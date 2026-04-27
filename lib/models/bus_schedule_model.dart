import 'package:cloud_firestore/cloud_firestore.dart';

class BusTiming {
  final String departureTime;
  final String destination;

  BusTiming({required this.departureTime, required this.destination});

  factory BusTiming.fromMap(Map<String, dynamic> data) {
    return BusTiming(
      departureTime: data['departureTime'] ?? '',
      destination: data['destination'] ?? '',
    );
  }
}

class BusRoute {
  final String id;
  final String routeName;
  final String description;
  final List<BusTiming> timings;

  BusRoute({
    required this.id,
    required this.routeName,
    required this.description,
    required this.timings,
  });

  factory BusRoute.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusRoute(
      id: doc.id,
      routeName: data['routeName'] ?? '',
      description: data['description'] ?? '',
      timings: (data['timings'] as List<dynamic>? ?? [])
          .map((t) => BusTiming.fromMap(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
