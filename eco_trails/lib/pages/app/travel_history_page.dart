import 'package:eco_trails/pages/app/trip_plan_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TravelHistoryPage extends StatefulWidget {
  const TravelHistoryPage({super.key});

  @override
  TravelHistoryPageState createState() => TravelHistoryPageState();
}

class TravelHistoryPageState extends State<TravelHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildTripCard(String title, String date, String imageUrl) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(date),
                if (_tabController.index == 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF264653),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TripPlanPage()),
                        );
                      },
                      child: Text("View Details"),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dummyImage = 'assets/images/places/ranikhet.jpg';

    return Scaffold(
      backgroundColor: Color(0xFFD1E0DC),
      appBar: AppBar(
        backgroundColor: Color(0xFFD1E0DC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            (context).go('/home');
          },
        ),
        title: Text(
          "Travel History",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            tabs: [Tab(text: 'Past Trip'), Tab(text: 'Ongoing')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: [
                    SizedBox(height: 16),
                    _buildTripCard(
                      'Dungagiri, Almora',
                      '23-05-2077',
                      dummyImage,
                    ),
                    _buildTripCard(
                      'Dungagiri, Almora',
                      '23-05-2077',
                      dummyImage,
                    ),
                  ],
                ),
                ListView(
                  children: [
                    SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.asset(
                              dummyImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Destination
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Destination: ",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 20
                                                  : 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "Dungagiri, Almora",
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.of(
                                                          context,
                                                        ).size.width >
                                                        600
                                                    ? 18
                                                    : 16,
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Date (LEFT aligned now)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Date: ",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 20
                                                  : 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "23-05-2077",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 18
                                                  : 16,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Status: ",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 20
                                                  : 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Ongoing",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 18
                                                  : 16,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Accommodation
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Accommodation Info: ",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 20
                                                  : 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "Hotel Info",
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.of(
                                                          context,
                                                        ).size.width >
                                                        600
                                                    ? 18
                                                    : 16,
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Planned Activities (wrapped)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Planned Activities: ",
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 20
                                                  : 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Solang Valley trek, Hidimba Temple visit , Bungee Jumping, Swimming, Camping",
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.of(
                                                          context,
                                                        ).size.width >
                                                        600
                                                    ? 18
                                                    : 16,
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
