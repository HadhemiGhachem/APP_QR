import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/qr_code_item.dart';
import '../services/api_service.dart';
import 'qr_codes_screen.dart';

class ExcelScreen extends StatefulWidget {
  const ExcelScreen({super.key});

  @override
  State<ExcelScreen> createState() => _ExcelScreenState();
}

class _ExcelScreenState extends State<ExcelScreen> {
  List<List<dynamic>> excelData = [];
  List<QRCodeItem> qrCodes = [];
  File? selectedFile;
  String status = '';
  bool isLoading = false;

  Future<void> pickExcelFile() async {
    setState(() { isLoading = true; status = 'Sélection du fichier...'; });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null) {
        setState(() { status = 'Aucun fichier sélectionné'; isLoading = false; });
        return;
      }
      selectedFile = File(result.files.single.path!);
      final response = await ApiService.uploadExcel(selectedFile!);
      if (response['data'] != null) {
        excelData = List<List<dynamic>>.from(
          response['data'].map((row) => List<dynamic>.from(row))
        );
        status = 'Fichier chargé avec succès';
      } else {
        status = response['error'] ?? 'Erreur upload';
      }
    } catch (e) {
      status = 'Erreur : $e';
    } finally { setState(() { isLoading = false; }); }
  }

  Future<void> generateQRCodes() async {
    if (selectedFile == null) { setState(() { status = 'Sélectionnez un fichier d’abord'; }); return; }
    setState(() { isLoading = true; status = 'Génération des QR codes...'; });
    try {
      final response = await ApiService.generateQRCodes(selectedFile!);
      if (response['qrcodes'] != null) {
        qrCodes = (response['qrcodes'] as List)
            .map((e) => QRCodeItem.fromJson(e))
            .toList();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QRCodesScreen(qrCodes: qrCodes)),
        );
      } else {
        status = response['error'] ?? 'Erreur génération QR';
      }
    } catch (e) { status = 'Erreur : $e'; }
    finally { setState(() { isLoading = false; }); }
  }

  Future<void> uploadNotes() async {
    if (selectedFile == null) { setState(() { status = 'Sélectionnez un fichier d’abord'; }); return; }
    setState(() { isLoading = true; status = 'Import des notes...'; });
    try {
      final response = await ApiService.uploadNotes(selectedFile!);
      if (response['results'] != null) {
        status = 'Notes importées avec succès !';
        for (var r in response['results']) { print(r); }
      } else {
        status = response['error'] ?? 'Erreur import notes';
      }
    } catch (e) { status = 'Erreur : $e'; }
    finally { setState(() { isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin QR Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : pickExcelFile,
              child: Text(isLoading ? 'Chargement...' : 'Sélectionner & Uploader Excel'),
            ),
            const SizedBox(height: 8),
            Text(status, style: TextStyle(color: status.contains('Erreur') ? Colors.red : Colors.green)),
            const SizedBox(height: 16),
            if (excelData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: excelData[0].map((h) => DataColumn(label: Text(h.toString()))).toList(),
                    rows: excelData.skip(1).map((row) {
                      return DataRow(cells: row.map((c) => DataCell(Text(c.toString()))).toList());
                    }).toList(),
                  ),
                ),
              ),
            if (excelData.isNotEmpty)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : generateQRCodes,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Générer QR Codes'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : uploadNotes,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Importer Notes'),
                  ),
                ],
              ),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
