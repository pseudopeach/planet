package com.apptinic.util{
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.PropertyChangeEvent;

[bindable]
public dynamic class ASRecord extends EventDispatcher{
//{type:MANY, assocClass:class, locProp:Object, fKeyName:"blabla_id", repo:Object
public static const HAS_MANY:String = "hasMany";
public static const BELONGS_TO:String = "belongsTo";
public static const SCHEMA:Dictionary = new Dictionary();
protected static const REPO:Dictionary = new Dictionary();
public static var fidCount:int = 1;

public var id:int;
protected var fid:int;

public var supressEvents:Boolean = false;
public var isPopulated:Boolean = false;

protected var lastProcessedUpdateEventId:int=-1;
protected var lastDispatchedUpdateEventId:int=-1;

// =========== lazily generated, read-only attributes =================

protected var _schemaEntry:Object;
/*protected function get schemaEntry():Object{
	if(!_schemaEntry){
		_schemaEntry = SCHEMA[this.constructor];
		if(!_schemaEntry)
			throw new Error("No schema info was set for this class: "+this.constructor.toString());
	}
	return _schemaEntry;
}*/
protected var _classInfo:ASRecordClass;
public function get classInfo():ASRecordClass{
	if(!_classInfo)
		_classInfo = SCHEMA[this.constructor];
	return _classInfo;
}

// =========== creation functions =================

public function ASRecord(id:*=null){
	if(id)
		this._id = id;
	this.fid = fidCount;
	fidCount++;
	
	addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropertyChanged);
	//ActionscriptRecord.storeObject(this);
}

public static function createRecord(klass:ASRecordClass,id:*=null):ASRecord{
	var record:ASRecord = new klass.klass();
	record.id = id;
	storeObject(record);
	return record;
}

public static function findOrCreate(klass:ASRecordClass,id:*=null):ASRecord{
	var out:ASRecord = findStoredObject(klass.tableBaseClass,id);
	if(!out)
		out = createRecord(klass,id);
	return out;
}

/*public function enterInSchema(forClass:Class, input:Array):void{
	if(SCHEMA[forClass]) return;
	var className:String = ASRecordClass.friendlyClassName(this);
	var schemaEntry:Object = new Object();
	var assoc:ASRecordAssociation;
	_classInfo = ASRecordClass.getInstance(this.constructor);
	
	schemaEntry.classInfo = _classInfo;
	schemaEntry.associations = new Object();
	//copy associations from superklass (inherit)
	if(_classInfo.superKlass)
		for(var s:String in _classInfo.superKlass.associations){
			assoc = _classInfo.superKlass.associations[s];
			schemaEntry.associations[assoc.propName] = assoc;
		}
	for(var i:int;i<input.length;i++){
		assoc = new ASRecordAssociation(input[i]);
		schemaEntry.associations[assoc.propName] = assoc;
		
		trace("** created association ** "+this._classInfo.shortClassName+" "+
			assoc.type+" "+assoc.propName);
	}
	_classInfo.associations = schemaEntry.associations;
	SCHEMA[forClass] = schemaEntry;
	//trace("setting schema info schema entry: "+className);
}*/

public function enterInSchema(forClass:Class, assocIn:Array=null):void{
	if(SCHEMA[forClass]) return;
	if(!assocIn) assocIn = []; //shouldnt have to do this
	var schemaEntry:ASRecordClass = ASRecordClass.getInstance(forClass);
	var assoc:ASRecordAssociation;
	schemaEntry.associations = new Object();
	
	//copy associations from superklass (inherit)
	if(schemaEntry.superKlass)
		for(var s:String in schemaEntry.superKlass.associations){
			assoc = schemaEntry.superKlass.associations[s];
			schemaEntry.associations[assoc.propName] = assoc;
		}
	for(var i:int;i<assocIn.length;i++){
		assoc = new ASRecordAssociation(assocIn[i]);
		schemaEntry.associations[assoc.propName] = assoc;
		
		trace("** created association ** "+schemaEntry.shortClassName+" "+
			assoc.type+" "+assoc.propName);
	}
	SCHEMA[forClass] = schemaEntry;
	_classInfo = schemaEntry;
}

// =========== Core Functionality =================

public function update(input:Object, event:ASRecordEvent=null):void{
	
	//precaution against circular updating
	if(event && event.eventId == lastProcessedUpdateEventId) return;
	var newEvent:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this,event);
	lastProcessedUpdateEventId = newEvent.eventId;
	
	var item:Object;
	var record:ASRecord;
	var assoc:ASRecordAssociation;
	for(var s:String in input){
		assoc = classInfo.assocByFKey[s];
		if(assoc && !input.hasOwnProperty(assoc.propName)){
			record = findOrCreate(assoc.classInfo,input[s]);
		 	this[assoc.propName] = record;
		}else{
			item = input[s];
			assoc = classInfo.associations[s];
			if(assoc && assoc.type==HAS_MANY)
				setMany(assoc,item);
			else if(s!="id")
				this[s] = item; 
		}
	}
	isPopulated = true;
}

