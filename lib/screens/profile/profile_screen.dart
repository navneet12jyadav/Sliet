import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/hostel_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Profile not found'));
        }
        return _ProfileContent(user: user);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final AppUser user;

  const _ProfileContent({required this.user});

  String get _hostel {
    if (user.hostelNo?.isNotEmpty == true) return user.hostelNo!;
    return HostelUtils.assignHostel(user.registrationNo);
  }

  int get _completionPercent {
    int filled = 0;
    final fields = [
      user.name,
      user.registrationNo,
      user.fathersName,
      user.personalEmail,
      user.phoneNo,
      user.course,
      user.branch,
      user.year,
      user.hostelNo,
    ];
    for (final f in fields) {
      if (f != null && f.isNotEmpty) filled++;
    }
    return ((filled / fields.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildCompletionIndicator(context),
        const SizedBox(height: 16),
        _buildIdentityCard(context),
        const SizedBox(height: 16),
        _buildDetailsSection(context),
        const SizedBox(height: 16),
        _buildSettingsSection(context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.deepPurple[200],
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.registrationNo,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 11, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator(BuildContext context) {
    final pct = _completionPercent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Completion',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$pct%',
                    style: GoogleFonts.poppins(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SLIET',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.school, color: Colors.white70, size: 28),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Digital Identity Card',
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 12),
              ),
              const Divider(color: Colors.white30, height: 24),
              _idRow('Name', user.name),
              _idRow('Reg. No.', user.registrationNo),
              _idRow('Course', user.course ?? 'N/A'),
              _idRow('Branch', user.branch ?? 'N/A'),
              _idRow('Year', user.year ?? 'N/A'),
              _idRow('Hostel', _hostel),
              if (user.roomNo?.isNotEmpty == true)
                _idRow('Room', user.roomNo!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Details',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              _detailTile(Icons.person, "Father's Name",
                  user.fathersName ?? 'Not added'),
              _detailTile(
                  Icons.email, 'Personal Email', user.personalEmail ?? 'N/A'),
              _detailTile(Icons.email_outlined, 'SLIET Email',
                  user.slietEmail ?? 'N/A'),
              _detailTile(Icons.phone, 'Phone', user.phoneNo ?? 'N/A'),
              _detailTile(Icons.cake, 'Date of Birth', user.dob ?? 'N/A'),
              _detailTile(Icons.home, 'Address', user.address ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepPurple, size: 22),
      title: Text(label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      dense: true,
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: Colors.deepPurple),
              title: Text('Notification Preferences',
                  style: GoogleFonts.poppins()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('Logout',
                  style: GoogleFonts.poppins(color: Colors.red)),
              onTap: () async {
                await AuthService().logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
