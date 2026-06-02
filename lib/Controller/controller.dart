import 'package:concepts/Model/company_model.dart';
import 'package:concepts/Model/profile_model.dart';
import 'package:concepts/Model/sites_model.dart';
import 'package:concepts/Model/trip_model.dart';
import 'package:concepts/Utils/api_helper.dart';
import 'package:concepts/Utils/shared_pref.dart';
import 'package:get/get.dart';

class Controller extends GetxController{
  RxString loginToken = "".obs;
  Rx<TripDataModel> recentTripData = TripDataModel().obs;
  Rx<ProfileDataModel> profileData = ProfileDataModel().obs;
  RxString noImagePath = "".obs;
  RxString imagePath = "".obs;
  RxList<TripDataModel> tripHistoryDataList = <TripDataModel>[].obs;
  RxList<SitesDataModel> siteDataList = <SitesDataModel>[].obs;
  Rx<SitesDataModel> selectFromSite = SitesDataModel().obs;
  Rx<SitesDataModel> selectToSite = SitesDataModel().obs;
  RxString selectDate = "".obs;
  RxString selectTime = "".obs;
  Rx<CompanyDataModel> companyData = CompanyDataModel().obs;
  RxString noCompanyImage = "".obs;
  RxString companyImage = "".obs;
  RxBool imageLoader = false.obs;
  RxList<String> localCreatedTripKeys = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalCreatedTripKeys();
  }

  Future<void> loadLocalCreatedTripKeys() async {
    final list = await SharedPref.getStringList("local_created_trips") ?? [];
    localCreatedTripKeys.value = list;
  }

  Future<void> addCreatedTripLocally({
    required String date,
    required String time,
    required int fromId,
    required int toId,
  }) async {
    final key = "${date}_${time}_${fromId}_${toId}";
    if (!localCreatedTripKeys.contains(key)) {
      localCreatedTripKeys.add(key);
      await SharedPref.setStringList("local_created_trips", localCreatedTripKeys);
    }
  }

  DateTime? _getTripDateTime(TripDataModel trip) {
    if (trip.tripsDate == null) return null;
    if (trip.tripsTime == null || trip.tripsTime!.isEmpty) return trip.tripsDate;
    try {
      final timeParts = trip.tripsTime!.split(":");
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        return DateTime(
          trip.tripsDate!.year,
          trip.tripsDate!.month,
          trip.tripsDate!.day,
          hour,
          minute,
        );
      }
    } catch (_) {}
    return trip.tripsDate;
  }

  String _getTripKey(TripDataModel trip) {
    final dateStr = trip.tripsDate != null 
        ? "${trip.tripsDate!.year.toString().padLeft(4, '0')}-${trip.tripsDate!.month.toString().padLeft(2, '0')}-${trip.tripsDate!.day.toString().padLeft(2, '0')}"
        : "";
    return "${dateStr}_${trip.tripsTime ?? ''}_${trip.tripsFromId ?? ''}_${trip.tripsToId ?? ''}";
  }

  void sortTripsByCreation(List<TripDataModel> trips) {
    trips.sort((a, b) {
      final keyA = _getTripKey(a);
      final keyB = _getTripKey(b);
      
      final idxA = localCreatedTripKeys.indexOf(keyA);
      final idxB = localCreatedTripKeys.indexOf(keyB);
      
      if (idxA != -1 && idxB != -1) {
        return idxB.compareTo(idxA); // Newest creation first
      } else if (idxA != -1) {
        return -1;
      } else if (idxB != -1) {
        return 1;
      } else {
        final dateA = _getTripDateTime(a);
        final dateB = _getTripDateTime(b);
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // Newest trip date first
      }
    });
  }

  Future getLoginToken()
  async{
    loginToken.value = await SharedPref.isLoggedToken()??"";
    // print("TTTTTTTTTT222222222 ${loginToken.value.length}");
  }

  Future getRecentTrip()
  async{
    ApiHelper.apiHelper.fetchRecentTrip(token: loginToken.value).then((recentTrip) {
      if (tripHistoryDataList.isEmpty) {
        recentTripData.value = TripDataModel.fromJson(recentTrip["data"]);
      }
    },);
  }

  Future getProfile()
  async{
    final profile = await ApiHelper.apiHelper.fetchProfile(
      token: loginToken.value,
    );

    noImagePath.value = profile["image_url"][0]["image_url"] ?? "";
    imagePath.value = profile["image_url"][1]["image_url"] ?? "";

    profileData.value = ProfileDataModel.fromJson(profile["data"]);
  }

  Future getTripHistory()
  async{
    ApiHelper.apiHelper.fetchTripHistory(token: loginToken.value).then((tripHistory) {
      List filterData = tripHistory["data"];
      final list = filterData.map((e) => TripDataModel.fromJson(e)).toList();
      sortTripsByCreation(list);
      tripHistoryDataList.value = list;

      if (tripHistoryDataList.isNotEmpty) {
        recentTripData.value = tripHistoryDataList.first;
      }
      print("LLLLLLLL ${tripHistoryDataList.length}");
    },);
  }

  Future getSites()
  async{
    ApiHelper.apiHelper.fetchSites(token: loginToken.value).then((sites) {
      List filterData = sites["data"];
      siteDataList.value = filterData.map((e) => SitesDataModel.fromJson(e)).toList();
      print("SSSSSSSSSS ${siteDataList.length}");
    },);
  }

  Future getCompanyData()
  async{
    companyData.value =await SharedPref.getCompanyData()??CompanyDataModel();
  }

  Future getCompanyImage()
  async{
    noCompanyImage.value =await SharedPref.getNoImagePath()??"";
    companyImage.value =await SharedPref.getImagePath()??"";
    imageLoader.value = true;
  }

  Future<bool> addNewSite({
    required String siteName,
    required String siteAddress,
  }) async {
    try {
      final res = await ApiHelper.apiHelper.createSite(
        token: loginToken.value,
        siteName: siteName,
        siteAddress: siteAddress,
        siteUrl: "", // Sending empty string to backend as it's removed from UI
      );
      if (res != null && res["code"] == 200) {
        await getSites();
        return true;
      }
    } catch (e) {
      print("Controller addNewSite error: $e");
    }
    return false;
  }

}