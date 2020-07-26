import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'homescreen.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Splash(),
    routes: routes,
  ));
}

var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => Home(),
};

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return splashscreen();
  }
}


