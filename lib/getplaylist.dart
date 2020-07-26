import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class playlist {

  Future<String> get directory async {
    var dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<File> playfile(String playlistfile) async {
    final file = await directory;
    return File("$file/$playlistfile.txt");
  }

  Future writefile(List<Map<dynamic, dynamic>> data,String playlistfile) async{
    try{
      final file = await playfile(playlistfile);
      String tojson = jsonEncode(data);
      print("tojson: $tojson");
      await file.writeAsString(tojson);
    }catch(e){
      print("errorwritting: #e");
    }
  }

  Future<List<Map<dynamic, dynamic>>> readfile(String playlistfile) async {
    try {
      final file = await playfile(playlistfile);
      String fromjson;
      await file.readAsString().then((value) => fromjson = value);
      print("fromjson: $fromjson");
      List<Map<dynamic, dynamic>> datastored = List<Map<dynamic, dynamic>>.from(
          jsonDecode(fromjson));
      print("final string: $datastored");
      return datastored;
    } catch (e) {
      List<Map<dynamic, dynamic>> helo = List();
      print("error: $e");
      return helo;
    }
  }
  Future<int> deleteFile(String deleteFile) async {
    try {
      final file = await playfile(deleteFile);

      await file.delete();
    } catch (e) {
      print("errordeleting: $e");
      return 0;
    }
  }
}


class allplaylist {

  Future<String> get directory async {
    var dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<File> get playfile async {
    final file = await directory;
    return File("$file/thiscontainsallplaylistfile.json");
  }

  Future writefile(List<String> data) async{
    try{
      final file = await playfile;
      String tojson = jsonEncode(data);
      print("tojson: $tojson");
      await file.writeAsString(tojson);
    }catch(e){
      print("errorwritting: $e");
    }
  }

  Future<List<String>> readfile() async {
    try {
      final file = await playfile;
      String fromjson;
      await file.readAsString().then((value) => fromjson = value);
      print("fromjson: $fromjson");
      List<String> datastored = List<String>.from(
          jsonDecode(fromjson));
      print("final string: $datastored");
      return datastored;
    } catch (e) {
      List<String> helo = List();
      print("error: $e");
      return helo;
    }
  }

}