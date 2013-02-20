package com.apptinic.util{
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.collections.IList;
import com.simmons.util.GenericObjectEvent;

public class UndoManager extends EventDispatcher{
	
public var maxBufferSize:int = 30;

private static var _sharedMgr:UndoManager;
public static function get sharedMgr():UndoManager{
	if(!_sharedMgr) _sharedMgr = new UndoManager();
	return _sharedMgr;
}
	
private var buffer:ArrayCollection = new ArrayCollection();   //**** make private
private var bufferPosition:int = 0;
public var recordingPaused:Boolean = false;
private var lockedForUpdate:Boolean = false;

public static const BUFFER_UPDATE:String = "bufferUpdated";
private static const TRANSACTION_MARKER_BEGIN:String = "beginTrans";
private static const TRANSACTION_MARKER_END:String = "endTrans";

	
public function UndoManager(target:IEventDispatcher=null){
	super(target);
}


private function doCollectionAdd(trans:UndoableTransaction,forwardTime:Boolean=true):void{
	var collection:ArrayCollection = trans.parent as ArrayCollection;
	collection.addAllAt(forwardTime? trans.newValue : trans.oldValue as IList,trans.index);
}

private function doCollectionRemove(trans:UndoableTransaction,forwardTime:Boolean=true):void{
	var hostColl:ArrayCollection = trans.parent as ArrayCollection;
	var reductionSize:int = (forwardTime? trans.oldValue : trans.newValue as IList).length;
	var endIndex:int = trans.index + reductionSize;
	if(endIndex > hostColl.length) throw new Error("Can't remove "+reductionSize+" elements starting at "+trans.index+" from collection with size "+hostColl.length);
	for(var i:int = endIndex-1;i>=trans.index;i--)
		hostColl.removeItemAt(i);
}

private function doPropChange(trans:UndoableTransaction,forwardTime:Boolean=true):void{
	trans.parent[trans.property] = forwardTime ? trans.newValue : trans.oldValue;
}

public static function stepForward():void{
	if(sharedMgr.bufferPosition == sharedMgr.buffer.length) return;
	var trans:UndoableTransaction = sharedMgr.buffer[sharedMgr. bufferPosition] as UndoableTransaction;
	
	sharedMgr.lockedForUpdate = true;
	
	switch(trans.action){
		case UndoableTransaction.COLLECTION_ADDED_NEWVAL_AT_INDEX:
		case UndoableTransaction.COLLECTION_ADDED_NEWVALCOLLECTION_AT_INDEX:
			sharedMgr.doCollectionAdd(trans);
		break;
		case UndoableTransaction.COLLECTION_REMOVED_OLDVAL_FROM_INDEX:
		case UndoableTransaction.COLLECTION_REMOVED_OLDVALCOLLECTION_FROM_FIRST_INDEX:
			sharedMgr.doCollectionRemove(trans);
		break;
		case UndoableTransaction.PROPERTY_OF_PARENT_CHANGED_FROM_OLDVAL_TO_NEWVAL:
			sharedMgr.doPropChange(trans);
		break;
		case TRANSACTION_MARKER_BEGIN:
		case TRANSACTION_MARKER_END:
		break;
		default: trace("WARNING: unknown undo buffer instruction skipped");
	}
	if(trans.parent as ArrayCollection)
		(trans.parent as ArrayCollection).refresh();
	
	sharedMgr.bufferPosition++;
	sharedMgr.lockedForUpdate = false;
	
	sharedMgr.onUpdateBuffer();
}

public static function stepBackward():void{
	if(sharedMgr.bufferPosition == 0) return;
	sharedMgr.lockedForUpdate = true;
	var trans:UndoableTransaction = sharedMgr.buffer[sharedMgr.bufferPosition-1] as UndoableTransaction;
	
	switch(trans.action){
		case UndoableTransaction.COLLECTION_ADDED_NEWVAL_AT_INDEX:
		case UndoableTransaction.COLLECTION_ADDED_NEWVALCOLLECTION_AT_INDEX:
			sharedMgr.doCollectionRemove(trans,false); //undo add = remove
			break;
		case UndoableTransaction.COLLECTION_REMOVED_OLDVAL_FROM_INDEX:
		case UndoableTransaction.COLLECTION_REMOVED_OLDVALCOLLECTION_FROM_FIRST_INDEX:
			sharedMgr.doCollectionAdd(trans,false); //undo remove = add;
			break;
		case UndoableTransaction.PROPERTY_OF_PARENT_CHANGED_FROM_OLDVAL_TO_NEWVAL:
			sharedMgr.doPropChange(trans,false); //backward time parameter causes prop change to roll back
			break;
		case TRANSACTION_MARKER_BEGIN:
		case TRANSACTION_MARKER_END:
			break;
		default: trace("WARNING: unknown undo buffer instruction skipped");
	}
	if(trans.parent as ArrayCollection)
		(trans.parent as ArrayCollection).refresh();
	
	sharedMgr.bufferPosition--;
	sharedMgr.lockedForUpdate = false;
	
	sharedMgr.onUpdateBuffer();
}

public static function recordAction(trans:UndoableTransaction):void{
	if(sharedMgr.recordingPaused || sharedMgr.lockedForUpdate) return;
	
	if(trans.action == UndoableTransaction.COLLECTION_ADDED_NEWVAL_AT_INDEX)
		trans.newValue = new ArrayCollection([trans.newValue]);  //wrap singles in an array collection
	if(trans.action == UndoableTransaction.COLLECTION_REMOVED_OLDVAL_FROM_INDEX)
		trans.oldValue = new ArrayCollection([trans.oldValue]);  //wrap singles in an array collection
	
	if(sharedMgr.bufferPosition != sharedMgr.buffer.length){ 
		//we undid some suff and then added new actions--Henceforth a new timeline exists.
		sharedMgr.buffer = new ArrayCollection(sharedMgr.buffer.source.slice(0,sharedMgr.bufferPosition));
	}
	
	sharedMgr.buffer.addItem(trans);
	if(sharedMgr.buffer.length > sharedMgr.maxBufferSize)
		sharedMgr.buffer.removeItemAt(0);
	
	sharedMgr.bufferPosition = sharedMgr.buffer.length;
	
	sharedMgr.onUpdateBuffer();
}

public static function startRecording():void {sharedMgr.recordingPaused=false;}
public static function stopRecording():void {sharedMgr.recordingPaused=true;}

public static function startUndoTransaction():void{
	var trans:UndoableTransaction = new UndoableTransaction();
	trans.action = TRANSACTION_MARKER_BEGIN;
	recordAction(trans);
}
public static function endUndoTransaction():void{
	var trans:UndoableTransaction = new UndoableTransaction();
	trans.action = TRANSACTION_MARKER_END;
	recordAction(trans);
}

private function onUpdateBuffer():void{
	var newEvent:GenericObjectEvent = new GenericObjectEvent(BUFFER_UPDATE);
	newEvent.Obj = {currentBuffer:buffer, bufferPosition:bufferPosition};
	dispatchEvent(newEvent);
}

}}