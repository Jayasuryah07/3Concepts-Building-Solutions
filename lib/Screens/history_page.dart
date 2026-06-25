import 'package:concepts/Controller/controller.dart';
import 'package:concepts/Model/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final bool isEmbedded;
  const HistoryPage({super.key, this.isEmbedded = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Controller controller = Get.find<Controller>();
  bool _sortByNewest = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to dynamically update statistics card
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculatePrice(String? kmStr) {
    double km = double.tryParse(kmStr ?? '0') ?? 0.0;
    return (km * 4).round();
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

  int _compareTrips(TripDataModel a, TripDataModel b) {
    final keyA = _getTripKey(a);
    final keyB = _getTripKey(b);
    
    final idxA = controller.localCreatedTripKeys.indexOf(keyA);
    final idxB = controller.localCreatedTripKeys.indexOf(keyB);
    
    if (idxA != -1 && idxB != -1) {
      int cmp = idxA.compareTo(idxB);
      return _sortByNewest ? -cmp : cmp;
    } else if (idxA != -1) {
      return _sortByNewest ? -1 : 1;
    } else if (idxB != -1) {
      return _sortByNewest ? 1 : -1;
    } else {
      final dateA = _getTripDateTime(a);
      final dateB = _getTripDateTime(b);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return _sortByNewest ? 1 : -1;
      if (dateB == null) return _sortByNewest ? -1 : 1;
      int cmp = dateA.compareTo(dateB);
      return _sortByNewest ? -cmp : cmp;
    }
  }

  List<TripDataModel> get _thisMonthTrips {
    final now = DateTime.now();
    final trips = controller.tripHistoryDataList.where((trip) {
      if (trip.tripsDate == null) return false;
      return trip.tripsDate!.year == now.year && trip.tripsDate!.month == now.month;
    }).toList();

    trips.sort(_compareTrips);
    return trips;
  }

  List<TripDataModel> get _previousTrips {
    final now = DateTime.now();
    int prevMonth = now.month - 1;
    int prevYear = now.year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear -= 1;
    }
    final trips = controller.tripHistoryDataList.where((trip) {
      if (trip.tripsDate == null) return false;
      return trip.tripsDate!.year == prevYear && trip.tripsDate!.month == prevMonth;
    }).toList();

    trips.sort(_compareTrips);
    return trips;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff2F5D7C), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff121212)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.black12,
    );
  }

  Widget _buildSummaryCard(List<TripDataModel> activeTrips) {
    int totalTrips = activeTrips.length;
    double totalDistance = activeTrips.fold(0.0, (sum, trip) {
      double km = double.tryParse(trip.tripsKm ?? '0') ?? 0.0;
      return sum + km;
    });
    int totalAmount = activeTrips.fold(0, (sum, trip) {
      return sum + _calculatePrice(trip.tripsKm);
    });

    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Trips", "$totalTrips", Icons.map_outlined),
          _buildStatDivider(),
          _buildStatItem("Total Distance", "${totalDistance.toStringAsFixed(0)} km", Icons.directions_car_outlined),
          _buildStatDivider(),
          _buildStatItem("Total Amount", "₹ $totalAmount", Icons.payments_outlined),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrips = _tabController.index == 0 ? _thisMonthTrips : _previousTrips;

    return Scaffold(
      backgroundColor: const Color(0xffF0F3FB),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xff2F5D7C),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                "Trip History",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: "This Month"),
                  Tab(text: "Previous"),
                ],
              ),
            ),
      body: Column(
        children: [
          if (widget.isEmbedded)
            Container(
              color: const Color(0xff2F5D7C),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: "This Month"),
                  Tab(text: "Previous"),
                ],
              ),
            ),
          _buildSummaryCard(activeTrips),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Trips",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87.withValues(alpha: 0.8),
                  ),
                ),
                PopupMenuButton<bool>(
                  initialValue: _sortByNewest,
                  onSelected: (bool value) {
                    setState(() {
                      _sortByNewest = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                    const PopupMenuItem<bool>(
                      value: true,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 16, color: Color(0xff2F5D7C)),
                          SizedBox(width: 8),
                          Text("Newest First", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 16, color: Color(0xff2F5D7C)),
                          SizedBox(width: 8),
                          Text("Oldest First", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(color: const Color(0xff2F5D7C).withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 14, color: Color(0xff2F5D7C)),
                        const SizedBox(width: 6),
                        Text(
                          _sortByNewest ? "Newest First" : "Oldest First",
                          style: const TextStyle(
                            color: Color(0xff2F5D7C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xff2F5D7C)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTripList(_thisMonthTrips, "No trips recorded this month"),
                _buildTripList(_previousTrips, "No previous trips recorded"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<TripDataModel> trips, String emptyMessage) {
    if (trips.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.getTripHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: Color(0xff7C7C7C),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.getTripHistory(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(15),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
        final formattedDate = trip.tripsDate != null
            ? DateFormat("dd MMM").format(trip.tripsDate!)
            : "";

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
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
                          style: const TextStyle(color: Color(0xff2F5D7C), fontSize: 11, fontWeight: FontWeight.bold),
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
                        const Icon(Icons.radio_button_checked, color: Colors.green, size: 10),
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
                                  height: 1,
                                  color: Colors.black26,
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 10, color: Colors.black26),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.location_on, color: Colors.red, size: 10),
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
          ),
        );
      },
    ),
  );
}
}