public function setMany(assoc:ASRecordAssociation,input:Object):void{
	var listIn:IList;
	if(input as Array) listIn = new ArrayCollection(input as Array);
	else listIn = input as IList;
	if(!this[assoc.propName])
		this[assoc.propName] = new UberCollection();
	var list:UberCollection = this[assoc.propName];
	list.refObject = assoc;
	if(!list.hasEventListener(ASRecordEvent.CHANGE))
		list.addEventListener(ASRecordEvent.CHANGE, onMemberCollectionChange);
	list.supressEvents = true;
	list.removeAll();
	for(var i:int=0;i<listIn.length;i++){
		var record:ASRecord = findOrCreate(assoc.classInfo,listIn[i].id);
		record.update(listIn[i]);
		list.addItem(record);
	}
	list.supressEvents = false;
	list.refresh();
}

protected function onMemberCollectionChange(event:ASRecordEvent):void{
	var record:ASRecord = event.item as ASRecord;
	var assoc:ASRecordAssociation = (event.target as UberCollection).refObject as ASRecordAssociation;
	
	if(assoc.propName == "attributes")
		trace("pause here");
	//**** figure out how to look that up
	var invAssoc:ASRecordAssociation;
	switch(event.subtype){
		case ASRecordEvent.COLL_ITEM_ADDED:
			if((invAssoc = assoc.inverse))
				record[invAssoc.propName] = this			
			//add event listener?
		break;
		case ASRecordEvent.COLL_ITEM_REMOVED:
			if((invAssoc = assoc.inverse))
				record[invAssoc.propName] = null;			
			//remove event listener?
		break;
	}
}

//this function bulk updates this ASRecord, and any associated records that are mentioned in the input
/*public function update(input:Object, event:ASRecordEvent=null):void{
	if(event && event.eventId == lastProcessedUpdateEventId) return;
	
	var newEvent:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this,event);
	lastProcessedUpdateEventId = newEvent.eventId;
	var association:ASRecordAssociation;
	var dummies:Array = [];
	var lu:Array = []
	for(var s:String in input){
		association = assocByFKey[s];
		if(association && !input.hasOwnProperty(association.propName))
			dummies.push({association:association, value:input[s]});
		else if((association = associations[s]))
			lu.push({association:association, value:input[s], event:event});
		else
			this[s] = input[s];    
	}
	this.isPopulated = true;
	if(input.hasOwnProperty("id")) ASRecord.storeObject(this);
	
	//save associated objects
	var i:int;
	var item:ASRecord;
	for(i=0;i<dummies.length;i++) linkDummyRecord(dummies[i].association,dummies[i].value);
	for(i=0;i<lu.length;i++){
		var assoc:ASRecordAssociation = lu[i].association;
		if(assoc.type == HAS_MANY){
			var collection:UberCollection = this[assoc.propName];
			if(!collection){
				this[assoc.propName] = new UberCollection();
				collection = this[assoc.propName];
				collection.supressEvents = true;
			}else{
				collection.supressEvents = true;
				collection.removeAll();
			}
			
			//add all the items
			for(var j:int=0;j<lu[i].value.length;j++){
				//**** implement this
			}
			collection.addEventListener(ASRecordEvent.CHANGE,onLinkedCollectionUpdate);
			collection.supressEvents = false;
			collection.refresh();
			
		}else{
			//single (belongs_to) member update
			item = updateMember(assoc.propName,lu[i].value,-1,event,lu[i].assoc);
			if(assoc.inverse) item.updateMember(assoc.inverse, this, -1, event);
		}
	}
	
	if(!supressEvents)
		dispatchEvent(newEvent);
}*/

public static function findStoredObject(klass:Class,id:*):ASRecord{
	var store:Object = REPO[klass];
	if(!store) return null;
	return store["id-"+id.toString()];    
}
public static function storeObject(obj:ASRecord):void{
	if(!obj.classInfo)
		throw new Error("Somehow, an instance of ASRecord exists with null classInfo");
	var store:Object = REPO[obj.classInfo.tableBaseClass];
	if(!store){
		store = new Object()
		REPO[obj.classInfo.tableBaseClass] = store;
	}
	store["id-"+obj.id.toString()] = obj;
}

