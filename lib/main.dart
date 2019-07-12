import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class LayoutObject {
  final String type;
  final Map<String, dynamic> args;

  LayoutObject({this.type, this.args});

  factory LayoutObject.fromJson(Map<String, dynamic> json) {
    return LayoutObject(
      type: json['type'],
      args: json['args']
    );
  }
}


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<LayoutObject> layout;

  @override
  void initState() {
    super.initState();
    layout = fetchLayout();
  }

  static LayoutObject _parseLayout(String body) {
    return LayoutObject.fromJson(json.decode(body));
  }

  Future<LayoutObject> fetchLayout() async {
    final response = await http.get('http://172.30.0.13:8000/test.json');

    if (response.statusCode == 200) {
      return compute(_parseLayout, response.body);
    } else {
      throw Exception('Failed to load layout');
    }
  }

  static Text makeTextObject(Map<String, dynamic> args) {
    return Text(args["data"]);
  }

  static Center makeCenterObject(Map<String, dynamic> args) {
    return Center(
      child: mapObject(LayoutObject.fromJson(args["child"])),
    );
  }

  static Widget mapObject(LayoutObject object) {
    Map<String, Function> objects = {
      "Text": makeTextObject,
      "Center": makeCenterObject
    };

    if (objects.containsKey(object.type)) {
      return objects[object.type](object.args);
    } else {
      throw Exception("Invalid object type");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('JSON layout POC'),
      ),
      body: FutureBuilder<LayoutObject>(
      future: layout,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return mapObject(snapshot.data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
    );
  }
}
