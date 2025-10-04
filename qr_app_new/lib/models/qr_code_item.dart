class QRCodeItem {
  final String hash;
  final String qrcode;
  final String studentId;
  final String firstName;
  final String lastName;
  final String cin;
  final String exam;
  final String examDate;
  final String numeroInscri;

  QRCodeItem({
    required this.hash,
    required this.qrcode,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.cin,
    required this.exam,
    required this.examDate,
    required this.numeroInscri,
  });

  factory QRCodeItem.fromJson(Map<String, dynamic> json) {
    return QRCodeItem(
      hash: json['hash']?.toString() ?? '',
      qrcode: json['qrcode']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      firstName: json['firstname']?.toString() ?? '',
      lastName: json['lastname']?.toString() ?? '',
      cin: json['cin']?.toString() ?? '',
      exam: json['exam']?.toString() ?? '',
      examDate: json['exam_date']?.toString() ?? '',
      numeroInscri: json['numero_inscri']?.toString() ?? '',
    );
  }
}
