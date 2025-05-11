import 'dart:async';
import 'package:eco_trails/models/Itinerary.dart';
import 'package:eco_trails/services/fetch_Itinerary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TripPlanPage extends StatefulWidget {
  const TripPlanPage({super.key});
  @override
  State<TripPlanPage> createState() => _TripPlanPageState();
}

class _TripPlanPageState extends State<TripPlanPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs = ['Over View'];
  Map<int, List<ItineraryItem>> dayWiseItinerary = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length + 1, vsync: this);
    fetchItinerary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchItinerary() async {
    try {
      List<ItineraryItem> itineraryItems =
          await FetchItinerary().fetchItineraryData();

      final Map<int, List<ItineraryItem>> grouped = {};
      for (var item in itineraryItems) {
        final dayNumber = int.tryParse(
          item.day.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        if (dayNumber != null) {
          grouped.putIfAbsent(dayNumber, () => []).add(item);
        }
      }

      List<int> sortedDays = grouped.keys.toList()..sort();

      setState(() {
        dayWiseItinerary = grouped;
        _tabs = ['Overview'] + sortedDays.map((day) => 'Day $day').toList();
        isLoading = false;
      });

      if (mounted) {
        _tabController = TabController(length: _tabs.length, vsync: this);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // void _addDay() {
  //   final newIndex = _tabController.index;
  //   setState(() {
  //     int newDay = _tabs.where((t) => t.startsWith('Day')).length + 1;
  //     _tabs.insert(_tabs.length, 'Day $newDay');
  //     _tabController.dispose();
  //     _tabController = TabController(length: _tabs.length + 1, vsync: this);
  //     _tabController.index = newIndex;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final panelHeight = MediaQuery.of(context).size.height * 0.55;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF93B7AC),
      body: Stack(
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
            child: SizedBox.expand(child: MapView()),
          ),
          Positioned(top: 50, right: 0, child: LocationInfoBox()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Container(
                height: panelHeight,
                color: const Color(0xFFCADCD6),
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFF264653),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        indicatorColor: Colors.tealAccent,
                        tabs: [..._tabs.map((t) => Tab(text: t))],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const OverviewContent(),
                          ..._tabs.where((t) => t.startsWith('Day')).map((tab) {
                            final day = int.tryParse(tab.split(' ')[1]) ?? 1;
                            final items = dayWiseItinerary[day] ?? [];
                            return DayItinerary(items: items);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewContent extends StatelessWidget {
  const OverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFCADCD6),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MUNICH ►',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Munsiyari is a picturesque hill station in Uttarakhand, nestled in the Kumaon Himalayas, known for its stunning views of the Panchachuli peaks.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('4 Days Trip ⏱', style: TextStyle(fontSize: 16)),
                Row(children: [Icon(Icons.person, size: 18), Text(" Solo")]),
                Row(children: [Icon(Icons.no_food, size: 18), Text(" Veg")]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(DateFormat('dd-MM-yyyy').format(DateTime.now())),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.sunny, size: 28),
                SizedBox(width: 8),
                Text("23° sunny", style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF264653),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text(
                  "Cancel Trip",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayItinerary extends StatelessWidget {
  final List<ItineraryItem> items;

  const DayItinerary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFCADCD6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              items.map((item) {
                return Column(
                  children: [
                    Text(
                      '${item.locationName} (${item.type})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Budget: ₹${item.budgetEstimate}'),
                    const Divider(),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final String imageUrl;
  final String type;
  final String name;
  final double rating;
  final int price;
  final String distance;
  final String time;

  const PlaceCard({
    super.key,
    required this.imageUrl,
    required this.type,
    required this.name,
    required this.rating,
    required this.price,
    required this.distance,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C8E89),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/places/ranikhet.jpg',
              image: imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/places/ranikhet.jpg',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      "$rating",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  "₹ $price per person",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 16,
                    color: Colors.white,
                  ),
                  Text(" $time", style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: Colors.white),
                  Text(
                    " $distance",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationInfoBox extends StatefulWidget {
  const LocationInfoBox({super.key});
  @override
  State<LocationInfoBox> createState() => _LocationInfoBoxState();
}

class _LocationInfoBoxState extends State<LocationInfoBox> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getCurrentTime(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = _formatDateTime(now);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF264653),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dwarahat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _timeString,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(29.7764, 79.4270),
        minZoom: 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.tripplanner',
        ),
      ],
    );
  }
}
