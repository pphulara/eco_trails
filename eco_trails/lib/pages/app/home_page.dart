import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_trails/models/place.dart';
import 'package:eco_trails/pages/app/app_drawer.dart';
import 'package:eco_trails/pages/app/category_page.dart';
import 'package:eco_trails/pages/app/map_page.dart';
import 'package:eco_trails/pages/app/trip_plan_page.dart';
import 'package:eco_trails/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
  int selectedBottomIndex = 0;
  int currentPopularIndex = 0;
  String? currentLocation;

  List<Place> popularPlaces = [];
  List<Place> hiddenGems = [];
  bool isLoading = true;

  final PageController _popularListController = PageController();

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchPlaces();
  }

  Future<void> fetchLocation() async {
    isLoading = true;
    final address = await LocationService.getCurrentAddress();
    setState(() {
      currentLocation = address ?? 'Location unavailable';
      isLoading = false;
    });
  }

  Future<void> fetchPlaces() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('places').get();
    final allPlaces =
        snapshot.docs.map((doc) => Place.fromFirestore(doc.data())).toList();

    setState(() {
      popularPlaces = allPlaces.where((place) => place.isPopular).toList();
      hiddenGems = allPlaces.where((place) => place.isHiddenGem).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const AppDrawer(),
      backgroundColor: const Color.fromRGBO(201, 219, 213, 1),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPageContent(deviceWidth),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPageContent(double deviceWidth) {
    if (selectedBottomIndex == 1) return const CategoryPage();
    if (selectedBottomIndex == 2) return MapScreen();
    if (selectedBottomIndex == 3) return TripPlanPage();
    return _buildHomeContent(deviceWidth);
  }

  Widget _buildHomeContent(double deviceWidth) {
    List<Place> displayedList =
        selectedTabIndex == 0 ? popularPlaces : hiddenGems;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildTopBar(),
            const SizedBox(height: 30),
            _buildLocationRow(),
            const SizedBox(height: 30),
            _buildTabs(),
            const SizedBox(height: 16),
            selectedTabIndex == 0
                ? _buildPopularList(deviceWidth)
                : Column(
                  children: displayedList.map(buildVerticalCard).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: MediaQuery.sizeOf(context).width * 0.25,
      children: [
        Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color.fromRGBO(111, 119, 137, 1),
                  size: 30,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        Text(
          'Home',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(111, 119, 137, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentLocation ?? 'Fetching location...',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTabButton('Popular', 0),
        _buildTabButton('Hidden Gems', 1),
      ],
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 10,
              margin: const EdgeInsets.only(top: 5),
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildPopularList(double deviceWidth) {
    List<Place> displayedList = popularPlaces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: PageView.builder(
            controller: _popularListController,
            itemCount: displayedList.length,
            onPageChanged:
                (index) => setState(() => currentPopularIndex = index),
            itemBuilder:
                (context, index) =>
                    buildHorizontalCard(displayedList[index], deviceWidth),
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicators(displayedList.length),
        const SizedBox(height: 30),
        Text(
          'Crowd Insights',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 16),
        ...displayedList.map(
          (place) => buildCrowdBar(place.title, place.crowd),
        ),
      ],
    );
  }

  Widget _buildPageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        bool isActive = index == currentPopularIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color:
                isActive ? const Color.fromARGB(255, 38, 70, 83) : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 20, right: 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 38, 70, 83),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavIcon(Icons.home_outlined, 0),
            _buildBottomNavIcon(Icons.search, 1),
            _buildBottomNavIcon(CupertinoIcons.compass, 2),
            _buildBottomNavIcon(Icons.directions_walk, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedBottomIndex = index),
      child: Icon(
        icon,
        color: selectedBottomIndex == index ? Colors.white : Colors.white70,
        size: index == selectedBottomIndex ? 28 : 22,
      ),
    );
  }

  Widget buildHorizontalCard(Place place, double screenWidth) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go('/place', extra: place);
      },
      child: Container(
        width: screenWidth * 0.6,
        margin: const EdgeInsets.only(right: 5, left: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.fromARGB(255, 38, 70, 83)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: place.images[0],
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).height * 0.2,
                width: double.infinity,
                placeholder:
                    (context, url) => Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            place.location.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        '4.8',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVerticalCard(Place place) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go('/place', extra: place);
      },
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.3,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color.fromARGB(255, 38, 70, 83)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: place.images[0],
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).height * 0.2,
                width: double.infinity,
                placeholder:
                    (context, url) => Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              place.location.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 2),
                          Text(
                            '4.5',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Icon(
                        Icons.bookmark_border,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCrowdBar(String label, int percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percent%',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
