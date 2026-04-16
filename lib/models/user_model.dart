class AppUser {
  final String uid;
  final String name;
  final String role;
  final String registrationNo;
  final String? fathersName;
  final String? personalEmail;
  final String? slietEmail;
  final String? phoneNo;
  final String? address;
  final String? dob;
  final String? course;
  final String? branch; // <-- NEW FIELD
  final String? year;
  final String? hostelNo;
  final String? roomNo;

  AppUser({
    required this.uid, required this.name, required this.role, required this.registrationNo,
    this.fathersName, this.personalEmail, this.slietEmail, this.phoneNo,
    this.address, this.dob, this.course, this.branch, this.year, this.hostelNo, this.roomNo,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? 'SLIET User',
      role: data['role'] ?? 'student', 
      registrationNo: data['registrationNo'] ?? 'N/A',
      fathersName: data['fathersName'],
      personalEmail: data['personalEmail'],
      slietEmail: data['slietEmail'],
      phoneNo: data['phoneNo'],
      address: data['address'],
      dob: data['dob'],
      course: data['course'],
      branch: data['branch'], // <-- NEW FIELD
      year: data['year'],
      hostelNo: data['hostelNo'],
      roomNo: data['roomNo'],
    );
  }
}