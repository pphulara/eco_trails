import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Place {
  final String title;
  final LatLng location;
  final String description;
  final int crowd;
  final double rating;
  final bool isPopular;
  final bool isHiddenGem;
  final List<String> images;

  Place({
    required this.title,
    required this.location,
    required this.description,
    required this.crowd,
    required this.rating,
    required this.isPopular,
    required this.isHiddenGem,
    required this.images,
  });

  factory Place.fromFirestore(Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint;
    return Place(
      title: data['name'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      description: data['description'] ?? '',
      crowd: data['crowd'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      isPopular: data['isPopular'] ?? false,
      isHiddenGem: data['isHiddenGem'] ?? false,
      images: List<String>.from(data['multiple images'] ?? []),
    );
  }
}
