// Auto-assign hostel based on registration number
// Boys hostels: BH-1 through BH-10
// Girls hostels: GH-1 through GH-5
class HostelUtils {
  static String assignHostel(String registrationNo) {
    final cleaned = registrationNo.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 3) return 'BH-1';

    final lastThree = int.tryParse(cleaned.substring(cleaned.length - 3)) ?? 0;
    final hostelNum = (lastThree % 15) + 1;
    if (hostelNum <= 10) {
      return 'BH-$hostelNum';
    } else {
      return 'GH-${hostelNum - 10}';
    }
  }

  static bool isBoysHostel(String hostel) => hostel.startsWith('BH');
  static bool isGirlsHostel(String hostel) => hostel.startsWith('GH');

  static const List<String> boysHostels = [
    'BH-1', 'BH-2', 'BH-3', 'BH-4', 'BH-5',
    'BH-6', 'BH-7', 'BH-8', 'BH-9', 'BH-10',
  ];
  static const List<String> girlsHostels = [
    'GH-1', 'GH-2', 'GH-3', 'GH-4', 'GH-5',
  ];
  static List<String> get allHostels => [...boysHostels, ...girlsHostels];
}
