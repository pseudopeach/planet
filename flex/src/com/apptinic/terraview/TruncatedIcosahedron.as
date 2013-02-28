package com.apptinic.terraview{
	import flash.geom.Vector3D;

public class TruncatedIcosahedron{
	
public var magicLats:Array = [90.0, 52.6226318593503, 26.565051177078, 10.8123169635717];
public var faces:Array = new Array();

public function init():void{
	var v:Vector3D = toCartesian(.5, 1);
	var v2:Vector3D = new Vector3D(1,2,3);
	var v3 = v2.subtract(v);
	var o = toSpherical(v);
	trace("output "+o.lat+","+o.lon);
	var m:int = 1;
	trace("int math:"+((m/2)%2));
	pele();
	validateFaces();
}

public function pele():void{
	var f1:Object;
	var i:int;
	var j:int;
	faces = new Array();
	for(i=1;i<magicLats.length;i++){
		for(j=0;j<10;j++){
			faces.push( f1={lat:magicLats[i], lon:36.0*j, type:"hex", vertices: new Array(), cart:new Vector3D()} );
			if(j%2==0) f1.lat *= -1;
			if(i==2){ f1.type = "pent";f1.lat *= -1;}
		}
	}
	faces.push({lat:90.0, lon:0.0, type:"pent", vertices: new Array()});
	faces.push({lat:-90.0, lon:0.0, type:"pent", vertices: new Array()});
	
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
	
	for(i=20;i<30;i++){
		//j = i%10;
		f1 = faces[i];
		f1.vertices.push(faces[(i-9)%10+10].vertices[1]);
		f1.vertices.push(faces[(i-9)%10+10].vertices[0]);
		f1.vertices.push(faces[(i-11)%10+10].vertices[3]);
		f1.vertices.push(faces[(i-11)%10+10].vertices[2]);
		f1.vertices.push(faces[(i-10)%10+10].vertices[1]);
		f1.vertices.push(faces[(i-10)%10+10].vertices[2]);
	}
	
	for(i=0;i<10;i++){
		//j = i%10;
		f1 = faces[i];
		f1.vertices.push(faces[(i+9)%10+10].vertices[4]);
		f1.vertices.push(faces[(i+9)%10+10].vertices[3]);
		f1.vertices.push(faces[(i+11)%10+10].vertices[0]);
		f1.vertices.push(faces[(i+11)%10+10].vertices[4]);
		if(i%2==1){
			f1.vertices.push(faces[30].vertices[int(i/2+1)%5]);
			f1.vertices.push(faces[30].vertices[int(i/2)%5]);
		}else{
			f1.vertices.push(faces[31].vertices[int(i/2)%5]);
			f1.vertices.push(faces[31].vertices[int(i/2+4)%5]);
		}
	}
	
	for(i=0;i<faces.length;i++){
		f1 = faces[i];
		if(!f1.cart || f1.cart.length==0) 
			f1.cart = toCartesian(f1.lat*Math.PI/180, f1.lon*Math.PI/180);
		if(f1.lat < 0)
			f1.vertices.reverse();
	}
	
}
public function addPentVertex(p1:Object, p2:Object):void{
	if(!p1.cart || p1.cart.length==0) 
		p1.cart = toCartesian(p1.lat*Math.PI/180, p1.lon*Math.PI/180);
	if(!p2.cart || p2.cart.length==0) 
		p2.cart = toCartesian(p2.lat*Math.PI/180, p2.lon*Math.PI/180);
	
	var diff:Vector3D = p2.cart.subtract(p1.cart);
	var newVert:Vector3D;
	p1.vertices.push((newVert=new Vector3D(p1.cart.x+diff.x/3,p1.cart.y+diff.y/3,p1.cart.z+diff.z/3)));
	newVert.normalize();
	if(Math.abs(p2.lat)>85){
		p2.vertices.push((newVert=new Vector3D(p2.cart.x-diff.x/3,p2.cart.y-diff.y/3,p2.cart.z-diff.z/3)));
		newVert.normalize();
	}
	
}

public function toCartesian(lat:Number, lon:Number, radius:Number=1.0):Vector3D{
	//var latr:Number = lat/180*Math.PI;
	//var lonr:Number = lon/180*Math.PI;
	var out:Vector3D = new Vector3D();
	out.x = radius*Math.cos(lat)*Math.sin(lon);
	out.y = -radius*Math.sin(lat);
	out.z = -radius*Math.cos(lat)*Math.cos(lon);
	return out;
}

public function toSpherical(v:Vector3D):Object{
	var out:Object = {lat:0.0, lon:0.0};
	var len:Number = v.length;
	out.lat = -Math.asin(v.y/len);
	out.lon = Math.atan2(v.x,-v.z);
	return out;
}

public function validateFaces():void{
	var lastCentralAngle:Number=0;
	var lastSurfaceAngle:Number=0;
	var lastDist:Number=0;
	
	//var i:int=30;
	for(var i:int=0;i<faces.length;i++){
		var face:Object = faces[i];
		var firstvert:Vector3D = face.vertices[0];
		var ang1:Number = Vector3D.angleBetween(face.cart,firstvert);
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
			if(diff1.crossProduct(diff2).dotProduct(face.cart) < 0)
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
	
}
	


}}