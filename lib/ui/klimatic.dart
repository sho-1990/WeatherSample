import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klimatic/util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
        MaterialPageRoute<Map>(
          builder: (BuildContext context) {
            return _ChangeCity();
          }
        ));

    if (results != null && results.containsKey('enter')) {
      debugPrint(results['enter']);
      _cityEntered = results['enter'];
    }
  }

  void showStuff() async {
    Map data = await _getWeather(util.apiId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Klimatic",),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.menu), onPressed: () => _goToNextScreen(context),)
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('images/umbrella.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(_cityEntered == null ? util.defaultCity :  '$_cityEntered',
              style: _cityStyle(),),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png'),
          ),
          updateTempWidget(_cityEntered)
        ],
      ),
    );
  }

  Future<Map> _getWeather(String apiId, String city) async {
    String apiUrl = "http://api.openweathermap.org/data/2.5/weather?q=$city&appid="
        "$apiId&units=imperial";
    debugPrint(apiUrl);
    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: _getWeather(util.apiId, city == null ? util.defaultCity : city),
        builder: (context, snapshot) {
          // where we get all of the json data, we setup widgets etc.
          if (snapshot.hasData) {
            Map content = snapshot.data;
            if (!content.containsKey('main')) {
              return Container();
            }
            return Container(
              margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: Text("${content['main']['temp'].toString()} F",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 49.9,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                    ),),
                    subtitle: ListTile(
                      title: Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                            "Min: ${content['main']['temp_min'].toString()} F\n"
                            "Max: ${content['main']['temp_max'].toString()} F"
                      , style: extraData(),),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
    });
  }

  TextStyle _cityStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 22.9,
      fontStyle: FontStyle.italic
    );
  }

  TextStyle _tempStyle() {
    return TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9,
    );
  }

  TextStyle extraData() {
    return TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontSize: 17.0,
    );
  }
}


class _ChangeCity extends StatelessWidget {
  var _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Change City'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'enter': _cityFieldController.text
                    });
                  },
                  textColor: Colors.white70,
                  color: Colors.redAccent,
                  child: Text('Get Weather'),),
              )
            ],
          )
        ],
      ),
    );
  }
}