protected function onPropertyChanged(event:PropertyChangeEvent):void{
	var newRecord:ASRecord = event.newValue as ASRecord;
	var oldRecord:ASRecord = event.oldValue as ASRecord;
	var assoc:ASRecordAssociation;
	var invAssoc:ASRecordAssociation;
	
	if((assoc = classInfo.associations[event.property])){
		//updated an associated member
		if(assoc.type==HAS_MANY){
			this.setMany(assoc,event.newValue);
			return;
		}
		if(oldRecord){
			//make sure we're not about to mess up referrential integrity
			if(oldRecord.id == newRecord.id)
				throw new Error("Can't assign a different record with the same id. Use update instead.");
			//oldRecord.removeEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
		}
		
		//deal with inverses
		if((invAssoc = assoc.inverse)){
			if(invAssoc.type == BELONGS_TO){
				oldRecord[invAssoc.propName] = null;
				newRecord[invAssoc.propName] = this;
			}else{
				(oldRecord[invAssoc.propName] as UberCollection).removeItem(this);
				(newRecord[invAssoc.propName] as UberCollection).addItem(this);
			}
		}
		
		//newRecord.addEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
	}else if((assoc = classInfo.assocByFKey[event.property])){
		setfKey(assoc.propName,event.newValue,assoc);
	}
	if(event.property != "id") isPopulated = true;
	
	var newEvent:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
	dispatchEvent(newEvent);
	
}
public function setfKey(propName:String, idValue:*, assoc:ASRecordAssociation=null, propAlreadyUpdated:Boolean=false):void{
	var record:ASRecord;
	if(!assoc) 
		assoc = classInfo.associations[propName];
	record = findOrCreate(assoc.classInfo,idValue);
	if(!propAlreadyUpdated) 
		this[assoc.propName] = record;
}

//public static function getRecordFrom

//this function called when only the id of an associated object is known
/*public function linkDummyRecord(assocEntry:ASRecordAssociation, id:*, index:int=-1):void{
	var record:ASRecord = searchStoredObjects(assocEntry.assocClassName,id);
	if(!record){
		var aclass:Class = assocEntry.assocClass
		record = new aclass();
		record.id = id;
		record.addEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
		ASRecord.storeObject(record,assocEntry.assocClassName);
	}
	if(index == -1)
		this[assocEntry.propName] = record;
	else
		this[assocEntry.propName][index] = record;    
}*/
/*public function updateAssociated(assocEntry:Object, input:Object, event:ASRecordEvent=null, manyIndex:int=-1):void{
	//get a record instance, update existing if required
	var record:ASRecord = saveOrCreateRecord(input,assocEntry.assocClass,assocEntry.assocClassName);
	if(!this[assocEntry.propName]){
		//never been set on this
		record.addEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
		if(manyIndex == -1)
			this[assocEntry.propName] = record;
		else{
			this[assocEntry.propName][manyIndex] = record;
			/*if(assocEntry.inverse) 
				record.updateAssociated(f,
		}
	}
	record.update(input,true,event);
}
public function saveOrCreateRecord(input:Object, klass:Class=null, repoClassName:String=null, event:ASRecordEvent=null, autoDispatch:Boolean=true):ASRecord{
	var newRecClass:Class = input.hasOwnProperty('asType') ? 
		getClassForType(input.asType) : klass;
	var repoName:String = repoClassName ? repoClassName : getQualifiedClassName(klass);
	var record:ASRecord = searchStoredObjects(repoName,input.id);
	if(!record){
		record = new newRecClass(input);
		ASRecord.storeObject(record,repoName);
	}else
		record.update(input,autoDispatch,event);
	return record;
}*/

protected function onLinkedRecordUpdate(event:ASRecordEvent):void{
	if(lastDispatchedUpdateEventId != event.eventId){
		lastDispatchedUpdateEventId = event.eventId;
		var newEvent:ASRecordEvent = new ASRecordEvent(event.type,null,event);
		dispatchEvent(newEvent);
	}
}

protected function onLinkedCollectionUpdate(event:ASRecordEvent):void{
	if(event.subtype == ASRecordEvent.COLL_ITEM_ADDED)
		event.item.addEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
	else if(event.subtype == ASRecordEvent.COLL_ITEM_REMOVED)
		event.item.removeEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
	onLinkedRecordUpdate(event);
	//this function may need to differ someday, but for now, it's identical to onLinkedRecordUpdate
}
public function refresh():void{
	dispatchEvent(new ASRecordEvent(ASRecordEvent.CHANGE, this));
}

public function getAssociation(name:String):ASRecordAssociation{
	return classInfo.associations[name];
}



}}