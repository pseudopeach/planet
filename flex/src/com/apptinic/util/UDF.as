package com.apptinic.util{

import flash.geom.Vector3D;
import flash.utils.describeType;

import mx.collections.ArrayCollection;
import mx.collections.IList;


public class UDF{
public function UDF(){
	
}

public static function underToCamel(input:String, capFirst:Boolean=false):String{
	var ar:Array = input.split("_");
	var output:String = capFirst ? (ar[i] as String).charAt(0).toUpperCase() : ar[0];
	for(var i:int=1;i<ar.length;i++)
		output += (ar[i] as String).charAt(0).toUpperCase() + ar[i].substr(1);
	return output;
}
public static function camelToUnder(input:String):String{
	var ar:Array = input.split(/[A-Z]/);
	var output:String = input.substr(0,ar[0].length).toLowerCase();
	for(var i:int=1;i<ar.length;i++)
		output += "_"+input.substr(output.length,ar[i].length);
	return output;
}

public static function dumpObject(Obj:Object):void{
	for(var prop:String in Obj)
		trace(prop+": "+Obj[prop]);
}
public static var exemptNames:Array = ["source","uid","list","object","flexId"];
public static var terminalTypes:Array = ["int","Number","Boolean","String", "Date"];

public static function deepTrace(o1:*, addressStr:String="{root}",collectionAddStr:String=null):String { 
	//returns a set of actionscript commands that will recreate o1
	
	var classInfo1:XML = describeType(o1);
	//var itemName:String;
	var a:XML;
	var s:String = "";
	var str:String = "";
	var propNames:Array;
	var i:int;
	
	if(!o1) return str;
	
	if(terminalTypes.indexOf(classInfo1.@name.toString()) != -1) {
		//o1 is a terminal (primitive) object
		trace(addressStr+"= "+o1);
		
		str = "\n"+ (collectionAddStr ? collectionAddStr : addressStr+" = ");
		if(o1 as String)
			str += "'"+o1.toString()+"'"
		else if(o1 as Date)
			str += "new Date("+o1.fullYear+","+o1.month+","+o1.date+")";
		else
			str += o1.toString()+"";
		str += collectionAddStr ? ");" : ";";
		return str;
	}
	
	if((o1 as IList || o1 as Array)){
		//collection object
		str += "\n"+ addressStr + " = new " + classInfo1.@name+"();"
		var collStr:String = classInfo1.@name.toString() == "Array" ? ".push(" : ".addItem(";
		collStr = addressStr+collStr;
		for(i=0;i<o1.length;i++){
			str += deepTrace(o1[i], addressStr+"["+i+"]",collStr);
		}
	}else{
		//non-terminal object with properties
		str += "\n" + (collectionAddStr ? collectionAddStr : addressStr + " = ");
		str += " new "+ classInfo1.@name+"()"
		str += collectionAddStr ? ");" : ";";
		propNames = new Array();
		for each (a in classInfo1..variable) 
		propNames.push(a.@name);
		
		for(s in o1)
			propNames.push(s);
		
		for each (a in classInfo1..accessor) 
		propNames.push(a.@name);
		
		for(i=0;i<propNames.length;i++){
			if(exemptNames.indexOf(propNames[i]) != -1) continue;
			str += deepTrace(o1[propNames[i]], addressStr+"."+propNames[i]);
			
		}
	}
	return str;	
}

public static function diffObjects(o1:*, o2:*, addressStr:String="{root}"):ArrayCollection { 
	//trace("diffobject: "+addressStr);
	
	if(!o1 && !o2) return null;
	
	var output:ArrayCollection;
	var result:ArrayCollection;
	var classInfo1:XML = describeType(o1);
	var classInfo2:XML = describeType(o2);
	//var itemName:String;
	var a:XML;
	var s:String;
	var propNames:Array;
	var i:int;
	
	//if objects are identical, go no further
	if(o1 == o2) return output;
	
	//if objects are terminal types, directly compare them
	if(!o1 || !o2 || terminalTypes.indexOf(classInfo1.@name.toString()) != -1 || 
		terminalTypes.indexOf(classInfo2.@name.toString()) != -1) {
		return new ArrayCollection([{address:addressStr, valA:o1, valB:o2, type:"simple"}]);
	}
	
	output = new ArrayCollection();
	
	if((o1 as IList || o1 as Array) && (o2 as IList || o2 as Array)){
		//if both objects are collections
		//trace("collection inspection: "+addressStr);
		if(o1.length != o2.length) //if length missmatch, report lengths and abandon this liniage
			return new ArrayCollection([{address:addressStr, lengthA:o1.length, lengthB:o2.length, type:"length"}]);
		else //if lengths match, compare each item in the collections
			for(i=0;i<o1.length;i++){
				result = diffObjects(o1[i], o2[i], addressStr+"["+i+"]");
				if(result)
					output.addAll(result);
			}
	}else{
		//collect all property names ....
		
		propNames = new Array();
		for each (a in classInfo1..variable) 
		propNames.push(a.@name);
		
		for each (a in classInfo2..variable) 
		if(!o1.hasOwnProperty(a.@name))
			propNames.push(a.@name);
		
		for(s in o1)
			propNames.push(s);
		
		for(s in o2)
			if(!o1.hasOwnProperty(s))
				propNames.push(s);
		
		for each (a in classInfo1..accessor) 
		propNames.push(a.@name.toString());
		
		for each (a in classInfo2..accessor) 
		if(!o1.hasOwnProperty(a.@name.toString()))
			propNames.push(a.@name.toString());
		
		for(i=0;i<propNames.length;i++){
			if(exemptNames.indexOf(propNames[i]) != -1) continue;
			result = diffObjects(o1[propNames[i]], o2[propNames[i]], addressStr+"."+propNames[i]);
			if(result)
				output.addAll(result);
		}
	}
	return output;	
}

public static function encodeLine(points:Array):String {
	var out:String = "";
	
	var lastLat:Number = 0;
	var lastLon:Number = 0;
	
	for each(var point:Object in points){
		out += encodeNumber(Math.round((point.lat-lastLat)*1e5));
		out += encodeNumber(Math.round((point.lon-lastLon)*1e5));
		lastLat = point.lat;
		lastLon = point.lon;
	}
	return out;
}

public static function encodeNumber(n:int):String {
	var out:String = "";
	var bits:int = n << 1;
	if(n < 0)
		bits = ~bits;
	while(bits >= 0x20) {
		out += (String.fromCharCode((0x20 | (bits & 0x1f)) + 63));
		bits >>= 5;
	}
	out += String.fromCharCode(bits + 63);
	return out;
}

public static function decodeLine(encoded:String):Array {
	var len:uint = encoded.length;
	var index:int = 0;
	var out:Array = [];
	var lat:Number = 0;
	var lon:Number = 0;
	var dc:Number;
	while (index < len) {
		var b:int;
		var shift:int = 0;
		var result:int = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		dc = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dc;
		shift = 0;
		result = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		dc = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lon += dc;
		out.push({lat:(lat*1e-5), lon:(lon*1e-5)});
	}
	return out;
}

public static function monthName(m:Number):String{
	if(m == 0)
		return "January";
	else if(m==1)
		return "February";
	else if(m==2)
		return "March";
	else if(m==3)
		return "April";
	else if(m==4)
		return "May";
	else if(m==5)
		return "June";
	else if(m==6)
		return "July";
	else if(m==7)
		return "August";
	else if(m==8)
		return "September";
	else if(m==9)
		return "October";
	else if(m==10)
		return "November";
	else if(m==11)
		return "December";
	else
		return "Fictituary";
}

public static function trimString(str:String):String{
	if(!str) return "";
	str = str.replace(/^\s+/,"");
	str = str.replace(/\s+$/,"");
	return str;
}

public static function interpolateColor(colorBegin:uint,colorEnd:uint,percent:Number):uint{
	var red1:Number = colorBegin >> 16;
	var green1:Number = colorBegin >> 8 & 255;
	var blue1:Number = colorBegin & 255;
	
	var delr:int = percent*((colorEnd>>16) - red1);
	var delg:int = percent*((colorEnd>>8 & 255) - green1);
	var delb:int = percent*((colorEnd & 255) - blue1);
	
	var red:uint = red1 + percent*((colorEnd>>16) - red1);
	var green:uint = green1 + percent*((colorEnd>>8 & 255) - green1);
	var blue:uint = blue1 + percent*((colorEnd & 255) - blue1);
	
	return red<<16|green<<8|blue;
}



public static function linearCombine(v1:Vector3D,v1Scale:Number,v2:Vector3D,v2Scale:Number):Vector3D{
	return new Vector3D(
		v1.x*v1Scale + v2.x*v2Scale,
		v1.y*v1Scale + v2.y*v2Scale,
		v1.z*v1Scale + v2.z*v2Scale
	);
}

}}