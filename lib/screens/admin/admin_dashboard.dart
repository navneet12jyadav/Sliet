import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/timetable_model.dart';
import '../../models/holiday_model.dart';
import '../../utils/hostel_utils.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async => AuthService().logOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Timetable'),
            Tab(text: 'Mess'),
            Tab(text: 'Holidays'),
            Tab(text: 'Bus'),
            Tab(text: 'Notify'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TimetableManagerTab(),
          _MessManagerTab(),
          _HolidayManagerTab(),
          _BusManagerTab(),
          _NotifyTab(),
        ],
      ),
    );
  }
}

// ── Timetable Manager ──────────────────────────────────────────────────────
class _TimetableManagerTab extends StatefulWidget {
  const _TimetableManagerTab();

  @override
  State<_TimetableManagerTab> createState() => _TimetableManagerTabState();
}

class _TimetableManagerTabState extends State<_TimetableManagerTab> {
  final _nameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  int _dayNumber = 1;
  String _type = 'Theory';
  int _semester = 1;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _instructorCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final entry = TimetableClass(
        id: '',
        name: _nameCtrl.text.trim(),
        type: _type,
        startTime: _startCtrl.text.trim(),
        endTime: _endCtrl.text.trim(),
        room: _roomCtrl.text.trim(),
        instructor: _instructorCtrl.text.trim(),
        semester: _semester,
        dayNumber: _dayNumber,
      );
      await FirebaseFirestore.instance
          .collection('timetable')
          .add(entry.toFirestore());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class added successfully!')),
        );
        _nameCtrl.clear();
        _roomCtrl.clear();
        _instructorCtrl.clear();
        _startCtrl.clear();
        _endCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Class Entry',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field(_nameCtrl, 'Subject Name'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: _inputDecoration('Type'),
                  items: ['Theory', 'Lab']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _dayNumber,
                  decoration: _inputDecoration('Day No.'),
                  items: List.generate(7, (i) => i + 1)
                      .map((d) =>
                          DropdownMenuItem(value: d, child: Text('Day $d')))
                      .toList(),
                  onChanged: (v) => setState(() => _dayNumber = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(_startCtrl, 'Start Time (e.g. 09:00)')),
              const SizedBox(width: 12),
              Expanded(child: _field(_endCtrl, 'End Time (e.g. 10:00)')),
            ],
          ),
          const SizedBox(height: 12),
          _field(_roomCtrl, 'Room'),
          const SizedBox(height: 12),
          _field(_instructorCtrl, 'Instructor'),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _semester,
            decoration: _inputDecoration('Semester'),
            items: List.generate(8, (i) => i + 1)
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text('Semester $s')))
                .toList(),
            onChanged: (v) => setState(() => _semester = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Class'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// ── Mess Manager ───────────────────────────────────────────────────────────
class _MessManagerTab extends StatefulWidget {
  const _MessManagerTab();

  @override
  State<_MessManagerTab> createState() => _MessManagerTabState();
}

class _MessManagerTabState extends State<_MessManagerTab> {
  String _hostelId = HostelUtils.boysHostels.first;
  final _dateCtrl = TextEditingController();
  final _breakfastCtrl = TextEditingController();
  final _lunchCtrl = TextEditingController();
  final _dinnerCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _breakfastCtrl.dispose();
    _lunchCtrl.dispose();
    _dinnerCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_dateCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final menuEntry = {
        'date': _dateCtrl.text.trim(),
        'meals': [
          {
            'type': 'Breakfast',
            'startTime': '07:30',
            'endTime': '09:00',
            'items': _breakfastCtrl.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          },
          {
            'type': 'Lunch',
            'startTime': '12:30',
            'endTime': '14:00',
            'items': _lunchCtrl.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          },
          {
            'type': 'Dinner',
            'startTime': '19:00',
            'endTime': '21:00',
            'items': _dinnerCtrl.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          },
        ],
      };

      final ref = FirebaseFirestore.instance.collection('mess').doc(_hostelId);
      await ref.set({
        'hostelId': _hostelId,
        'hostelName': _hostelId,
        'hostelType':
            HostelUtils.isBoysHostel(_hostelId) ? 'Boys' : 'Girls',
        'menus': FieldValue.arrayUnion([menuEntry]),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Mess Menu',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _hostelId,
            decoration: _dec('Hostel'),
            items: HostelUtils.allHostels
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (v) => setState(() => _hostelId = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateCtrl,
            decoration: _dec('Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _breakfastCtrl,
            decoration: _dec('Breakfast items (comma separated)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lunchCtrl,
            decoration: _dec('Lunch items (comma separated)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dinnerCtrl,
            decoration: _dec('Dinner items (comma separated)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Menu'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
}

// ── Holiday Manager ────────────────────────────────────────────────────────
class _HolidayManagerTab extends StatefulWidget {
  const _HolidayManagerTab();

  @override
  State<_HolidayManagerTab> createState() => _HolidayManagerTabState();
}

class _HolidayManagerTabState extends State<_HolidayManagerTab> {
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _type = 'National';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_nameCtrl.text.trim().isEmpty || _dateCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final holiday = Holiday(
        id: '',
        date: DateTime.parse(_dateCtrl.text.trim()),
        name: _nameCtrl.text.trim(),
        type: _type,
      );
      await FirebaseFirestore.instance
          .collection('holidays')
          .add(holiday.toFirestore());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holiday added!')),
        );
        _nameCtrl.clear();
        _dateCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Holiday',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: _dec('Holiday Name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateCtrl,
            decoration: _dec('Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: _dec('Type'),
            items: ['National', 'College', 'Regional']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _add,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Holiday'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
}

// ── Bus Schedule Manager ───────────────────────────────────────────────────
class _BusManagerTab extends StatefulWidget {
  const _BusManagerTab();

  @override
  State<_BusManagerTab> createState() => _BusManagerTabState();
}

class _BusManagerTabState extends State<_BusManagerTab> {
  final _stopCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _routeIdCtrl = TextEditingController();
  final _timingsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _stopCtrl.dispose();
    _destCtrl.dispose();
    _routeIdCtrl.dispose();
    _timingsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_stopCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final timings = _timingsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final route = {
        'routeId': _routeIdCtrl.text.trim(),
        'destination': _destCtrl.text.trim(),
        'timings': timings,
      };

      final ref = FirebaseFirestore.instance
          .collection('busSchedules')
          .doc(_stopCtrl.text.trim());

      await ref.set({
        'stopName': _stopCtrl.text.trim(),
        'routes': FieldValue.arrayUnion([route]),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus schedule updated!')),
        );
        _destCtrl.clear();
        _routeIdCtrl.clear();
        _timingsCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Bus Schedule',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field(_stopCtrl, 'Stop Name (used as doc ID)'),
          const SizedBox(height: 12),
          _field(_routeIdCtrl, 'Route ID'),
          const SizedBox(height: 12),
          _field(_destCtrl, 'Destination'),
          const SizedBox(height: 12),
          _field(_timingsCtrl, 'Timings (comma separated, e.g. 08:00, 12:00)'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Route'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ── Notifications Tab ──────────────────────────────────────────────────────
class _NotifyTab extends StatefulWidget {
  const _NotifyTab();

  @override
  State<_NotifyTab> createState() => _NotifyTabState();
}

class _NotifyTabState extends State<_NotifyTab> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _type = 'general';
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': _type,
        'title': _titleCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
        'studentId': 'all',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent to all students!')),
        );
        _titleCtrl.clear();
        _msgCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Announcement',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: _dec('Notification Type'),
            items: [
              'general',
              'timetable_update',
              'cancellation',
              'holiday',
              'mess',
              'bus',
            ]
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleCtrl,
            decoration: _dec('Title'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _msgCtrl,
            decoration: _dec('Message'),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send),
              label: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send to All Students'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
}
