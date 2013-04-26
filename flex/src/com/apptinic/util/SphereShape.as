package com.apptinic.util{
	import com.apptinic.terraschema.Location;
	import com.apptinic.terraschema.TerraRailsClassConverter;
	import com.apptinic.terraview.ContinentBuilder;
	
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

//public var loc_i:int;
//public var loc_j:int;
public var dataItem:Location;

public var center:Vector3D;
public var type:String;
public var seedVertices:Vector.<Vector3D>;
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
public function createTerrainTile():SphereShape{
	var out:SphereShape = new SphereShape();
	out.dataItem = this.dataItem;
	out.color = ContinentBuilder.getColorForType(this.dataItem.terrainType);
	var iceMode:Boolean = this.dataItem.terrainType == ContinentBuilder.ICE;
	out.vertices = new Vector.<Vector3D>();
	for(var i:int=0;i<this.seedVertices.length;i++){
		var vert:Vector3D = seedVertices[i];
		var vert2d:Object = SphereView.toSpherical(vert);
		if(!iceMode) out.vertices.push(vert);
		if(out.dataItem.coastSegments[i]){
			var extras2d:Array = UDF.decodeLine(out.dataItem.coastSegments[i]);
			for each(var coord:Object in extras2d){
				var extra:Vector3D = SphereView.toCartesian(coord.lat+vert2d.lat,coord.lon+vert2d.lon);
				out.vertices.push(extra);
			}
		}
	}//polygon vertex loop
	return out;
}
public function encodeTerrainInfo():void{
	var j:int=0;
	var segmentEndInd:int=0;
	var seedVert2d:Object;
	var segment:Array;
	
	if(!dataItem)
		dataItem = new Location();
	dataItem.terrainType = ContinentBuilder.getTypeForColor(this.color);

	for(var i:int=0;i<seedVertices.length;i++){
		segment = [];
		seedVert2d = SphereView.toSpherical(seedVertices[i]);
		segmentEndInd = i==seedVertices.length-1 ? 
			vertices.length : vertices.indexOf(seedVertices[i+1]);
		if(segmentEndInd == -1)
			segmentEndInd = vertices.length;
		j++;
		while(j<segmentEndInd){
			var pt:Object = SphereView.toSpherical(vertices[j]);
			segment.push({lat:pt.lat-seedVert2d.lat, lon:pt.lon-seedVert2d.lon});
			j++;
		}
		//var sstr:String;
		dataItem.coastSegments.push(/*sstr=*/UDF.encodeLine(segment));
		//trace("segment length"+sstr.length);
	}
}

public function set loc_i(input:int):void{
	if(!dataItem)
		dataItem = new Location();
	dataItem.i = input;
}
public function get loc_i():int{return dataItem?dataItem.i : NaN;}
public function set loc_j(input:int):void{
	if(!dataItem)
		dataItem = new Location();
	dataItem.j = input;
}
public function get loc_j():int{return dataItem?dataItem.j : NaN;}

}}