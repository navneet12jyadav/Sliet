import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/data_controller.dart';
import '../../models/bus_schedule_model.dart';

class BusScheduleScreen extends ConsumerWidget {
  const BusScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(busScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bus Schedule',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: routesAsync.when(
        data: (routes) => _buildRouteList(context, routes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading schedules: $e')),
      ),
    );
  }

  Widget _buildRouteList(BuildContext context, List<BusRoute> routes) {
    if (routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No bus schedules available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routes.length,
      itemBuilder: (context, index) => _RouteCard(route: routes[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Card for a single bus route
// ---------------------------------------------------------------------------
class _RouteCard extends StatelessWidget {
  final BusRoute route;

  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.routeName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (route.description.isNotEmpty)
                        Text(
                          route.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (route.timings.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Departures',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: route.timings
                    .map((t) => _TimingChip(timing: t))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimingChip extends StatelessWidget {
  final BusTiming timing;

  const _TimingChip({required this.timing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            timing.departureTime,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          if (timing.destination.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '→ ${timing.destination}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
