import 'package:flutter/material.dart';
import 'Images.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gotoproject/Screen2.dart';
import 'package:shake/shake.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int page = 1;

  @override
  void initState() {
    super.initState();
    getLocationData(page);
    //---------only to detect the shaking--------------------------------
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      setState(() {
        page < 10 ? page++ : page = 1;
        getLocationData(page);
      });
    });
    //-------------------------------------------------------------------
  }

  void getLocationData(int p) async {
    var imageData = await ImagesModel().getWallpaperImages(p);
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Screen2(
        imagesData: imageData,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }
}
