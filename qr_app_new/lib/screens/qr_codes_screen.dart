import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../models/qr_code_item.dart';
import '../services/api_service.dart';

class QRCodesScreen extends StatefulWidget {
  final List<QRCodeItem> qrCodes;
  const QRCodesScreen({required this.qrCodes, super.key});

  @override
  State<QRCodesScreen> createState() => _QRCodesScreenState();
}

class _QRCodesScreenState extends State<QRCodesScreen> {
  bool isGeneratingPDF = false;

  Future<void> generatePDF() async {
    setState(() { isGeneratingPDF = true; });
    try {
      final qrcodes = widget.qrCodes.map((qr) => {
        'student_id': qr.studentId,
        'nom': qr.firstName,
        'prenom': qr.lastName,
        'cin': qr.cin,
        'numero_inscri': qr.numeroInscri,
        'exam': qr.exam,
        'exam_date': qr.examDate,
        'qrcode': qr.qrcode,
      }).toList();
      final response = await ApiService.generatePDF(qrcodes);
      if (response.statusCode == 200 && response.headers['content-type']?.contains('pdf') == true) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/qrcodes.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur PDF : ${response.body}')),
        );
      }
    } catch (e) { print('Erreur PDF : $e'); }
    finally { setState(() { isGeneratingPDF = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Codes')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.qrCodes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9
              ),
              itemBuilder: (context, index) {
                final qr = widget.qrCodes[index];
                Uint8List bytes;
                try { bytes = base64Decode(qr.qrcode); } catch (_) { bytes = Uint8List(0); }
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${qr.firstName} ${qr.lastName}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('CIN: ${qr.cin}'),
                      const SizedBox(height: 8),
                      bytes.isNotEmpty ? Image.memory(bytes, width: 100, height: 100) : const Text('QR invalide', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: isGeneratingPDF ? null : generatePDF,
            child: isGeneratingPDF ? const CircularProgressIndicator(color: Colors.white) : const Text('Générer PDF'),
          ),
        ],
      ),
    );
  }
}
