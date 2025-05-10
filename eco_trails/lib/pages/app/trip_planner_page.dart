import 'package:eco_trails/models/place.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TripPlannerPage extends StatefulWidget {
  final Place place;

  const TripPlannerPage({super.key, required this.place});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final PageController _controller = PageController();
  int currentPage = 0;
  bool validatePage(int page) {
    switch (page) {
      case 0:
        return selectedTripDuration.isNotEmpty && (isFamily || isSolo);
      case 1:
        return interests.containsValue(true) &&
            adventureLevel > 0 &&
            ecoModes.containsValue(true);
      case 2:
        return selectedTransport.isNotEmpty &&
            ecoHomeStay > 0 &&
            dietary.containsValue(true);
      default:
        return false;
    }
  }

  void PlanSummary() {
    final _ = '''
Trip Duration: $selectedTripDuration
Trip Date: ${selectedDate.toLocal().toString().split(' ')[0]}
Group Type: ${isFamily ? 'Family' : 'Solo'}
Price Range: ₹${price.toStringAsFixed(0)}

Interests: ${interests.entries.where((e) => e.value).map((e) => e.key).join(', ')}
Adventure Level: $adventureLevel
Eco Mode: ${ecoModes.entries.firstWhere((e) => e.value, orElse: () => MapEntry('', false)).key}

Transport: $selectedTransport
Avoid Plastic: ${plasticAvoidance ? 'Yes' : 'No'}
Eco Homestay Rating: $ecoHomeStay
Health Notes: ${healthController.text}
Dietary: ${dietary.entries.firstWhere((e) => e.value, orElse: () => MapEntry('', false)).key}
''';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Trip Planned for ${widget.place.title}'),
            content: const Text('All preferences saved. Enjoy your journey!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Page 1
  String selectedTripDuration = '1 Day';
  DateTime selectedDate = DateTime.now();
  bool isFamily = false;
  bool isSolo = false;
  double price = 2000;

  // Page 2
  Map<String, bool> interests = {
    'Adventure': false,
    'Culture & Heritage': false,
    'Spirituality': false,
    'Photography': false,
  };
  double adventureLevel = 1;
  Map<String, bool> ecoModes = {
    'Eco Max': false,
    'Balance': false,
    'Comfort': false,
  };

  // Page 3
  String selectedTransport = 'Car';
  bool plasticAvoidance = true;
  double ecoHomeStay = 1;
  final TextEditingController healthController = TextEditingController();
  Map<String, bool> dietary = {
    'Vegan': false,
    'Vegetarian': false,
    'Non-Vegetarian': false,
    'Other': false,
  };

  void nextPage() {
    if (validatePage(currentPage)) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Widget detailContainer({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget page1() {
    return plannerCard([
      detailContainer(
        title: 'Trip Duration',
        child: dropdownTile(
          '',
          ['1 Day', '4 Day', '7 Day'],
          selectedTripDuration,
          (val) => setState(() => selectedTripDuration = val),
        ),
      ),
      detailContainer(
        title: 'Trip Date',
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              onPrimary: Color.fromARGB(255, 0, 191, 255),
              primary: Color.fromARGB(204, 255, 255, 255),
            ),
          ),
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2027),
            onDateChanged: (picked) {
              setState(() {
                selectedDate = picked;
              });
            },
          ),
        ),
      ),

      detailContainer(
        title: 'Group Type',
        child: Wrap(
          spacing: 10,
          children:
              ['Family', 'Solo'].map((option) {
                bool isSelected =
                    (option == 'Family' && isFamily) ||
                    (option == 'Solo' && isSolo);
                return ChoiceChip(
                  label: Text(option, style: GoogleFonts.poppins()),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      isFamily = option == 'Family';
                      isSolo = option == 'Solo';
                    });
                  },
                );
              }).toList(),
        ),
      ),
      detailContainer(
        title: 'Price Range',
        child: sliderTile(
          "Rs",
          price,
          0,
          10000,
          (val) => setState(() => price = val),
        ),
      ),
    ]);
  }

  Widget page2() {
    return plannerCard([
      detailContainer(
        title: 'Interest',
        child: checkboxList(
          'Interest',
          interests,
          (label, value) => setState(() => interests[label] = value),
        ),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Adventure Level',
        child: Wrap(
          spacing: 10,
          children: List.generate(5, (index) {
            final level = index + 1;
            return ChoiceChip(
              label: Text(level.toString()),
              selected: adventureLevel == level.toDouble(),
              onSelected: (selected) {
                if (selected) {
                  setState(() => adventureLevel = level.toDouble());
                }
              },
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Eco Mode',
        child: Wrap(
          spacing: 10,
          children:
              ecoModes.keys.map((mode) {
                return ChoiceChip(
                  label: Text(mode),
                  selected: ecoModes[mode] == true,
                  onSelected: (_) {
                    setState(() {
                      ecoModes.updateAll((key, value) => false);
                      ecoModes[mode] = true;
                    });
                  },
                );
              }).toList(),
        ),
      ),
    ]);
  }

  Widget page3() {
    return plannerCard([
      detailContainer(
        title: 'Transport Mode',
        child: Wrap(
          spacing: 10,
          children:
              ['Car', 'Bus', 'Bike'].map((mode) {
                return ChoiceChip(
                  label: Text(mode),
                  selected: selectedTransport == mode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedTransport = mode);
                    }
                  },
                );
              }).toList(),
        ),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Plastic Avoidance',
        child: SwitchListTile(
          title: const Text('Avoid Plastic Usage'),
          value: plasticAvoidance,
          onChanged: (val) => setState(() => plasticAvoidance = val),
        ),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Eco Homestays',
        child: Wrap(
          spacing: 10,
          children: List.generate(5, (index) {
            final level = index + 1;
            return ChoiceChip(
              label: Text(level.toString()),
              selected: ecoHomeStay == level.toDouble(),
              onSelected: (selected) {
                if (selected) {
                  setState(() => ecoHomeStay = level.toDouble());
                }
              },
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Health Condition',
        child: textFieldTile('Health Notes', healthController),
      ),
      const SizedBox(height: 8),
      detailContainer(
        title: 'Dietary Preference',
        child: Wrap(
          spacing: 10,
          children:
              dietary.keys.map((diet) {
                return ChoiceChip(
                  label: Text(diet),
                  selected: dietary[diet] == true,
                  onSelected: (selected) {
                    setState(() {
                      dietary.updateAll((key, value) => false);
                      dietary[diet] = selected;
                    });
                  },
                );
              }).toList(),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 251, 244),
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                currentPage > 0
                    ? IconButton(
                      onPressed: previousPage,
                      icon: const Icon(Icons.arrow_back),
                    )
                    : IconButton(
                      onPressed: () {
                        (context).go('/place', extra: widget.place);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                Text(
                  'Planner',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 119, 137, 1),
                  ),
                ),
                TextButton(
                  onPressed:
                      currentPage == 2
                          ? () {
                            if (validatePage(2)) {
                              PlanSummary();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please complete all fields'),
                                ),
                              );
                            }
                          }
                          : nextPage,

                  child: Row(
                    children: [
                      Text(
                        currentPage == 2 ? 'Submit' : 'Next',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => currentPage = i),
                children: [page1(), page2(), page3()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget plannerCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(64, 147, 183, 172),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(child: Column(children: children)),
    );
  }

  Widget dropdownTile(
    String label,
    List<String> items,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          items:
              items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }

  Widget tileWithButton(
    String title,
    String value,
    Future<void> Function() onPressed,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: ElevatedButton(
        onPressed: onPressed, // now accepts async
        child: Text('Select'),
      ),
    );
  }

  Widget toggleCheckbox(
    String label,
    Map<String, bool> options,
    Function(String, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: 10,
          children:
              options.entries
                  .map(
                    (e) => FilterChip(
                      label: Text(e.key),
                      selected: e.value,
                      onSelected: (val) => onChanged(e.key, val),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget sliderTile(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(0)}"),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget checkboxList(
    String label,
    Map<String, bool> items,
    Function(String, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: 10,
          children:
              items.entries
                  .map(
                    (e) => FilterChip(
                      label: Text(e.key),
                      selected: e.value,
                      onSelected: (val) => onChanged(e.key, val),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget switchTile(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Switch(value: value, onChanged: onChanged)],
    );
  }

  Widget textFieldTile(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label), TextField(controller: controller)],
    );
  }
}
