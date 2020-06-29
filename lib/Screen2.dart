import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Screen2 extends StatefulWidget {
  Screen2({this.imagesData});
  final imagesData;
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  //-----------different data 1. to get names 2.to to get urls-----------
  var names = List<String>.filled(10, '', growable: false);
  var urls = List<String>.filled(10, '', growable: false);
  int index = 0; //this one is used to keep track of the screen number

  //---------------------------------------------------------------------

  //-- this is used to 1. get the data 2. to make the list at the start itself---
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI(widget.imagesData);
    makeBackgroundList();
  }
  //-----------------------------------------------------------------------------------------------

  //-------------fetching urls and names at the beginning----------------
  void updateUI(dynamic imageData) {
    for (int i = 0; i < 10; i++) {
      if (imageData == null) {
        names[i] = 'system';
        urls[i] =
            'https://i2.wp.com/appslova.com/wp-content/uploads/2016/03/Android-error.png?fit=512%2C512&ssl=1';
      } else {
        names[i] = imageData['results'][i]['user']['name'];
        urls[i] = imageData['results'][i]['urls']['regular'];
      }
    }
  }
  //---------------------------------------------------------------------

  //---------Here we are making the different backgrounds----------------
  var resolved = List<OneBackground>();
  List<OneBackground> makeBackgroundList() {
    for (int i = 0; i < 10; i++) {
      OneBackground temp = OneBackground(
        url: urls[i],
        name: names[i],
      );
      resolved.add(temp);
    }
    return resolved;
  }
  //---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //this is used to create the scrolling functionality------------
        PageView(
          physics: BouncingScrollPhysics(),
          children: resolved,
          onPageChanged: (value) {
            setState(() {
              index = value;
            });
          },
        ),
        //--------------------------------------------------------------

        //----------this here is the dots displayed below----------------
        resolved.length == 2
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new DotsIndicator(
                      dotsCount: 10,
                      position: index.toDouble(),
                    )
                  ],
                ),
              ),
        //--------------------------------------------------------------
      ],
    );
  }
}

//OneBackground(i: index, url: urls)
class OneBackground extends StatefulWidget {
  OneBackground({this.url, this.name});
  final String url;
  final String name;
  @override
  _OneBackgroundState createState() => _OneBackgroundState();
}

class _OneBackgroundState extends State<OneBackground> {
//--------------data required by the widget------------------------------
  bool homeOn = false;
  bool lockOn = false;
//-----------------------------------------------------------------------
//------------this is to get android permission--------------------------
  Future _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

//-----------------------------------------------------------------------
//----------this here is to save the image-------------------------------
  _getHttp() async {
    await _requestPermission();
    var response = await Dio()
        .get(widget.url, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: widget.name);
    if (result != null) {
      //-----------this is my alert on save------------------------------
      Alert(
        context: context,
        title: "Saved",
        desc: "Wallpaper successfully saved to camera roll",
        buttons: [
          DialogButton(
            child: Text(
              "High 5!",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
  }

//-----------------------------------------------------------------------

//---------------these are methods to build our home and lock screen-----
  Widget _toggleName() {
    if (homeOn == true || lockOn == true) {
      return Container();
    } else {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.black54,
                child: Text(
                  'Photo By',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                color: Colors.black54,
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _toggleHome() {
    if (homeOn == false) {
      return Container();
    } else {
      return Image.asset(
        'images/homescreen.png',
      );
    }
  }

  Widget _toggleLock() {
    if (lockOn == false) {
      return Container();
    } else {
      return Image.asset(
        'images/lockscreen.png',
      );
    }
  }
//-----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //stack to get the gesture detecting containers
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          //---------------------child 1 a background sexy image--------------
          Container(
            child: new Image.network(
              widget.url,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
          ),
          //------------------the two detecting images------------------------
          Row(
            children: <Widget>[
              Expanded(
                //--------the gestures on container---------------------------
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      lockOn = true;
                    });
                  },
                  onLongPressUp: () {
                    setState(() {
                      lockOn = false;
                    });
                  },
                  onDoubleTap: _getHttp,
                  child: Container(
                    color: Colors.red.withOpacity(0.0),
                    //to display the author name-------------------------------
                    child: _toggleName(),
                  ),
                ),
              ),
              //the other simple gesture---------------------------------------
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      homeOn = true;
                    });
                  },
                  onLongPressUp: () {
                    setState(() {
                      homeOn = false;
                    });
                  },
                  onDoubleTap: _getHttp,
                  child: Container(
                    color: Colors.red.withOpacity(0.0),
                  ),
                ),
              )
            ],
          ),
          _toggleHome(),
          _toggleLock(),
        ],
      ),
    );
  }
}
