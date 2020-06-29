import 'package:http/http.dart' as http;
import 'dart:convert';

//------------HERE I BUILD THE API TO WORK ON-------------------------------------------
const String apiKey = 't7PrRZQckXqmQho6MFHeAGNVFrdulKyfJJJLCJIwOTM';
const String unSplashAPI = 'https://api.unsplash.com/search/photos';

//---------------------------------------------------------------------------------------

class NetworkHelper {
  Future getData(int p) async {
    String url =
        '$unSplashAPI?page=$p&query=wallpaper&orientation=portrait&order_by=popular&client_id=$apiKey';
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
