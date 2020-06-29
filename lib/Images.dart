import 'package:gotoproject/api_data_fetch.dart';

class ImagesModel {
  Future<dynamic> getWallpaperImages(int page) async {
    var imageData = await NetworkHelper().getData(page);
    return imageData;
  }
}
