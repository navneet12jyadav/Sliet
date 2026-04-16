import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/placement_model.dart';

class PlacementTab extends StatelessWidget {
  const PlacementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placement Hub', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
        automaticallyImplyLeading: false, // Hides the back button
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('placements').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading insights'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final insights = snapshot.data!.docs.map((doc) => PlacementInsight.fromFirestore(doc)).toList();

          if (insights.isEmpty) {
            return const Center(child: Text('No placement insights added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Company and Role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            insight.company,
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          Chip(
                            label: Text(insight.role, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Alumni Info
                      Text(
                        '${insight.alumniName} (Batch of ${insight.batch})',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      // The Advice
                      Text(
                        '💡 Advice:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.advice,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}