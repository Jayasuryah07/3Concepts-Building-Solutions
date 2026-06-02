import 'package:concepts/Utils/api_const.dart';
import 'package:concepts/Utils/const_helper.dart';
import 'package:dio/dio.dart';

class ApiHelper{
  ApiHelper._();
  static ApiHelper apiHelper = ApiHelper._();
  final dio = Dio();

  Future getLogin({required String mobile,required String password,required String deviceID})
  async{
    try{
      var data = FormData.fromMap({
        "mobile":mobile,
        "password":password,
        "device_id":deviceID
      });

      Response response =await dio.post(ApiConst.login,data: data);

      if(response.statusCode == 200)
        {
          return {
            "code":response.data["code"],
            "message":response.data["message"],
            "data":response.data["data"],
            "company":response.data["company"],
            "image_url":response.data["image_url"],
            // "user":response.data["data"]["user"],
          };
        }
    }
    catch(error)
    {
      print("EEEEEEEEEE $error");
    }
  }

  Future fetchRecentTrip({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.recentTrip,options: Options(
        headers: headers
      ));

      if(response.statusCode == 200)
        {
          return {
            "code":response.statusCode,
            "data":response.data["data"],
          };
        }
    }
    catch(error)
    {
      print("EEEEE $error");
    }
  }

  Future fetchProfile({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchProfile,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
          "image_url":response.data["image_url"],
        };
      }
    }
    catch(error)
    {
      print("EEEEE $error");
    }
  }

  Future fetchTripHistory({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.tripHistory,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
        };
      }
    }
    catch(error)
    {
      print("EEEEE $error");
    }
  }

  Future fetchSites({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchSites,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
        };
      }
    }
    catch(error)
    {
      print("EEEEE $error");
    }
  }

  Future createTrip({
    required String token,
    required String tripDate,
    required String tripTime,
    required int tripFromID,
    required int tripToID
})
async{
  var  headers = {
    "Authorization": "Bearer $token"
  };

  var data = FormData.fromMap({
    "trips_date":tripDate,
    "trips_time":tripTime,
    "trips_from_id":tripFromID,
    "trips_to_id":tripToID
  });

  Response response = await dio.post(ApiConst.createTrip,data: data,options: Options(
    headers: headers
  ));

  if(response.statusCode == 200)
    {
      return {
        "code":response.data["code"],
        "message":response.data["message"],
      };
    }

}

  Future createSite({
    required String token,
    required String siteName,
    required String siteAddress,
    required String siteUrl,
  }) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "site_name": siteName,
        "site_address": siteAddress,
        "site_url": siteUrl,
      });

      Response response = await dio.post(ApiConst.createSite, data: data, options: Options(
          headers: headers
      ));

      if (response.statusCode == 200) {
        return {
          "code": response.data["code"],
          "message": response.data["message"],
        };
      }
    } catch (error) {
      print("Create Site API Error: $error");
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (ConstHelper.googleMapsApiKey == "YOUR_GOOGLE_MAPS_API_KEY" || ConstHelper.googleMapsApiKey.isEmpty) {
      return [];
    }
    try {
      const url = "https://places.googleapis.com/v1/places:autocomplete";
      Response response = await dio.post(
        url,
        data: {
          "input": input,
          "includedRegionCodes": ["in"],
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": ConstHelper.googleMapsApiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final suggestions = data["suggestions"] as List?;
        if (suggestions == null) {
          return [];
        }
        return suggestions
            .map((s) => s["placePrediction"]?["text"]?["text"] as String?)
            .where((text) => text != null)
            .cast<String>()
            .toList();
      }
    } catch (e) {
      print("Error fetching place suggestions from Places API (New): $e");
      if (e is DioException) {
        if (e.response != null) {
          print("Places API (New) Error Response: ${e.response?.data}");
        } else {
          print("Places API (New) Request Error: ${e.message}");
        }
      }
    }
    return [];
  }

}