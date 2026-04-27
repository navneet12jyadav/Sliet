import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../bus/bus_schedule_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Profile not found.'));
        }
        return _ProfileContent(user: user);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final AppUser user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ----------------------------------------------------------------
        // Digital ID Card
        // ----------------------------------------------------------------
        _DigitalIdCard(user: user),

        const SizedBox(height: 24),

        // ----------------------------------------------------------------
        // Details section
        // ----------------------------------------------------------------
        Text(
          'Student Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _infoTile(Icons.person, 'Full Name', user.name),
        _infoTile(
          Icons.badge,
          'Registration No.',
          user.registrationNo,
          copyable: true,
          context: context,
        ),
        _infoTile(Icons.school, 'Course', user.course ?? '—'),
        _infoTile(Icons.book, 'Branch', user.branch ?? '—'),
        _infoTile(Icons.timeline, 'Admission Year', user.year ?? '—'),
        _infoTile(Icons.apartment, 'Hostel', user.hostelNo ?? '—'),
        _infoTile(Icons.door_front_door, 'Room No.', user.roomNo ?? '—'),
        _infoTile(Icons.phone, 'Phone', user.phoneNo ?? '—'),
        _infoTile(Icons.email, 'Personal Email', user.personalEmail ?? '—'),
        _infoTile(Icons.school_outlined, 'SLIET Email', user.slietEmail ?? '—'),
        _infoTile(Icons.cake, 'Date of Birth', user.dob ?? '—'),

        const SizedBox(height: 24),

        // ----------------------------------------------------------------
        // Quick links
        // ----------------------------------------------------------------
        Text(
          'Quick Links',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.directions_bus,
              color: Colors.deepPurple,
            ),
            title: Text('Bus Schedule', style: GoogleFonts.poppins()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BusScheduleScreen()),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ----------------------------------------------------------------
        // Logout
        // ----------------------------------------------------------------
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: Text('Log Out', style: GoogleFonts.poppins(fontSize: 16)),
          onPressed: () async => await AuthService().logOut(),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    bool copyable = false,
    BuildContext? context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          dense: true,
          leading: Icon(icon, size: 20, color: Colors.deepPurple),
          title: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          subtitle: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: copyable && context != null
              ? IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Digital ID Card widget
// ---------------------------------------------------------------------------
class _DigitalIdCard extends StatelessWidget {
  final AppUser user;

  const _DigitalIdCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: logo + APEX label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APEX',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'Student Identity Card',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Student info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.registrationNo,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 12),

            // Bottom details grid
            Row(
              children: [
                Expanded(
                  child: _idField('Course', user.course ?? '—'),
                ),
                Expanded(
                  child: _idField('Branch', user.branch ?? '—'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _idField('Hostel', user.hostelNo ?? '—'),
                ),
                Expanded(
                  child: _idField('Year', user.year ?? '—'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _idField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
