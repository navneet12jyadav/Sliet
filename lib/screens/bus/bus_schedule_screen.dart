import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/data_controller.dart';
import '../../models/bus_schedule_model.dart';

class BusScheduleScreen extends ConsumerWidget {
  const BusScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busAsync = ref.watch(busSchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: busAsync.when(
        data: (stops) {
          if (stops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No bus schedules available',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stops.length,
            itemBuilder: (context, index) => _BusStopCard(stop: stops[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BusStopCard extends StatelessWidget {
  final BusStop stop;

  const _BusStopCard({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  stop.stopName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (stop.routes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No routes available for this stop.',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          else
            ...stop.routes.map((route) => _RouteRow(route: route)),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final BusRoute route;

  const _RouteRow({required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus,
                  color: Colors.deepPurple, size: 18),
              const SizedBox(width: 8),
              Text(
                route.destination,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: route.timings.map((t) => _TimingChip(time: t)).toList(),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

class _TimingChip extends StatelessWidget {
  final String time;

  const _TimingChip({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          color: Colors.deepPurple,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
