import 'package:flutter/material.dart';

Widget Head(context){
  return Flexible(
    flex: 10,
    fit: FlexFit.tight,
    child: Container(
      width: MediaQuery.of(context).size.width - 10.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset("asset/logo.png",
            scale: 5.0,
            color: Colors.white,
          ),
          Text("Feel Music",
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
              fontFamily: "headline",
            ),),
          Image.asset("asset/logo.png",
            scale: 5.0,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}

Widget Space() => Flexible(flex: 1,fit: FlexFit.tight, child: Container());

Time(Duration duration){
  String time = "";
  String temp ="";
  double inttime = duration.inSeconds.toDouble();
  temp = ((inttime/(60*60)).toInt()).toString();
  if(temp != '0'){
    time = temp;
    time += ":";
  }
  inttime %= (60*60);
  time += ((inttime/60).toInt()).toString();
  time += ":";
  inttime %= 60;
  time += (inttime.toInt()).toString();
  return time;
}

Widget Ok(context){
  return new GestureDetector(
    onTap: () => Navigator.of(context).pop(false),
    child: Container(
      width: 30.0,
      height: 30.0,
      color: Colors.grey[600],
      child: Center(
        child: Text("Ok"),
      ),
    ),
  );
}

Widget letmeexit(){
  return Container(
  width: 80.0,
  height: 30.0,
  color: Colors.grey[600],
  child: Center(
  child: Text("Let me exit"),
  ),
  );
}

BoxDecoration circle = BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular((25.0))));
BoxDecoration thirty = BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular((30.0))));
BoxDecoration whitethirty = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular((30.0))));
BoxDecoration sixty = BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular((60.0))));
BoxDecoration whitesixty = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular((60.0))));
BoxDecoration greysixty = BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.all(Radius.circular((60.0))));
BoxDecoration grey10900 = BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.all(Radius.circular((10.0))));
