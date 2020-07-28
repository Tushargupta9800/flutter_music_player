import 'dart:async';
import 'package:flutter/material.dart';

class splashscreen extends StatefulWidget {
  @override
  _splashscreenState createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 2500), () {
      Navigator.of(context).pop(true);
      Navigator.pushNamed(context, "/home");}
      );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("asset/applogo.png",width: MediaQuery.of(context).size.width - 100,),
            Text("Feel Music - Tushar Gupta",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              fontFamily: "headline"
            ),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("asset/logo.png",scale: 3,),
                Image.asset("asset/logo.png",scale: 3,),
                Image.asset("asset/logo.png",scale: 3,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text("-Version: 2.1.0",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        fontFamily: "headline"
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    ),);
  }
}
