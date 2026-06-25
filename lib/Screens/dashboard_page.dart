import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Model/sites_model.dart';
import 'package:concepts/Screens/home_page.dart';
import 'package:concepts/Screens/profile_page.dart';
import 'package:concepts/Utils/api_helper.dart';
import 'package:concepts/Utils/const_helper.dart';
import 'package:concepts/Utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:concepts/Screens/history_page.dart';



class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    controller.bottomIndex.value = 0;

    initData();
  }

  Future<void> initData() async {
    await controller.getLoginToken();
    await controller.getProfile();
    await controller.getSites();
  }

  Future<void> _getCurrentLocation(TextEditingController addressController, void Function(void Function()) setDialogState) async {
    try {
      Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Getting GPS coordinates...");
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
          ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
        ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
          const SnackBar(content: Text("Location permission is permanently denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
      Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Resolving address...");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String name = place.name ?? "";
        String subLocality = place.subLocality ?? "";
        String locality = place.locality ?? "";
        String postalCode = place.postalCode ?? "";
        String country = place.country ?? "";
        
        List<String> addressParts = [];
        if (name.isNotEmpty) addressParts.add(name);
        if (subLocality.isNotEmpty) addressParts.add(subLocality);
        if (locality.isNotEmpty) addressParts.add(locality);
        if (postalCode.isNotEmpty) addressParts.add(postalCode);
        if (country.isNotEmpty) addressParts.add(country);
        
        String fullAddress = addressParts.join(", ");
        setDialogState(() {
          addressController.text = fullAddress;
        });
      } else {
        setDialogState(() {
          addressController.text = "${position.latitude}, ${position.longitude}";
        });
      }
    } catch (e) {
      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
      print("Error getting current location: $e");
      ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  void _showAddSiteDialog(BuildContext context) {
    TextEditingController newSiteController = TextEditingController();
    TextEditingController newAddressController = TextEditingController();
    List<Map<String, String>> placeSuggestions = [];
    bool isSearching = false;
    String selectedPlaceUrl = "";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            width: Get.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xff2F5D7C),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Text(
                              "Add New Location",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Site Name *",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: newSiteController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: "Enter location name",
                                prefixIcon: const Icon(Icons.business, color: Color(0xff2F5D7C), size: 20),
                                filled: true,
                                fillColor: const Color(0xffF4F6FA),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xff2F5D7C), width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Site Address",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                InkWell(
                                  onTap: () => _getCurrentLocation(newAddressController, setDialogState),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.my_location, color: Color(0xff2F5D7C), size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          "Current Location",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff2F5D7C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: newAddressController,
                              style: const TextStyle(fontSize: 14),
                                onChanged: (val) async {
                                  selectedPlaceUrl = ""; // reset URL if user types
                                  if (val.trim().length > 2) {
                                    setDialogState(() {
                                    isSearching = true;
                                  });
                                  final suggestions = await ApiHelper.apiHelper.fetchPlaceSuggestions(val);
                                  setDialogState(() {
                                    placeSuggestions = suggestions;
                                    isSearching = false;
                                  });
                                } else {
                                  setDialogState(() {
                                    placeSuggestions = [];
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter address ",
                                prefixIcon: const Icon(Icons.map_outlined, color: Color(0xff2F5D7C), size: 20),
                                filled: true,
                                fillColor: const Color(0xffF4F6FA),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xff2F5D7C), width: 1.5),
                                ),
                              ),
                            ),
                            if (isSearching)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff2F5D7C)),
                                  ),
                                ),
                              ),
                            if (placeSuggestions.isNotEmpty)
                              Container(
                                constraints: const BoxConstraints(maxHeight: 150),
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: placeSuggestions.length,
                                  itemBuilder: (context, idx) {
                                    final suggestion = placeSuggestions[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(suggestion["text"] ?? "", style: const TextStyle(fontSize: 13)),
                                      onTap: () async {
                                        setDialogState(() {
                                          newAddressController.text = suggestion["text"] ?? "";
                                          placeSuggestions = [];
                                        });
                                        final placeId = suggestion["placeId"];
                                        if (placeId != null) {
                                          final url = await ApiHelper.apiHelper.fetchPlaceDetailsUrl(placeId);
                                          if (url != null) {
                                            selectedPlaceUrl = url;
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                String name = newSiteController.text.trim();
                                String address = newAddressController.text.trim();

                                if (name.isNotEmpty) {
                                  Navigator.pop(context);
                                  Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Adding site...");
                                  bool success = await controller.addNewSite(
                                    siteName: name,
                                    siteAddress: address,
                                    siteUrl: selectedPlaceUrl,
                                  );
                                  Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                  
                                  ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? "Location added successfully!" : "Failed to add location"),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Site name is required!"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add, size: 18, color: Colors.white),
                              label: const Text(
                                "Add Site",
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2F5D7C),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1D3E53), Color(0xff2F5D7C), Color(0xff437293)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 50,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Container(
                    height: Get.width / 7,
                    width: Get.width / 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.white24, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Obx(() {
                        final image = controller.profileData.value.userImage;
                        final baseUrl = controller.imagePath.value;

                        final fullUrl = (image != null &&
                                image.isNotEmpty &&
                                baseUrl.isNotEmpty)
                            ? "$baseUrl$image"
                            : null;

                        if (fullUrl == null) {
                          return CircleAvatar(
                            backgroundColor: const Color(0xffF4F6FA),
                            child: Icon(
                              Icons.person,
                              color: const Color(0xff2F5D7C).withOpacity(0.6),
                              size: Get.width / 14,
                            ),
                          );
                        }

                        return ClipOval(
                          child: Image.network(
                            fullUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor: const Color(0xffF4F6FA),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xff2F5D7C).withOpacity(0.6),
                                  size: Get.width / 14,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(width: Get.width / 40),

                  Expanded(
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.profileData.value.name ?? "User",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Obx(() {
                    final isActive = controller.bottomIndex.value == 2;
                    if (isActive) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () {
                        controller.bottomIndex.value = 2;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: Get.width / 30),
            Expanded(
              child: Container(
                height: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Obx(
                  () => controller.bottomIndex.value == 0
                      ? const HomePage()
                      : controller.bottomIndex.value == 1
                          ? const HistoryPage(isEmbedded: true)
                          : const ProfilePage(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
        backgroundColor: Colors.transparent,
        elevation: 4,
        onPressed: () {
          controller.selectFromSite.value = SitesDataModel(id: 1);
          controller.selectToSite.value = SitesDataModel(id: 1);
          controller.selectDate.value = DateFormat('dd/MM/yyyy').format(DateTime.now());
          controller.selectTime.value = DateFormat('hh:mm').format(DateTime.now());
          
          showModalBottomSheet(
            context: ConstHelper.navigatorKey.currentContext!,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Center(
                                  child: Text(
                                    "Add Trip",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff121212),
                                      fontSize: 20,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.width / 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Date",
                                            style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(
                                            () => TextField(
                                              readOnly: true,
                                              textAlign: TextAlign.center,
                                              controller: TextEditingController(text: controller.selectDate.value),
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color(0xffF4F6FA),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                suffixIcon: Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: SvgPicture.asset(
                                                    "assets/calendar.svg",
                                                    width: 18,
                                                    height: 18,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                final now = DateTime.now();
                                                final today = DateTime(now.year, now.month, now.day);
                                                DateTime? pickedDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: today,
                                                  firstDate: today,
                                                  lastDate: today,
                                                );

                                                if (pickedDate != null) {
                                                  String formattedDate = DateFormat("dd/MM/yyyy").format(pickedDate);
                                                  controller.selectDate.value = formattedDate;
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Time",
                                            style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(
                                            () => TextField(
                                              readOnly: true,
                                              textAlign: TextAlign.center,
                                              controller: TextEditingController(text: controller.selectTime.value),
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color(0xffF4F6FA),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                suffixIcon: Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: SvgPicture.asset(
                                                    "assets/clock.svg",
                                                    width: 18,
                                                    height: 18,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                TimeOfDay? pickedTime = await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );

                                                if (pickedTime != null) {
                                                  final hour = (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
                                                      .toString()
                                                      .padLeft(2, '0');
                                                  final minute = pickedTime.minute.toString().padLeft(2, '0');
                                                  controller.selectTime.value = "$hour:$minute";
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: Get.width / 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () => _showAddSiteDialog(context),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.add, size: 16, color: Color(0xff2F5D7C)),
                                            SizedBox(width: 4),
                                            Text(
                                              "Add New Site",
                                              style: TextStyle(color: Color(0xff2F5D7C), fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => DropdownButtonFormField<SitesDataModel>(
                                    dropdownColor: Colors.white,
                                    value: controller.selectFromSite.value.id == 0
                                        ? null
                                        : controller.siteDataList.firstWhereOrNull(
                                            (e) => e.id == controller.selectFromSite.value.id,
                                          ),
                                    hint: const Text("Select From Site", style: TextStyle(fontSize: 14)),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xffF4F6FA),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: controller.siteDataList.map((site) {
                                      return DropdownMenuItem<SitesDataModel>(
                                        value: site,
                                        child: Text(
                                          site.siteName ?? "",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.selectFromSite.value = value;
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: Get.width / 20),
                                const Text(
                                  "To",
                                  style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => DropdownButtonFormField<SitesDataModel>(
                                    dropdownColor: Colors.white,
                                    value: controller.selectToSite.value.id == 0
                                        ? null
                                        : controller.siteDataList.firstWhereOrNull(
                                            (e) => e.id == controller.selectToSite.value.id,
                                          ),
                                    hint: const Text("Select To Site", style: TextStyle(fontSize: 14)),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xffF4F6FA),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: controller.siteDataList.map((toSite) {
                                      return DropdownMenuItem<SitesDataModel>(
                                        value: toSite,
                                        child: Text(
                                          toSite.siteName ?? "",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.selectToSite.value = value;
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: Get.width / 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      DateTime date = DateFormat("dd/MM/yyyy").parse(controller.selectDate.value);
                                      DateTime time = DateFormat("hh:mm").parse(controller.selectTime.value);
                                      Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                                      ApiHelper.apiHelper
                                          .createTrip(
                                        token: controller.loginToken.value,
                                        tripDate: DateFormat("yyyy-MM-dd").format(date),
                                        tripTime: DateFormat("hh:mm").format(time),
                                        tripFromID: controller.selectFromSite.value.id!,
                                        tripToID: controller.selectToSite.value.id!,
                                      )
                                          .then((createTrip) async {
                                        if (createTrip["code"] == 200) {
                                          await controller.addCreatedTripLocally(
                                            date: DateFormat("yyyy-MM-dd").format(date),
                                            time: DateFormat("hh:mm").format(time),
                                            fromId: controller.selectFromSite.value.id!,
                                            toId: controller.selectToSite.value.id!,
                                          );
                                          Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                          Get.back();
                                          await controller.getRecentTrip();
                                          await controller.getTripHistory();
                                          controller.bottomIndex.value = 0;
                                          ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                createTrip["message"],
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                          Get.back();
                                          ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                createTrip["message"],
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff2F5D7C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      "Create",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xff1D3E53), Color(0xff2F5D7C), Color(0xff437293)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
          child: Container(
            height: Get.width / 7,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1D3E53), Color(0xff2F5D7C), Color(0xff437293)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff1D3E53).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      controller.bottomIndex.value = 0;
                    },
                    child: Obx(() {
                      final isActive = controller.bottomIndex.value == 0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/home.svg",
                            height: Get.width / 15,
                            width: Get.width / 15,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              isActive ? Colors.white : Colors.white.withOpacity(0.5),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Home",
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                            ),
                          )
                        ],
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.bottomIndex.value = 1;
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Obx(() {
                      final isActive = controller.bottomIndex.value == 1;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                            size: Get.width / 15,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "History",
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
