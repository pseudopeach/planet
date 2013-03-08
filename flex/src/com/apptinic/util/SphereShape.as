package com.apptinic.util{
	import flash.geom.Vector3D;

public class SphereShape{
	
public var color:uint;
public var alpha:Number=1;
public var borderColor:uint;
public var borderThickness:int=1;
public var borderAlpha:Number=0;

public var lat:Number;
public var lon:Number;
public var center:Vector3D;
public var type:String;
public var vertices:Vector.<Vector3D>;
public var adjacentShapes:Vector.<SphereShape>;
	
	
public function SphereShape(input:Object=null){
	if(input){
		for(var s:String in input)
			if(this.hasOwnProperty(s))
				this[s] = input[s];
	}
}

}}