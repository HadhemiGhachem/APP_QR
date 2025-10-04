import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> uploadExcel(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-excel'));
    request.files.add(await http.MultipartFile.fromPath('excel_file', file.path));
    var response = await request.send();
    final data = await response.stream.bytesToString();
    return json.decode(data);
  }

  static Future<Map<String, dynamic>> generateQRCodes(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/generate-qrcodes'));
    request.files.add(await http.MultipartFile.fromPath('excel_file', file.path));
    var response = await request.send();
    final data = await response.stream.bytesToString();
    return json.decode(data);
  }

  static Future<Map<String, dynamic>> uploadNotes(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-notes'));
    request.files.add(await http.MultipartFile.fromPath('excel_file', file.path));
    var response = await request.send();
    final data = await response.stream.bytesToString();
    return json.decode(data);
  }

  static Future<http.Response> generatePDF(List<Map<String, dynamic>> qrcodes) async {
    return await http.post(
      Uri.parse('$baseUrl/generate-pdf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qrcodes': qrcodes}),
    );
  }
}
