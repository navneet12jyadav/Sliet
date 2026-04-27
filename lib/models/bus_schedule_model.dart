class BusRoute {
  final String routeId;
  final String destination;
  final List<String> timings;

  BusRoute({
    required this.routeId,
    required this.destination,
    required this.timings,
  });

  factory BusRoute.fromMap(Map<String, dynamic> data) {
    return BusRoute(
      routeId: data['routeId'] ?? '',
      destination: data['destination'] ?? '',
      timings: List<String>.from(data['timings'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'routeId': routeId, 'destination': destination, 'timings': timings};
  }
}

class BusStop {
  final String id;
  final String stopName;
  final List<BusRoute> routes;

  BusStop({required this.id, required this.stopName, required this.routes});

  factory BusStop.fromFirestore(Map<String, dynamic> data, String id) {
    final routesList = (data['routes'] as List<dynamic>? ?? []);
    return BusStop(
      id: id,
      stopName: data['stopName'] ?? '',
      routes: routesList
          .map((r) => BusRoute.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
