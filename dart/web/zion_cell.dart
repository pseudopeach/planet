import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'dart:math';

class ZionCell extends WebComponent {
  
String renderedFor = "";
num contentPadding = 30;

void inserted(){
  window.onResize.listen((e)=>draw());
  host.style.position = "relative";
  draw();
}

void draw(){
  Rect box = host.client;
  
  String dim = "${box.width} x ${box.height}";
  if(dim == renderedFor) return;
  
  CanvasElement canv = query("canvas");
  if(canv==null) {print("sad time");return;}
  CanvasRenderingContext2D cg = canv.context2D;
  
  canv.width = box.width;
  canv.height = box.height;
  
  setLineProps(cg);
  setFillProps(cg);
  setFilterProps(cg);
  
  drawPath(cg, box.width, box.height);
  
  cg.stroke();
  cg.fill();
  
  print("drew $dim");
  renderedFor = dim;
}

void setLineProps(CanvasRenderingContext2D cg){
  cg.strokeStyle = 'rgba(0,130,166,1.0)';
  cg.lineWidth = 4;
}

void setFillProps(CanvasRenderingContext2D cg){
  cg.fillStyle = 'rgba(0,130,166,.25)';
}

void setFilterProps(CanvasRenderingContext2D cg){
  cg.shadowColor = 'rgba(0,130,166,.50)';
  cg.shadowBlur = 30;
  cg.shadowOffsetX = 0;
  cg.shadowOffsetY = 0;
}

void drawPath(CanvasRenderingContext2D cg, num width, num height){
  //m 10 0 l 30 0 l 0 20 l -10 10 l -30 0 l 0 -20 l 10 -10
  //cg.moveTo(10,0); lineTo( 30, 0); lineTo( 0, 20); lineTo( -10, 10); lineTo( -30, 0); lineTo( 0, -20); lineTo( 10, -10);
  final num cut = 1/3;
  final num padd = contentPadding;
  num top = padd;
  num right = width-padd;
  num bott = height-padd ;
  num left = padd;
  num lCut = (min(right-left,bott-top)*cut).floor();
  
  cg.moveTo(right-lCut, top);
  cg.lineTo(right,top);
  cg.lineTo(right,bott-lCut);
  cg.lineTo(right-lCut, bott);
  cg.lineTo(left, bott);
  cg.lineTo(left, top+lCut);
  cg.lineTo(left+lCut, top);
  cg.lineTo(right-lCut, top);
}

}
