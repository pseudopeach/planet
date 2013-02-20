package com.apptinic.util{

import mx.collections.ArrayCollection;
import mx.collections.IList;

public class UndoableArrayCollection extends ArrayCollection{
	
public function UndoableArrayCollection(source:Array=null){
	super(source);
}
//====================  add  ============================ 

override public function addItemAt(item:Object,index:int):void{
	super.addItemAt(item,index);
	var trans:UndoableTransaction = new UndoableTransaction(UndoableTransaction.COLLECTION_ADDED_NEWVAL_AT_INDEX);
	trans.newValue = item;
	trans.index = index;
	trans.parent = this;
	UndoManager.recordAction(trans);
}

override public function addAllAt(addList:IList, index:int):void{
	var length:int = addList.length;
	for (var i:int=0; i < length; i++){
		super.addItemAt(addList.getItemAt(i), i+index);
	}
	var trans:UndoableTransaction = new UndoableTransaction(UndoableTransaction.COLLECTION_ADDED_NEWVALCOLLECTION_AT_INDEX);
	trans.newValue = addList;
	trans.index = index;
	trans.parent = this;
	UndoManager.recordAction(trans);
}

override public function removeItemAt(index:int):Object{
	var trans:UndoableTransaction = new UndoableTransaction(UndoableTransaction.COLLECTION_REMOVED_OLDVAL_FROM_INDEX);
	var item:Object = super.removeItemAt(index);
	trans.oldValue = item;
	trans.index = index;
	trans.parent = this;
	UndoManager.recordAction(trans);
	return item;
}

override public function removeAll():void{
	var trans:UndoableTransaction = new UndoableTransaction(UndoableTransaction.COLLECTION_REMOVED_OLDVALCOLLECTION_FROM_FIRST_INDEX);
	//make a shollow copy of the entire collection
	trans.oldValue = new ArrayCollection();
	for(var ii:int=0;ii<this.length;ii++)
		trans.oldValue.addItem(this[i]);
	trans.index = 0;
	trans.parent = this;
	UndoManager.recordAction(trans);
	var len:int = length;
	if (len > 0){
		if (localIndex){
			for (var i:int = len - 1; i >= 0; i--)
				super.removeItemAt(i);
		}
		else
			super.list.removeAll();
	}
}

}}