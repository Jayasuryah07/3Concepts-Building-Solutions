import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Model/trip_model.dart';
import 'package:concepts/Screens/history_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Controller controller = Get.put(Controller());
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    await controller.getLoginToken();
    await controller.getRecentTrip();
    await controller.getTripHistory();
    isLoading.value = false;
  }

  int _calculatePrice(String? kmStr) {
    double km = double.tryParse(kmStr ?? '0') ?? 0.0;
    return (km * 4).round();
  }

  Widget _buildRecentTripCard(TripDataModel trip) {
    final formattedDate = trip.tripsDate != null
        ? DateFormat("dd MMM yyyy").format(trip.tripsDate!)
        : "";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F5D7C), Color(0xff437293)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2F5D7C).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "LATEST TRIP",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                Text(
                  "$formattedDate  |  ${trip.tripsTime ?? ""}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, color: Colors.greenAccent, size: 16),
                    Container(
                      width: 1.5,
                      height: 24,
                      color: Colors.white30,
                    ),
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.fromsite?.siteName ?? "Unknown Source",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        trip.tosite?.siteName ?? "Unknown Destination",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${trip.tripsKm ?? "0"} km",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  "₹ ${_calculatePrice(trip.tripsKm)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTripCard(TripDataModel trip) {
    final formattedDate = trip.tripsDate != null
        ? DateFormat("dd/MM").format(trip.tripsDate!)
        : "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffF4F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Color(0xff2F5D7C), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    trip.tripsTime ?? "",
                    style: const TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      trip.fromsite?.siteName ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Color(0xff121212), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: const Color.fromARGB(66, 48, 48, 48),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 20, color: Color.fromARGB(66, 48, 48, 48)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      trip.tosite?.siteName ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Color(0xff121212), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "₹ ${_calculatePrice(trip.tripsKm)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff2F5D7C),
                  ),
                ),
                Text(
                  "${trip.tripsKm ?? "0"} km",
                  style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.width / 10),
            const Text(
              "Recent Trip",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff121212)),
            ),
            SizedBox(height: Get.width / 30),
            Obx(
              () {
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildRecentTripCard(controller.recentTripData.value);
              },
            ),
            SizedBox(height: Get.width / 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff121212)),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const HistoryPage(), transition: Transition.fadeIn);
                  },
                  child: const Text(
                    "View all",
                    style: TextStyle(color: Color(0xff7C7C7C), fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            Expanded(
              child: Obx(
                () {
                  final displayCount = controller.tripHistoryDataList.length > 5 ? 5 : controller.tripHistoryDataList.length;
                  return ListView.builder(
                    itemCount: displayCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHistoryTripCard(controller.tripHistoryDataList[index]),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
