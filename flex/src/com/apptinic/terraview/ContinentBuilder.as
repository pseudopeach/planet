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
public var continentOutlines:Vector.<Vector.<Vector3D>>;	
protected var continents:Vector.<SphereShape>;

public var tempsv:SphereView;
	
public function ContinentBuilder(hedronIn:TruncatedIcosahedron=null){
	if(hedronIn)
		hedron = hedronIn;
	else
		hedron = new TruncatedIcosahedron();
	
	createMap();
	//generate();
}

public function generate():void{
	var i:int;
	
	continents = new Vector.<SphereShape>(); 
	continentOutlines = new Vector.<Vector.<Vector3D>>;
	paintRandomContinents();
	
	
	for(i=0;i<hedron.faces.length;i++){
		if(hedron.faces[i].color==LAND_COLOR){
			var coast:Object = findCoast(hedron.faces[i].vertices[0]);
			
			if(!coast){
				trace("Could not find an edge for this polygon!!!: "+i);
				continue;
			}
			if(findExistingCoastPoint(coast.edge)) continue;
			var outline:Vector.<Vector3D> = getOutline(coast.edge,coast.away);
			continentOutlines.push(outline);
		}
	}
	for(i=0;i<continentOutlines.length;i++)
		trace("found outline:"+continentOutlines[i].length);
	
	
	/*
	for(i=0;i<continentOutlines.length;i++)
		continents.push(createPrettyContinent(continentOutlines[i],LAND_COLOR));
	
	if(addIcecaps){
		for(i=30;i<hedron.faces.length;i++){
			hedron.faces[i].color = ICE_COLOR;
			continents.push(createPrettyContinent(hedron.faces[i].vertices,ICE_COLOR));
		}
	}
	*/
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
		seed = hedron.faces[Math.round(Math.random()*(hedron.faces.length-1))];
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

//finds a vertex on the east coast
public function findCoast(initialPoint:Vector3D,transitColor:uint=LAND_COLOR):Object{
	var vertex:Vector3D; 
	var nextVertex:Vector3D = initialPoint;
	var largest:Number;
	//var away:Vector3D;
	var node:Vector.<SphereShape>
	var i:int;
	var j:int;
	var northPole:Vector3D = new Vector3D(0,-1,0);
	var goRandom:Boolean = false;
	
	for(var step:int=0;step<30;step++){
		vertex = goRandom ? node[Math.floor(Math.random()*node.length)].vertices[0] : nextVertex;
		node = vertexMap[vertex];
		largest = -1.0;
		for(i=0;i<node.length;i++){
			//for the ith polygon touching vertex...
			if(node[i].color != transitColor){	
				return {edge:vertex, away:node[i].center.subtract(vertex)};
			}
			if(!goRandom){
				//vertex is not on the coast
				//search the vertices of shape i for a more notherly one
				for(j=0;j<node[i].vertices.length;j++){
					var dir:Vector3D = node[i].vertices[j].subtract(vertex);
					var dp:Number = dir.dotProduct(northPole);
					if(dp > largest){
						largest = dp;
						nextVertex = node[i].vertices[j];
					}
				}
			}
		}
		
		//done searching this node
		if(largest <= 0) goRandom = true;
			
	}

	return null; //fail
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
		//trace("new node " );//+vertex.x+","+vertex.y+","+vertex.z);
		for(var i:int=0;i<node.length;i++){
			//search next vertices on connected polygons for the smallest positive angle
			if(node[i].color == LAND_COLOR){	
				//for each polygon touching this node
				//find the potential next vertex
				var nextN:int = (node[i].vertices.indexOf(vertex)+1)%node[i].vertices.length;
				var aVertex:Vector3D = node[i].vertices[nextN];
				var newDir:Vector3D = aVertex.subtract(vertex);
				var posAng:Number = Vector3D.angleBetween(backDir,newDir);
				if(backDir.crossProduct(newDir).dotProduct(node[i].center) < 0)
					posAng = 2*Math.PI - posAng;
				//trace("vertex option:"+i+" angle:"+posAng*180/Math.PI);
				if(posAng < smallestAngle){
					smallestAngle = posAng;
					nextVertex = aVertex;
				}
			}		 	
		}
		
		//now, we know what the next node will be
		//trace("picked vertex, angle:"+smallestAngle*180/Math.PI);
		backDir = vertex.subtract(nextVertex);
		vertex = nextVertex;
		outline.push(nextVertex);
		//trace("now at: "+vertex.x+","+vertex.y+","+vertex.z);
		//tempLimit++;
	}while(  vertex != initialPoint)
	return outline;
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