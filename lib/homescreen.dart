import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:deepmusicfinder/deepmusicfinder.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'head.dart';
import 'getplaylist.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{
  List<Map<dynamic, dynamic>> songsList = [];
  List<Map<dynamic, dynamic>> tempsongsList = [];
  List<Map<dynamic, dynamic>> choosensongsList = [];
  List<Map<dynamic, dynamic>> playlistsongsList = [];
  Deepmusicfinder musicfinder;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer nomusic = AudioPlayer();
  bool isplaying = false;
  int playingindex = -1;
  bool weedit = false;
  bool ispause = false;
  Duration current = Duration();
  Duration complete = Duration();
  bool isnotfirst = false;
  bool playrandom = false;
  TabController controller;
  bool createplaylist = false;
  playlist Playlistfile = playlist();
  allplaylist Allplaylist = allplaylist();
  List<String> PlaylistString = List();
  String whichplaylist = "AllSongs";
  String playingplaylist = "AllSongs";
  bool textfield = false;
  bool didweedit = false;
  bool repeat = false;
  TextEditingController txtcontroller = TextEditingController();
  bool isplayingnextsong = false;

  void getPermission() async {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((checkPermissionStatus) async {
      if (checkPermissionStatus == PermissionStatus.granted) {
        try {
          dynamic result = await musicfinder.fetchSong;
          if (result["error"] == true) {print(result["errorMsg"]); return;}
          setState(() {songsList = List.from(result["songs"]);
          playlistsongsList.addAll(songsList);
          });
        } catch (e) {print(e);}
      } else {
        PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
                (reqPermissions) async {
              if (reqPermissions[PermissionGroup.storage] ==
                  PermissionStatus.granted) {
                try {
                  dynamic result = await musicfinder.fetchSong;
                  if (result["error"] == true) {print(result["errorMsg"]); return;}
                  setState(() {songsList = List.from(result["songs"]); playlistsongsList.addAll(songsList);});
                } on PlatformException {print("Error");}
              }
            });
      }
    });
  }

  void getPermissionagain() async {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((checkPermissionStatus) async {
      if (checkPermissionStatus == PermissionStatus.granted) {
        try {
          dynamic result = await musicfinder.fetchSong;
          if (result["error"] == true) {print(result["errorMsg"]); return;}
          setState(() {
            tempsongsList = [];
            tempsongsList = List.from(result["songs"]);
          });
        } catch (e) {print(e);}
      } else {
        PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
                (reqPermissions) async {
              if (reqPermissions[PermissionGroup.storage] ==
                  PermissionStatus.granted) {
                try {
                  dynamic result = await musicfinder.fetchSong;
                  if (result["error"] == true) {print(result["errorMsg"]); return;}
                  setState(() {
                    tempsongsList = [];
                    tempsongsList = List.from(result["songs"]);});
                } on PlatformException {print("Error");}
              }
            });
      }
    });
  }

  loadplaylist() async {
    PlaylistString = [];
    await Allplaylist.readfile().then((value) => PlaylistString = value);
    bool isthere = false;
    for(String i in PlaylistString){
      if(i == "AllSongs"){isthere = true;}
    }
    if(!isthere){
      print("something");
      PlaylistString.add("AllSongs");
      await Allplaylist.writefile(PlaylistString);
      PlaylistString = [];
      await Allplaylist.readfile().then((value) => PlaylistString = value);
    }
    print(PlaylistString.length);
    setState(() {});
  }

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
    musicfinder = new Deepmusicfinder();
    this.getPermission();
    this.getPermissionagain();
    nomusic.play("http://www.minidisc.org/charman/1sec.mp3",stayAwake: true);
    nomusic.completionHandler = () {setState(() {
      print("here");
      nomusic.play("http://www.minidisc.org/charman/1sec.mp3", stayAwake: true);
      audioPlayer.completionHandler = () {print("where"); setState(() {forward();});};});
      audioPlayer.positionHandler = (p) => {
        audioPlayer.durationHandler = (d) => {if(d.inMilliseconds - p.inMilliseconds <= 700){forward(),}}};};
    audioPlayer.durationHandler = (d) => setState(() {complete = d;});
    audioPlayer.positionHandler = (p) => setState(() {current = p;});
    audioPlayer.completionHandler = () {setState(() {getnextsong();});};
    MediaNotification.setListener('pause', () {setState(() {audioPlayer.pause(); ispause = true;});});
    MediaNotification.setListener('play', () {setState(() {audioPlayer.resume(); ispause = false;});});
    MediaNotification.setListener('next', () {forward();});
    MediaNotification.setListener('prev', () {back();});
    MediaNotification.setListener('select', () {setState(() {});});
    loadplaylist();
  }

  Widget buildLeading(img,int index,bool isit) {
    if (img == null) {return ClipOval(child: Icon(Icons.music_note,color: (playingindex != index || isit)?Colors.white:Colors.black,size: 50.0,));}
    if (img == "unknown") {return ClipOval(child: Icon(Icons.music_note,color: (playingindex != index || isit)?Colors.white:Colors.black,size: 50.0,));}
    File pic = new File.fromUri(Uri.parse(img));
    return ClipOval(child: Image.file(pic, height: 50.0, width: 50.0),);
  }

  play(int index) async {
    shownotification(index,true);
    try {isplaying? await audioPlayer.play(playlistsongsList[index]['path'], isLocal: true,stayAwake: true): await audioPlayer.stop();}
    catch (err) {print(err);}
  }

  shownotification(int index,bool what){
    MediaNotification.showNotification(
      title: playlistsongsList[index]["Title"],
      isPlaying: what,
    );
  }

  Widget songBuilder(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 9,
              child: Row(
                children: [
                  Flexible(
                    child: Text(playlistsongsList[index]["Title"],
                      style: TextStyle(
                        color: (playingindex == index)?Colors.black:Colors.white,
                      ),),
                  ),
                ],
              ),
            ),
            Flexible(flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  (playingindex == index && ispause)?Icon(Icons.play_circle_outline,color: Colors.black,):Container(),
                  (playingindex == index && !ispause)?Icon(Icons.pause_circle_outline,color: Colors.black,):Container(),
                ],
              ),
            ),
          ],
        ),
        leading: buildLeading(playlistsongsList[index]["Image"],index,false),
        onTap: () {
           setState(() {
            ispause = false;
            if(playingindex == index){ playingindex = -1; isplaying = false; audioPlayer.stop(); shownotification(index,false);}
            else{ isplaying = true; this.play(index); playingindex = index; shownotification(index,true);}
          });
        },
      ),
      decoration: (playingindex == index)?whitesixty:sixty,
    );
  }

  getchoosenplaylistsongs() async {
    choosensongsList = [];
    await Playlistfile.readfile(whichplaylist).then((value) => choosensongsList.addAll(value));
  }

  Widget playlistbuilder(BuildContext context,int index){
    return Container(
      decoration: greysixty,
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(top: 2.0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            (PlaylistString[index] != "AllSongs")?GestureDetector(
              onTap: () async {
                await Playlistfile.deleteFile(PlaylistString[index]);
                PlaylistString.remove(PlaylistString[index]);
                await Allplaylist.writefile(PlaylistString);
                PlaylistString = [];
                await Allplaylist.readfile().then((value) => PlaylistString.addAll(value));
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.only(right: 25.0),
                child: Icon(Icons.delete),
              ),
            ):Container(),
            RaisedButton(
              color: Colors.grey[600],
              onPressed: () async {
                if(PlaylistString[index] == "AllSongs"){
                  playingindex = -1; isplaying = false; audioPlayer.stop();
                  playingplaylist = "AllSongs";
                  playlistsongsList = [];
                  playlistsongsList.addAll(songsList);
                  MediaNotification.hideNotification();
                }
               else {
                  whichplaylist = PlaylistString[index];
                  await getchoosenplaylistsongs();
                  createplaylist = !createplaylist;
                }
                setState(() {
                  weedit = false;
                });
              },
              child: Text(PlaylistString[index],style: TextStyle(
                fontSize: 30.0,
                color: Colors.white
              ),),
            ),

            (playingplaylist == PlaylistString[index])?Container(
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(Icons.forward),
            ):Container(),
          ],
        ),
      ),
    );
  }

  Widget songBuildertwo(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  Flexible(
                    child: Text(tempsongsList[index]["Title"],
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                  ),
                ],
              ),
            ),
            Flexible(flex: 3,
              fit: FlexFit.tight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
              decoration: greysixty,
                    child: IconButton(icon: Icon(Icons.remove,color: Colors.white,size: 35.0,), onPressed: () {
                      setState(() {
                        tempsongsList.removeAt(index);
                      });
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
        leading: buildLeading(tempsongsList[index]["Image"],index,false),
      ),
      decoration: sixty,
    );
  }

  Widget songBuilderthree(BuildContext context, int index){

    return Container(
      width: MediaQuery.of(context).size.width - 90,
      margin: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  Flexible(
                    child: Text(choosensongsList[index]["Title"],
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: buildLeading(choosensongsList[index]["Image"],index,false),
      ),
      decoration: sixty,
    );
  }

  Widget slider() {
    if(isplayingnextsong){
      setState(() {
        Duration dur = complete - complete;
        audioPlayer.seek(dur);
      });
    }
    return (!isplayingnextsong)?Slider(
        activeColor: Colors.grey[500],
        inactiveColor: Colors.white,
        value: current.inSeconds.toDouble(),
        min: 0.0,
        max: complete.inSeconds.toDouble(),
        onChanged: (double value){
          if(value >= complete.inSeconds.toDouble()){
             value = complete.inSeconds.toDouble() - 1;
          }
          setState(() {
            value = value;
            audioPlayer.seek(Duration(seconds: value.toInt()));
          });
        }):Container();
  }

  getnextsong(){
    if(isnotfirst == false && current.inSeconds >= 1 && current.inSeconds <= 5){
      isnotfirst = true;
    }
    else if(isnotfirst == false && current.inSeconds >= 1){
      setState(() {
        audioPlayer.seek(Duration(seconds: 0));
      });
    }
    if(isplayingnextsong == true){
      setState(() {
        isplayingnextsong = false;
      });
    }
    if(current.inMilliseconds.toDouble() >= complete.inMilliseconds.toDouble() - 700 && isnotfirst){
      setState(() {
        isnotfirst = false;
        isplayingnextsong = true;
        ispause = false;
        if(repeat){
          audioPlayer.play(playlistsongsList[playingindex]['path'], isLocal: true,stayAwake: true);
        }
        else if(playrandom){
          var tempplayingindex = Random().nextInt(playlistsongsList.length);
          while(tempplayingindex == playingindex){
            tempplayingindex = Random().nextInt(playlistsongsList.length);
          }
          playingindex = tempplayingindex;
          audioPlayer.play(playlistsongsList[playingindex]['path'], isLocal: true,stayAwake: true);
        }
        else {
          playingindex ++;
          if (playingindex > playlistsongsList.length - 1) {
            playingindex = 0;
          }
          audioPlayer.play(playlistsongsList[playingindex]['path'], isLocal: true,stayAwake: true);
        }
      });
    }
    shownotification(playingindex, true);
    return Container();
  }

  forward(){
    shownotification(playingindex, true);
    ispause = false;
    if(playrandom){
      var tempplayingindex = Random().nextInt(playlistsongsList.length);
      while(tempplayingindex == playingindex){
        tempplayingindex = Random().nextInt(playlistsongsList.length);
      }
      playingindex = tempplayingindex;
      audioPlayer.play(playlistsongsList[playingindex]['path'], isLocal: true,stayAwake: true);
    }
    else {
      playingindex += 1;
      if (playingindex > playlistsongsList.length - 1) {
        playingindex = 0;
      }
      setState(() {
        audioPlayer.play(playlistsongsList[playingindex]["path"],
            isLocal: true,stayAwake: true);
      });
    }
    shownotification(playingindex, true);
  }

  back(){
    shownotification(playingindex, true);
    ispause = false;
    if(playrandom){

      var tempplayingindex = Random().nextInt(playlistsongsList.length);
      while(tempplayingindex == playingindex){
        tempplayingindex = Random().nextInt(playlistsongsList.length);
      }
      playingindex = tempplayingindex;
      print("playingindex: $playingindex");
      audioPlayer.play(playlistsongsList[playingindex]['path'], isLocal: true,stayAwake: true);
    }
    else {
      playingindex -= 1;
      if (playingindex < 0) {
        playingindex = playlistsongsList.length - 1;
      }
      setState(() {
        shownotification(playingindex, true);
        audioPlayer.play(playlistsongsList[playingindex]["path"],
            isLocal: true,stayAwake: true);
      });
    }
    shownotification(playingindex, true);
  }

  gettab(){
    return Flexible(flex: 22, fit: FlexFit.tight,child: Container(
      width: MediaQuery.of(context).size.width - 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildLeading(playlistsongsList[playingindex]["Image"],playingindex,true),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(playlistsongsList[playingindex]["Title"],
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: Colors.white,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(right: 40.0),
                width: MediaQuery.of(context).size.width - 120,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getnextsong(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if(playrandom && !repeat){
                            playrandom = false;
                          }
                          else if(!playrandom && !repeat){
                            repeat = true;
                          }
                          else if(repeat){
                            repeat = false;
                            playrandom = true;
                          }
                        });
                      },
                      child: Icon((!repeat)?Icons.shuffle:Icons.repeat_one, color: (playrandom)?Colors.yellowAccent:Colors.white,),
                    ),
                    (!ispause)?GestureDetector(
                        onTap: () {
                          ispause = false;
                          Duration dur = current - Duration(seconds: 10);
                          if(dur <= Duration(seconds: 0)){dur = Duration(seconds: 0);}
                          else audioPlayer.seek(dur);
                        },
                        child: Icon(Icons.replay_10,color: Colors.white,)):Container(),
                    GestureDetector(
                        onTap: () {
                          back();
                        },
                        child: Icon(Icons.fast_rewind,color: Colors.white,)),
                    GestureDetector(
                        onTap: () {
                          shownotification(playingindex,(ispause)?true:false);
                          if(ispause){audioPlayer.resume();}
                          if(!ispause){audioPlayer.pause();}
                          setState(() {ispause = !ispause;});
                        },
                        child: Icon((ispause)?Icons.play_arrow:Icons.pause,color: Colors.white,)),
                    GestureDetector(
                        onTap: () {
                          forward();
                        },
                        child: Icon(Icons.fast_forward,color: Colors.white,)),
                    (!ispause)?GestureDetector(
                        onTap: () {
                          ispause = false;
                          Duration dur = current + Duration(seconds: 10);
                          if(dur >= complete){dur = complete;}
                          else audioPlayer.seek(dur);
                        },
                        child: Icon(Icons.forward_10,color: Colors.white,)):Container(),
                  ],
                ),
              ),
              (!ispause)?Row(
                children: [
                  Text(Time(current), style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),),
                  slider(),
                  Text(Time(complete), style: TextStyle(fontWeight: FontWeight.w300,color: Colors.white),),
                ],
              ):Container(),
            ],
          ),
        ],
      ),
      decoration: thirty,
    ));
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure to exit?'),
        content: new Text('Press home button to play the music in background'),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Ok(context),
                new GestureDetector(
                  onTap: () {
                    audioPlayer.stop();
                    Navigator.of(context).pop(true);
                    },
                  child: letmeexit(),
                ),
              ],
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Widget Songs(){
    return Container(
      color: Colors.grey[600],
      child: Column(
        children: [
          Space(),
          Head(context),
          Space(),
          Flexible(
            flex: 80,
            fit: FlexFit.tight,
            child: Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.only(top: 25.0,bottom: 25.0),
              child: ListView.builder(
                itemBuilder: songBuilder,
                itemCount: (playingplaylist == "AllSongs")?songsList.length:choosensongsList.length,
              ),
              decoration: thirty,
            ),
          ),
          Space(),
          isplaying ? gettab(): Container(),
          isplaying ? Space() : Container(),
        ],
      ),
    );
  }

  Widget Playlist(){
    return Container(
      color: Colors.grey[600],
      child: Column(
        children: [
          Space(),
          Head(context),
          Space(),
          Flexible(
            flex: 20,
            fit:  FlexFit.tight,
            child: Container(
                width: MediaQuery.of(context).size.width - 20,
                child: (!createplaylist)?Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 10.0),),
                    Text("Playlists",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("asset/logo.png",color: Colors.white,width: 50.0,height: 30.0,),
                        Image.asset("asset/logo.png",color: Colors.white,width: 50.0,height: 30.0,),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        padding: EdgeInsets.only(top: 25.0,bottom: 2.0),
                        child: ListView.builder(
                          itemCount: PlaylistString.length,
                            itemBuilder: playlistbuilder
                        ),
                        decoration: thirty,
                      ),
                    ),
                    (!createplaylist)?(!textfield)?Center(
                      child: IconButton(icon: Icon(Icons.add_circle,color: Colors.white,size: 50.0,), onPressed: () {
                        setState(() {
                          textfield = !textfield;
                        });
                      }),
                    ):Container(
                      child: Column(
                        children: [
                          TextField(
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: "     Playlist name? (No space and no speacial characters)",
                              hintStyle: TextStyle(
                                fontSize: 10.0,
                              ),
                            ),
                            controller: txtcontroller,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Icon(Icons.done,color: Colors.black,size: 30.0,),
                                  onTap: () async {
                                  if(txtcontroller.text!= ""){
                                    PlaylistString.add(txtcontroller.text);
                                    await Allplaylist.writefile(PlaylistString);
                                    PlaylistString = [];
                                    await Allplaylist.readfile().then((value) => PlaylistString = value);
                                  }
                                  setState(() {
                                    textfield = !textfield;
                                  });
                                },
                              ),
                              SizedBox(width: 40.0,),
                              GestureDetector(
                                child: Icon(Icons.cancel,color: Colors.black,size: 30.0,),
                                onTap: (){
                                  setState(() {
                                    textfield = !textfield;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                        decoration: whitethirty,
                    ):Container(),
                    Padding(padding: EdgeInsets.only(bottom: 20.0)),
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                  decoration: grey10900,
                            child: GestureDetector(
                                child: Text(whichplaylist,style: TextStyle(color: Colors.white,fontSize: 40.0),),
                              onTap: () {
                                  setState(() {});
                              },
                            ),
                        ),
                        Container(
                          decoration: grey10900,
                          child: GestureDetector(
                            child: Icon(Icons.save,color: Colors.white,size: 30.0,),
                            onTap: () async {
                              if(didweedit){
                              choosensongsList = [];
                              choosensongsList.addAll(tempsongsList);
                              await Playlistfile.writefile(choosensongsList, whichplaylist);}
                              choosensongsList = [];
                              await Playlistfile.readfile(whichplaylist).then((value) => choosensongsList.addAll(value));
                              setState(() {
                                playlistsongsList = [];
                                playlistsongsList.addAll(choosensongsList);
                                createplaylist = !createplaylist;
                              });
                            },
                          ),
                        ),
                        Container(
                          decoration: grey10900,
                          child: GestureDetector(
                            child: Icon(Icons.play_circle_outline,color: Colors.white,size: 30.0,),
                            onTap: () async {
                              MediaNotification.hideNotification();
                              if(didweedit){
                              choosensongsList = [];
                              choosensongsList.addAll(tempsongsList);
                              await Playlistfile.writefile(choosensongsList, whichplaylist);}
                              choosensongsList = [];
                              await Playlistfile.readfile(whichplaylist).then((value) => choosensongsList.addAll(value));
                              setState(() {
                                playingindex = -1; isplaying = false; audioPlayer.stop();
                                playingplaylist = whichplaylist;
                                createplaylist = !createplaylist;
                                playlistsongsList = [];
                                playlistsongsList.addAll(choosensongsList);
                              });
                            },
                          ),
                        ),
                        Container(
                          decoration: grey10900,
                          child: GestureDetector(
                            child: Icon(Icons.edit,color: Colors.white,size: 30.0,),
                            onTap: () async {
                              if(!weedit){
                                await getPermissionagain();
                                choosensongsList = [];
                                await Playlistfile.writefile(choosensongsList, whichplaylist);
                              }else{
                                choosensongsList = [];
                                choosensongsList.addAll(tempsongsList);
                                await Playlistfile.writefile(choosensongsList, whichplaylist);
                                choosensongsList = [];
                                await Playlistfile.readfile(whichplaylist).then((value) => choosensongsList.addAll(value));
                              }
                              setState((){
                                didweedit = true;
                                weedit = !weedit;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                decoration: thirty,
            ),
          ),
          Space(),
          (createplaylist)?((weedit)?Flexible(
            flex: 80,
            fit: FlexFit.tight,
            child: Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.only(top: 25.0,bottom: 25.0),
              child: ListView.builder(
                itemBuilder: songBuildertwo,
                itemCount: tempsongsList.length,
              ),
              decoration: thirty,
            ),
          ):Flexible(
            flex: 80,
            fit: FlexFit.tight,
            child: Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.only(top: 25.0,bottom: 25.0),
              child: ListView.builder(
                itemBuilder: songBuilderthree,
                itemCount: choosensongsList.length,
              ),
              decoration: thirty,
            ),
          )):Container(),
          (createplaylist) ? Space(): Container(),
        ],

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Stack(
        children: [
          SafeArea(
            child: Scaffold(
              body: TabBarView(
                children: <Widget>[Songs(), Playlist()],
                controller: controller,
              ),
              bottomNavigationBar: Material(
                color: Colors.grey[600],
                child: TabBar(
                  tabs: <Tab>[
                    Tab(
                      child: Container(
                        width: 80.0,
                        height: 50.0,
                        child: Column(
                          children: [
                            Icon(Icons.queue_music),
                            Text("Songs"),
                          ],
                        ),
                        decoration: circle,
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: 80.0,
                        height: 50.0,
                        child: Column(
                          children: [
                            Icon(Icons.featured_play_list),
                            Text("Playlist"),
                          ],
                        ),
                        decoration: circle,
                      ),
                    ),
                  ],
                  controller: controller,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
