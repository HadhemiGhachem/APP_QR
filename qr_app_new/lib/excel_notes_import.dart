import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

// void main() {
//   runApp(NotesExcelApp());
// }


class NotesExcelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Importer Notes Excel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: NotesExcelScreen(),
    );
  }
}

class NotesExcelScreen extends StatefulWidget {
  @override
  _NotesExcelScreenState createState() => _NotesExcelScreenState();
}

class _NotesExcelScreenState extends State<NotesExcelScreen> {
  List<List<dynamic>> _excelData = [];
  String _status = 'Aucun fichier chargé';
  bool _isLoading = false;

  // Fonction pour importer et lire le fichier Excel
  Future<void> _importExcelNotes() async {
    setState(() {
      _isLoading = true;
      _status = 'Sélection du fichier Excel des notes...';
      _excelData = [];
    });

    try {
      // Sélectionner un fichier Excel
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        setState(() {
          _status = 'Aucun fichier sélectionné';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun fichier sélectionné'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() => _status = 'Lecture du fichier Excel...');

      // Lire le fichier Excel
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Lire la première feuille
      var sheet = excel.tables.keys.first;
      var table = excel.tables[sheet];

      if (table == null || table.rows.isEmpty) {
        setState(() {
          _status = 'Erreur : Aucune donnée dans le fichier Excel';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : Aucune donnée dans le fichier Excel'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Extraire les données
      List<List<dynamic>> data = [];
      for (var row in table.rows) {
        List<dynamic> rowData = row.map((cell) => cell?.value ?? '').toList();
        data.add(rowData);
      }

      setState(() {
        _excelData = data;
        _status = 'Fichier Excel des notes chargé avec succès !';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fichier Excel des notes chargé avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Erreur lors de la lecture : $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importer et Afficher Notes Excel'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton pour importer
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text(_isLoading ? 'Chargement...' : 'Importer Fichier Notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _importExcelNotes,
            ),
            SizedBox(height: 16),
            // Statut
            Text(
              _status,
              style: TextStyle(
                color: _status.contains('Erreur') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            // Affichage du DataTable
            _isLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ),
                  )
                : _excelData.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.blue[50]),
                              columns: _excelData[0]
                                  .map((header) => DataColumn(
                                        label: Text(
                                          header.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[900]),
                                        ),
                                      ))
                                  .toList(),
                              rows: _excelData.skip(1).map((row) {
                                return DataRow(
                                  cells: row
                                      .map((cell) => DataCell(
                                            Text(
                                              cell.toString(),
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ))
                                      .toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: Text(
                            'Aucun fichier chargé. Veuillez importer un fichier Excel.',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}