package com.apptinic.terraview{
	import com.apptinic.util.SphereShape;
	import com.apptinic.util.SphereView;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

public class ContinentBuilder{
	
public const LAND_COLOR:uint = 0xC0FFB0;
public const SEA_COLOR:uint = 0x76A3FF;
public const ICE_COLOR:uint = 0xe0faff;

public var continentSpread:Number = 0.7;
public var continentMinSize:Number = 5;
public var continentMaxSize:Number = 12;
public var roughness:Number = 1;
public var addIcecaps:Boolean = true;

public var hedron:TruncatedIcosahedron;
protected var vertexMap:Dictionary;
//vertexMap[i][0-2] = {vertex:int,  polygon:int}
protected var continentOutlines:Vector.<Vector.<Vector3D>>;	
protected var continents:Vector.<SphereShape>;
	
public function ContinentBuilder(hedronIn:TruncatedIcosahedron=null){
	if(hedronIn)
		hedron = hedronIn;
	else
		hedron = new TruncatedIcosahedron();
	
	createMap();
	generate();
}

public function generate():void{
	var i:int;
	
	continents = new Vector.<SphereShape>();
	continentOutlines = new Vector.<Vector.<Vector3D>>;
	paintRandomContinents();
	
	for(i=0;i<hedron.faces.length;i++){
		var west:Vector3D = findWestCoast(hedron.faces[i].vertices[0]);
		if(findExistingCoastPoint(west)) continue;
		var outline:Vector.<Vector3D> = getOutline(west,west.crossProduct(new Vector3D(0,-1,0)));
		continentOutlines.push(outline);
	}
	
	for(i=0;i<continentOutlines.length;i++)
		continents.push(createPrettyContinent(continentOutlines[i],LAND_COLOR));
	
	if(addIcecaps){
		for(i=30;i<hedron.faces.length;i++){
			hedron.faces[i].color = ICE_COLOR;
			continents.push(createPrettyContinent(hedron.faces[i].vertices,ICE_COLOR));
		}
	}
}

public function paintRandomContinents():void{
	var sizeOfContinent:int;
	var direction:int;
	var point:Point = new Point();
	var seed:SphereShape;
	var location:SphereShape;
	var p:Point;
	var i:int;
	for(i=0;i<hedron.faces.length;i++)
		hedron.faces[i].color = SEA_COLOR;
	for(i=0;i<3;i++){//0xC0FFB0
		seed = hedron.faces[Math.round(Math.random()*hedron.faces.length)];
		sizeOfContinent = Math.round(Math.random()*(continentMaxSize-continentMinSize) + continentMinSize)
		for(var j:int=0;j<sizeOfContinent;j++){
			point = new Point(seed.lon,seed.lat);
			for(var k:int=0;k<10;k++){
				direction = Math.random() > .5 ? 1 : -1;
				point.x += continentSpread*direction;
				direction = Math.random() > .5 ? 1 : -1;
				point.y += continentSpread*direction;
			}
			location = hedron.findContainingLocation(SphereView.toCartesian(point.y,point.x),true)
			location.color = LAND_COLOR;
		}
	}
}

public function createPrettyContinent(outline:Vector.<Vector3D>,color:uint):SphereShape{
	var res:int = 50;
	var poly:SphereShape = new SphereShape();
	poly.vertices = outline;
	var con:SphereShape = hedron.bendTile(poly,res)
	con.color = color;
	con.alpha = 1;
	
	var cumu:Number = 0;
	var squeezeThreshold:Number = con.vertices.length - res/2;
	var randSize:Number = .3/res*.17
	
	for(var i:int=0;i<con.vertices.length;i++){
		if(i > squeezeThreshold) cumu *= .9
		var devi:Number = 2*Math.random()*randSize-1 + cumu;
		var norm:Vector3D = con.vertices[i].subtract(con.vertices[i+1]).crossProduct(con.vertices[i]);
		norm.normalize();
		norm.scaleBy(devi);
		con.vertices[i] = con.vertices[i].add(norm);
		con.vertices[i].normalize();
		cumu = devi;
	}
	
	return con;
}


//finds a vertex on the east coast
public function findWestCoast(initialPoint:Vector3D):Vector3D{
	var vertex:Vector3D = initialPoint;
	var nextVertex:Vector3D;
	var largest:Number;
	var westward:Vector3D;
	
	while(true){
		var node:Vector.<SphereShape> = vertexMap[vertex];
		largest = -1.0;
		westward = vertex.crossProduct(new Vector3D(0,-1,0));
		for(var i:int=0;i<node.length;i++){
			if(node[i].color == LAND_COLOR){	
				for(var j:int=0;j<node[i].vertices.length;j++){
					var dir:Vector3D = node[i].vertices[j].subtract(vertex);
					var dp:Number = dir.dotProduct(westward);
					if(dp > largest){
						largest = dp;
						nextVertex = node[i].vertices[j];
					}
				} //vertices of shape i
			} //if		 	
		}
		
		if(largest <= 0) return vertex;
		vertex = nextVertex;
	}
	return null;
}
protected function findExistingCoastPoint(point:Vector3D):Object{
	var output:Object;
	var i:int=0;
	var j:int;
	while(i < continentOutlines.length && !output){
		if((j=continentOutlines[i].indexOf(point))!=-1)
			output = {continent:i, position:j};
		i++;
	}
	return output;
}

public function getOutline(initialPoint:Vector3D, backDir:Vector3D):Vector.<Vector3D>{
	var outline:Vector.<Vector3D> = new Vector.<Vector3D>;
	var vertex:Vector3D = initialPoint;
	var nextVertex:Vector3D;
	var smallestAngle:Number;
	
	//outline.push(initialPoint);
	do{
		//now we have vertex, which is on an edge, and backDir, a reference direction
		var node:Vector.<SphereShape> = vertexMap[vertex];
		smallestAngle = 7.0;
		for(var i:int=0;i<node.length;i++){
			//find the next vertex with the smallest positive angle
			if(node[i].color == LAND_COLOR){	
				//for each polygon touching this node
				//find the potential next vertex
				var nextN:int = (node[i].vertices.indexOf(vertex)+1)%node[i].vertices.length;
				var aVertex:Vector3D = node[i].vertices[nextN];
				var newDir:Vector3D = vertex.subtract(aVertex);
				var posAng:Number = Vector3D.angleBetween(backDir,newDir);
				if(backDir.crossProduct(newDir).dotProduct(node[i].center) < 0)
					posAng = 2*Math.PI - posAng;
				if(posAng < smallestAngle){
					smallestAngle = posAng;
					nextVertex = aVertex;
					trace("vertex option:"+i+" angle:"+posAng);
				}
			}
			//now, we know what the next node will be
			backDir = vertex.subtract(nextVertex);
			vertex = nextVertex;
			outline.push(nextVertex);		 	
		}
	}while(vertex != initialPoint)
	
	return outline;
}

public function createMap():void{
	vertexMap = new Dictionary();
	var node:Vector.<SphereShape>;
	for(var i:int=0;i<hedron.faces.length;i++){
		for(var j:int=0;j<hedron.faces[i].vertices.length;j++){
			if(!(node = vertexMap[hedron.faces[i].vertices[j]])){
				node = new Vector.<SphereShape>();
				vertexMap[hedron.faces[i].vertices[j]] = node;
			}
			node.push(hedron.faces[i]);	
		}
	}
}


}}