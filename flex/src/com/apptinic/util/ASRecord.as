package com.apptinic.util{
import flash.events.EventDispatcher;
import flash.geom.Vector3D;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.collections.ISummaryCalculator;
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
protected var _hasUnsavedChanges:Boolean = true;
public function get hasUnsavedChanges():Boolean{return _hasUnsavedChanges;}

public var isLockedForUpdate:Boolean = false;
public var isPopulated:Boolean = false;

protected var lastProcessedUpdateEventId:int=-1;
protected var lastDispatchedUpdateEventId:int=-1;

// =========== lazily generated, read-only attributes =================

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


protected var service:RequestQueue;
public function save():void{
	if(!service)
		service = new RequestQueue();
	
	service.addEventListener(RequestQueueEvent.RESULT, onSaveResult);
	var params:Object = this.toObject();
	service.addRequest(classInfo.remoteSaveMethodName,classInfo.remoteControllerName,params);
}

protected function onSaveResult(event:RequestQueueEvent):void{
	service.removeEventListener(RequestQueueEvent.RESULT, onSaveResult);
	this.id = event.data.id;
	this._hasUnsavedChanges = false;
}

public static function findOrCreate(classish:Object,id:*=null, eType:String=null):ASRecord{
	var klass:ASRecordClass;
	if(eType)
		klass = ASRecordClass.createFromString(eType);
	else if(!(klass = classish as ASRecordClass))
		klass = ASRecordClass.getInstance(classish as Class);
	var out:ASRecord = findStoredObject(klass.tableBaseClass,id);
	if(!out)
		out = createRecord(klass,id);
	return out;
}

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

protected static var _isBaseTableInherited:Boolean = false;
public function set isBaseTableInherited(input:Boolean):void{
	if(input != _isBaseTableInherited){
		if(input){
			var ci:ASRecordClass = classInfo;
			_classInfo.tableBaseClass = ci.superKlass.tableBaseClass;
			_isBaseTableInherited = true;
		}else{
			_classInfo.tableBaseClass = classInfo.klass;
			_isBaseTableInherited = false;
		}
	}
}
public function get isBaseTableInherited():Boolean{ return _isBaseTableInherited;}

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
			if(input[s]){
				record = findOrCreate(assoc.classInfo,input[s]);
			 	this[assoc.propName] = record;
			}else{
				this[assoc.propName] = null;
			}
		}else{
			item = input[s];
			assoc = classInfo.associations[s];
			if(assoc && assoc.type==HAS_MANY)
				setMany(assoc,item);
			else if(s!="id"){
				if(this.hasOwnProperty(s))
					this[s] = item;
				else
					trace("Warning: ASRecord "+classInfo.className+" couldn't accept the property: "+s);
			}
		}
	}
	//init();
	isPopulated = true;
}

public function toObject(shallow:Boolean=true):Object{
	var out:Object = new Object();
	var names:Array = [];
	var a:Object;
	var s:String;
	var assoc:ASRecordAssociation;
	for(s in this)
		names.push(s);
	var classInfo:XML = describeType(this);
	for each (a in classInfo..accessor) 
	names.push(a.@name.toString());
	for each (a in classInfo..variable) 
	names.push(a.@name.toString());
	for each(s in names){
		//copy stuff
		assoc = classInfo.associations[s];
		if(shallow){
			if(assoc && assoc.type == BELONGS_TO)
				out[assoc.fKeyName] = this[s] ? this[s].id : null;
			else if(!assoc)
				out[s] = this[s]
		}else{
			//todo: implement deep serialize
		}		
	}
	return out;
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
		if(!isLockedForUpdate && (invAssoc = assoc.inverse)){
			if(invAssoc.type == BELONGS_TO){
				if(oldRecord) updateLocked(oldRecord,invAssoc.propName,null);
				updateLocked(newRecord,invAssoc.propName,this);
			}else{
				//implement
			}
		}
		
		//newRecord.addEventListener(ASRecordEvent.CHANGE,onLinkedRecordUpdate);
	}else if((assoc = classInfo.assocByFKey[event.property])){
		setfKey(assoc.propName,event.newValue,assoc);
	}
	if(event.property != "id") isPopulated = true;
	
	this._hasUnsavedChanges = true;
	var newEvent:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
	dispatchEvent(newEvent);	
}

protected function onMemberCollectionChange(event:ASRecordEvent):void{
	var record:ASRecord = event.item as ASRecord;
	var assoc:ASRecordAssociation = (event.target as UberCollection).refObject as ASRecordAssociation;
	
	//**** this isn't running for player.attributes.add, why?
	if(!isLockedForUpdate){
		var invAssoc:ASRecordAssociation;
		switch(event.subtype){
			case ASRecordEvent.COLL_ITEM_ADDED:
				if((invAssoc = assoc.inverse))
					updateLocked(record,invAssoc.propName,this);			
				//add event listener?
			break;
			case ASRecordEvent.COLL_ITEM_REMOVED:
				if((invAssoc = assoc.inverse))
					updateLocked(record,invAssoc.propName,null);			
				//remove event listener?
			break;
		}
	}
}

public function setMany(assoc:ASRecordAssociation,input:Object,updateLocked:Boolean=false):void{
	var listIn:IList;
	if(input as Array) listIn = new ArrayCollection(input as Array);
	else listIn = input as IList;
	if(!this[assoc.propName]){
		if(updateLocked) isLockedForUpdate = true;
		this[assoc.propName] = new UberCollection();
		isLockedForUpdate = false;
	}
	var list:UberCollection = this[assoc.propName];
	list.refObject = assoc;
	if(!list.hasEventListener(ASRecordEvent.CHANGE))
		list.addEventListener(ASRecordEvent.CHANGE, onMemberCollectionChange);
	//list.supressEvents = true;
	list.removeAll();
	for(var i:int=0;i<listIn.length;i++){
		var record:ASRecord = findOrCreate(assoc.classInfo,listIn[i].id,listIn[i].eType);
		record.update(listIn[i]);
		list.addItem(record);
	}
	//list.supressEvents = false;
	list.refresh();
}

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

public function setfKey(propName:String, idValue:*, assoc:ASRecordAssociation=null, propAlreadyUpdated:Boolean=false):void{
	var record:ASRecord;
	if(!assoc) 
		assoc = classInfo.associations[propName];
	record = findOrCreate(assoc.classInfo,idValue);
	if(!propAlreadyUpdated) 
		this[assoc.propName] = record;
}

protected function onLinkedRecordUpdate(event:ASRecordEvent):void{
	if(lastDispatchedUpdateEventId != event.eventId){
		lastDispatchedUpdateEventId = event.eventId;
		var newEvent:ASRecordEvent = new ASRecordEvent(event.type,null,event);
		dispatchEvent(newEvent);
	}
}

public static function updateLocked(record:ASRecord, property:String, value:*):void{
	record.isLockedForUpdate = true;
	record[property] = value;
	record.isLockedForUpdate = false;
}

public function refresh():void{
	dispatchEvent(new ASRecordEvent(ASRecordEvent.CHANGE, this));
}

public function getAssociation(name:String):ASRecordAssociation{
	return classInfo.associations[name];
}



}}