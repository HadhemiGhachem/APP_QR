class Student {
  final String id;
  final String exam;
  final String examDate;
  final String firstName;
  final String lastName;
  final String cin;
  final String qrCode;
  final String NINSCRI ;
  double? note; 

  Student({
    required this.id,
    required this.exam,
    required this.examDate,
    required this.firstName,
    required this.lastName,
    required this.cin,
    required this.qrCode,
    required this.NINSCRI,
    this.note, // Ajouté ici

  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(), 
      exam: json['exam']?.toString() ?? '',
      examDate: json['exam_date']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      cin: json['cin']?.toString() ?? '',
      NINSCRI: json['numero_inscri']?.toString() ?? '',
      qrCode: json['qrcode']?.toString() ?? '',
    );
  }
}
