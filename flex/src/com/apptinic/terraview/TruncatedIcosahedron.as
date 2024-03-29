package com.apptinic.terraview{
	import com.apptinic.util.SphereShape;
	import com.apptinic.util.SphereView;
	
	import flash.geom.Vector3D;

public class TruncatedIcosahedron{
	
public const MAGIC_LATS:Array = [90.0, 52.6226318593503, 26.565051177078, 10.8123169635717];
public const PENT_RATIO:Number = 1.18299818148;

public var faces:Vector.<SphereShape>;
//public var curvedTiles:Vector.<SphereShape>;

public function init():void{
	createFaces();
	//validateFaces();
	//createCurvedTiles()
}

public function createFaces():void{
	var f1:SphereShape;
	var i:int;
	var j:int;
	faces = new Vector.<SphereShape>();
	for(i=1;i<MAGIC_LATS.length;i++){
		for(j=0;j<10;j++){
			faces.push( f1=new SphereShape({lat:MAGIC_LATS[i], lon:36.0*j, 
				type:"hex", vertices: new Vector.<Vector3D>(), center:new Vector3D(),
				adjacentShapes: new Vector.<SphereShape>(), loc_i:i, loc_j:j} ) );
			if(j%2==0){
				f1.lat *= -1;
				f1.loc_i = 7-i;
			}
			if(i==2){ f1.type = "pent";f1.lat *= -1;}
		}
	}
	faces.push(new SphereShape({lat:90.0, lon:0.0, type:"pent", loc_i:0, loc_j:0, 
		vertices: new Vector.<Vector3D>(), adjacentShapes: new Vector.<SphereShape>()}) );
	faces.push(new SphereShape({lat:-90.0, lon:0.0, type:"pent", loc_i:7, loc_j:0, 
		vertices: new Vector.<Vector3D>(), adjacentShapes: new Vector.<SphereShape>()}) );
	
	//pents 10-19, 30,31
	//arctic=30
	//antarctic=31
	for(i=10;i<20;i++){
		//j = i%10 + 8;
		addPentVertex(faces[i],faces[(i-2)%10+10]);//left arm
		addPentVertex(faces[i],faces[(i-1)%10+10]);//left leg
		addPentVertex(faces[i],faces[(i+1)%10+10]);
		addPentVertex(faces[i],faces[(i+2)%10+10]);
		addPentVertex(faces[i],faces[30+((i%2==1)?1:0)]);
	}
	//faces[31].vertices.reverse();
	
	//fill out temperate hexes
	for(i=0;i<10;i++){
		//j = i%10;
		f1 = faces[i];
		f1.vertices.push(faces[(i+9)%10+10].vertices[4]);
		f1.vertices.push(faces[(i+9)%10+10].vertices[3]);
		makeAdjacent(f1,faces[(i+9)%10+10]);
		f1.vertices.push(faces[(i+11)%10+10].vertices[0]);
		f1.vertices.push(faces[(i+11)%10+10].vertices[4]);
		makeAdjacent(f1,faces[(i+11)%10+10]);
		if(i%2==1){
			f1.vertices.push(faces[30].vertices[int(i/2+1)%5]);
			f1.vertices.push(faces[30].vertices[int(i/2)%5]);
			makeAdjacent(f1,faces[30]);
		}else{
			f1.vertices.push(faces[31].vertices[int(i/2)%5]);
			f1.vertices.push(faces[31].vertices[int(i/2+4)%5]);
			makeAdjacent(f1,faces[31]);
		}
	}
	
	//fill out equitorial hexes
	for(i=20;i<30;i++){
		//j = i%10;
		f1 = faces[i];
		f1.vertices.push(faces[(i-9)%10+10].vertices[1]);
		f1.vertices.push(faces[(i-9)%10+10].vertices[0]);
		makeAdjacent(f1,faces[(i-9)%10+10]);
		f1.vertices.push(faces[(i-11)%10+10].vertices[3]);
		f1.vertices.push(faces[(i-11)%10+10].vertices[2]);
		makeAdjacent(f1,faces[(i-11)%10+10]);
		f1.vertices.push(faces[(i-10)%10+10].vertices[1]);
		f1.vertices.push(faces[(i-10)%10+10].vertices[2]);
		makeAdjacent(f1,faces[(i-10)%10+10]);
	}
	
	//post-processing
	for(i=0;i<faces.length;i++){
		f1 = faces[i];
		f1.center.normalize();
		if(!f1.center || f1.center.length==0) 
			f1.center = SphereView.toCartesian(f1.lat*Math.PI/180, f1.lon*Math.PI/180);
		if(f1.lat < 0)
			f1.vertices.reverse();
		f1.seedVertices = new Vector.<Vector3D>();
		for each(var pt:Vector3D in f1.vertices) f1.seedVertices.push(pt);
	}
	
}

//creates a vertex on p1, which points toward the center of p2
public function addPentVertex(p1:SphereShape, p2:SphereShape):void{
	if(!p1.center || p1.center.length==0) 
		p1.center = SphereView.toCartesian(p1.lat*Math.PI/180, p1.lon*Math.PI/180);
	if(!p2.center || p2.center.length==0) 
		p2.center = SphereView.toCartesian(p2.lat*Math.PI/180, p2.lon*Math.PI/180);
	
	var diff:Vector3D = p2.center.subtract(p1.center);
	var newVert:Vector3D;
	p1.vertices.push((newVert=new Vector3D(p1.center.x+diff.x/3,p1.center.y+diff.y/3,p1.center.z+diff.z/3)));
	newVert.normalize();
	if(Math.abs(p2.lat)>85){
		p2.vertices.push((newVert=new Vector3D(p2.center.x-diff.x/3,p2.center.y-diff.y/3,p2.center.z-diff.z/3)));
		newVert.normalize();
	}	
}

public function makeAdjacent(p1:SphereShape,p2:SphereShape):void{
	if(p1.adjacentShapes.indexOf(p2)!=-1)
		p1.adjacentShapes.push(p2);
	if(!p2.adjacentShapes.indexOf(p1)!=-1)
		p1.adjacentShapes.push(p1);
}

public function findContainingFace(surfacePoint:Vector3D):int{
	var ind:int;
	var tVect:Vector3D;
	var shortest:Number = 200000;
	var tempDist:Number;
	//trace("pointer position: "+pointer3D.x+", "+pointer3D.y+", "+pointer3D.z);
	for(var i:int=0;i<faces.length;i++){
		//trace("hover near center: "+net.curvedTiles[i].center);
		tVect = surfacePoint.subtract(faces[i].center);
		tempDist = tVect.length;
		if(faces[i].type == "pent") tempDist *= PENT_RATIO;
		if(tempDist < shortest){
			shortest = tempDist;
			ind = i;
		}
	}
	return ind;
}

public function validateFaces():void{
	var lastCentralAngle:Number=0;
	var lastSurfaceAngle:Number=0;
	var lastDist:Number=0;
	
	//var i:int=30;
	for(var i:int=0;i<faces.length;i++){
		var face:SphereShape = faces[i];
		var firstvert:Vector3D = face.vertices[0];
		var ang1:Number = Vector3D.angleBetween(face.center,firstvert);
		if(Math.abs(ang1 - lastCentralAngle) > .01){
			lastCentralAngle = ang1;
			trace("central angle:"+(lastCentralAngle*180/Math.PI)+" at index:"+i);
		}
		//var diff1:Vector3D = face.vertices[face.vertices.length-1].subtract(firstvert);
		for(var j:int=0;j<face.vertices.length;j++){
			var diff1:Vector3D = face.vertices[(j+1)%face.vertices.length].subtract(face.vertices[j]);
			var diff2:Vector3D = face.vertices[(j-1+face.vertices.length)%face.vertices.length].
				subtract(face.vertices[j]);
			var ang2:Number = Vector3D.angleBetween(diff1,diff2);
			var dist:Number = diff1.length;
			if(diff1.crossProduct(diff2).dotProduct(face.center) < 0)
				trace("clockwise polygon *** at:"+" at index:"+i+","+j);
			if(Math.abs(ang2 - lastSurfaceAngle) > .01){
				lastSurfaceAngle = ang2;
				trace("surface angle:"+(lastSurfaceAngle*180/Math.PI)+" at index:"+i+","+j);
			}
			if(Math.abs(lastDist - dist) > .001){
				lastDist = dist;
				trace("surface distance:"+dist+" at index:"+i+","+j);
			}
		}
		
	}
}

public function TruncatedIcosahedron(){
	init();
}
	


}}