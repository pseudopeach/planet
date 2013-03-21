package com.apptinic.util{
	import flash.geom.Vector3D;
	import flash.utils.describeType;

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
		var names:Array = [];
		var a:Object;
		var s:String;
		for(s in input)
			names.push(s);
		var classInfo:XML = describeType(input);
		for each (a in classInfo..accessor) 
			names.push(a.@name.toString());
		for each (a in classInfo..variable) 
			names.push(a.@name.toString());
		for each(s in names)
			if(this.hasOwnProperty(s)){
				if(s=="vertices"){
					this.vertices = new Vector.<Vector3D>();
					for each(var vertex:Vector3D in input.vertices)
						this.vertices.push(vertex);
				}else
					this[s] = input[s];
			}
	}
}

public function bend(maxSegSize:Number=.05):void{
	var vc:Vector.<Vector3D> = new Vector.<Vector3D>();
	//var lastVert:Vertex3D = vertices[vertices.length-1];
	for(var i:int=0;i<vertices.length;i++){
		vc.push(vertices[i]);
		var nextV:Vector3D = vertices[(i+1)%vertices.length];
		if(Vector3D.distance(vertices[i],nextV) > maxSegSize){
			var axis:Vector3D = vertices[i].crossProduct(nextV);
			var forepoint:Vector3D = axis.crossProduct(vertices[i]);
			forepoint.normalize();
			var endAng:Number = Vector3D.angleBetween(vertices[i],nextV);
			
			for(var j:Number=0;j<endAng;j=j+maxSegSize){
				vc.push(UDF.linearCombine(vertices[i],Math.cos(j),forepoint,Math.sin(j)));
			}
		} //if adding
	}//each orig. vertex
	vertices = vc;
}

}}