package com.apptinic.terraview{
	import com.apptinic.util.SphereShape;
	import com.apptinic.util.SphereView;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

public class ContinentBuilder{
	
public static const LAND_COLOR:uint = 0xC0FFB0;
public static const LAND:String = "tt_land";
public static const WATER_COLOR:uint = 0x76A3FF;
public static const WATER:String = "tt_water";
public static const ICE_COLOR:uint = 0xEBFBFF;
public static const ICE:String = "tt_ice";

public var continentSpread:Number = 0.7;
public var continentMinSize:Number = 5;
public var continentMaxSize:Number = 12;
public var roughness:Number = .5;
public var maxCoastalSegmentSize:Number = .03;
public var addIcecaps:Boolean = true;
public var prebendTiles:Boolean = false;
public var schmutzCorners:Boolean = false;

public var hedron:TruncatedIcosahedron;
protected var vertexMap:Dictionary;
//vertexMap[i][0-2] = {vertex:int,  polygon:int}
public var continentOutlines:Vector.<Vector.<Vector3D>>;	
public var tiles:Vector.<SphereShape>;

public var tempsv:SphereView;
	
public function ContinentBuilder(){
	
}

public function generate():void{
	hedron = new TruncatedIcosahedron();
	var tile:SphereShape;
	tiles = new Vector.<SphereShape>();
	continentOutlines = new Vector.<Vector.<Vector3D>>;
	var outline:Vector.<Vector3D>
	
	paintRandomContinents();
	hedron.faces[0].color = LAND_COLOR;
	createGraph();
		
	for each(tile in tiles){
		if(tile.color==LAND_COLOR){
			var coast:Object = seekACoast(tile.vertices[0]);
			
			if(!coast){
				trace("Could not find an edge for this polygon!!!: ");
				continue;
			}
			if(findExistingCoastPoint(coast.edge)) continue;
			outline = traceOutline(coast.edge,coast.away);
			continentOutlines.push(outline);
		}
	}
	
	for each(outline in continentOutlines){
		trace("found coastline: "+outline.length);
		createCoastline(outline);
	}	
	if(addIcecaps){
		for(var i:int=30;i<hedron.faces.length;i++){
			var last:Vector3D = hedron.faces[i].vertices[hedron.faces[i].vertices.length-1];
			tile = new SphereShape({
				color:ICE_COLOR, vertices:new Vector.<Vector3D>,
				loc_i:(i%2==0? 0:7), loc_j:0
			});
			for(var j:int=0;j<hedron.faces[i].vertices.length;j++){
				//tile.vertices.push(hedron.faces[i].vertices[j].clone());
				tile.vertices = tile.vertices.concat(getInterPoints(last,hedron.faces[i].vertices[j]));
				tile.seedVertices = hedron.faces[i].seedVertices;
				last = hedron.faces[i].vertices[j];
			}
			tiles.push(tile);
		}	
	}
	if(prebendTiles)	
		for each(tile in tiles) tile.bend();
	
	hedron=null;
	vertexMap=null;
}

public function paintRandomContinents():void{
	var sizeOfContinent:int;
	var direction:int;
	var point:Point = new Point();
	var seed:SphereShape;
	var location:SphereShape;
	var p:Point;
	//var i:int;
	for each(var face:SphereShape in hedron.faces)
		face.color = WATER_COLOR;
	for(var i:int=0;i<3;i++){//0xC0FFB0
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
			location = hedron.faces[hedron.findContainingFace(SphereView.toCartesian(point.y,point.x))];
			location.color = LAND_COLOR;
		}
	}
}

//finds a vertex on the east coast
public function seekACoast(initialPoint:Vector3D,transitColor:uint=LAND_COLOR):Object{
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

public static function getColorForType(type:String):uint{
	switch(type){
		case LAND:
			return LAND_COLOR;
		case WATER:
			return WATER_COLOR;
		case ICE:
			return ICE_COLOR;
	}
	return NaN;
}

public static function getTypeForColor(color:uint):String{
	switch(color){
		case LAND_COLOR:
			return LAND;
		case WATER_COLOR:
			return WATER;
		case ICE_COLOR:
			return ICE;
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

public function traceOutline(initialPoint:Vector3D, backDir:Vector3D):Vector.<Vector3D>{
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
				
				if(posAng < smallestAngle){
					smallestAngle = posAng;
					nextVertex = aVertex;
				}
			}		 	
		}
		
		//now, we know what the next node will be
		backDir = vertex.subtract(nextVertex);
		vertex = nextVertex;
		outline.push(nextVertex);
		if(schmutzCorners)
			schmutzVertex(nextVertex);
	}while(  vertex != initialPoint)
	return outline;
}

public function createCoastline(outline:Vector.<Vector3D>):void{
	var j:int;
	var index:int;
	var node:Vector.<SphereShape>;
	var vertex:Vector3D;
	var nextVertex:Vector3D;
	
	for(var i:int=0;i<outline.length;i++){
		vertex = outline[i];
		nextVertex = outline[(i+1)%outline.length];
		
		node = vertexMap[vertex];
		
		//figure out which polygon (node[j]), and which vertex (node[j].vertices[index])
		j=0;
		
		//not found on node[j] || node[j] next vertex is not the one -> try another j
		while((index = node[j].vertices.indexOf(vertex)) == -1 || 
			node[j].vertices[(index+1)%node[j].vertices.length] != nextVertex) 
				j++;
		
		//get intermediate points
		var points:Vector.<Vector3D> = getInterPoints(vertex,nextVertex);
		
		//splice interpoints into node[j].vertices
		for(var k:int=0;k<points.length;k++)
			node[j].vertices.splice(index+k+1,0,points[k]);
		
		//trace("added coastline points: "+points.length);
	}
}

public function saveContinents(gameStateId:int):void{
	var locData:Array = [];
	for each(var tile:SphereShape in tiles){
		//locData.push({i:
	}
}

protected function getInterPoints(left:Vector3D, right:Vector3D):Vector.<Vector3D>{
	var points:Vector.<Vector3D> = new Vector.<Vector3D>();
	var len:Number;
	
	var seg:Vector3D = right.subtract(left);
	var norm:Vector3D = seg.crossProduct(left);
	norm.scaleBy(roughness);
	var r1:Number = Math.random();
	seg.scaleBy(r1);
	norm.scaleBy((Math.random()-.5)*(1-Math.abs(2*r1-1)));
	
	var mid:Vector3D = seg.add(norm);
	len = mid.length;
	mid = mid.add(left);
	mid.normalize();
	
	if(len > maxCoastalSegmentSize)
		points = points.concat(getInterPoints(left,mid));
	points.push(mid);
	len = Vector3D.distance(mid,right);
	if(len > maxCoastalSegmentSize)
		points = points.concat(getInterPoints(mid,right));
	return points;
}

protected function schmutzVertex(v:Vector3D):void{
	v.x += (Math.random()-.5)*maxCoastalSegmentSize*2;
	v.y += (Math.random()-.5)*maxCoastalSegmentSize*2;
	v.z += (Math.random()-.5)*maxCoastalSegmentSize*2;
	v.normalize();
}

public function createGraph():void{
	vertexMap = new Dictionary();
	var node:Vector.<SphereShape>;
	for each(var tile:SphereShape in hedron.faces){
		var tile2:SphereShape = new SphereShape(tile);
		for(var j:int=0;j<tile2.vertices.length;j++){
			if(!(node = vertexMap[tile2.vertices[j]])){
				node = new Vector.<SphereShape>();
				vertexMap[tile2.vertices[j]] = node;
			}
			node.push(tile2);	
		}
		if(tile2.color == LAND_COLOR) tiles.push(tile2);
	}
}


}}