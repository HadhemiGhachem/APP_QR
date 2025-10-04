import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// --- Votre Modèle QRCodeItem (Conservé) ---
class QRCodeItem {
  final String hash;
  final String qrcode;
  final String studentId;
  final String firstName;
  final String lastName;
  final String cin;
  final String exam;
  final String examDate;
  final String NINSCRI;
  double? note; 

  QRCodeItem({
    required this.hash,
    required this.qrcode,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.cin,
    required this.exam,
    required this.examDate,
    required this.NINSCRI,
    this.note,
  });

  factory QRCodeItem.fromJson(Map<String, dynamic> json) {
    return QRCodeItem(
      hash: json['hash']?.toString() ?? '',
      qrcode: json['qrcode']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      firstName: json['prenom']?.toString() ?? '',
      lastName: json['nom']?.toString() ?? '',
      cin: json['cin']?.toString() ?? '',
      exam: json['exam']?.toString() ?? '',
      examDate: json['exam_date']?.toString() ?? '',
      NINSCRI: json['numero_inscri']?.toString() ?? '',
      note: double.tryParse(json['note']?.toString() ?? ''), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_inscri': NINSCRI,
      'cin': cin,
      'nom': lastName,
      'prenom': firstName,
      'exam': exam,
      'exam_date': examDate,
      'note': note, 
    };
  }
}

void main() {
  runApp(const MyApp());
}

// --- Styles et Widgets Utilitaires pour le nouveau design ---

// Fonction pour obtenir l'icône
Widget _buildIcon(String iconName, {Color? color, double size = 24}) {
  IconData iconData;
  switch (iconName) {
    case 'upload_file': iconData = Icons.upload_file; break;
    case 'qr_code': iconData = Icons.qr_code; break;
    case 'assessment': iconData = Icons.assessment; break;
    case 'edit': iconData = Icons.edit; break;
    case 'delete': iconData = Icons.delete; break;
    case 'check_circle': iconData = Icons.check_circle; break;
    case 'error': iconData = Icons.error; break;
    case 'list_alt': iconData = Icons.list_alt; break;
    default: iconData = Icons.info;
  }
  return Icon(iconData, color: color, size: size);
}

// Widget de bouton d'action rapide (similaire à celui du Dashboard)
Widget _buildQuickActionButton(
  BuildContext context, 
  String title, 
  String iconName, 
  VoidCallback? onTap, 
  {Color? color, bool isActive = true}
) {
  final theme = Theme.of(context);
  final buttonColor = color ?? theme.primaryColor;
  
  return InkWell(
    onTap: isActive ? onTap : null,
    borderRadius: BorderRadius.circular(10),
    child: Card(
      margin: EdgeInsets.zero,
      color: isActive ? buttonColor.withOpacity(0.1) : Colors.grey.shade100,
      elevation: isActive ? 2 : 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? buttonColor.withOpacity(0.4) : Colors.grey.shade300)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(iconName, color: isActive ? buttonColor : Colors.grey.shade500, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isActive ? Colors.black : Colors.grey.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des Examens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExcelDisplayScreen(),
    );
  }
}

// --- Page d'Accueil Stylisée (Nom de classe: ExcelDisplayScreen) ---
class ExcelDisplayScreen extends StatefulWidget {
  @override
  _ExcelDisplayScreenState createState() => _ExcelDisplayScreenState(); // Nom de classe conservé
}

class _ExcelDisplayScreenState extends State<ExcelDisplayScreen> { // Nom de classe conservé
  // CONSERVATION DE VOS VARIABLES D'ÉTAT
  List<List<dynamic>> _excelData = [];
  List<QRCodeItem> _qrCodes = []; 
  String _status = '';
  bool _isLoading = false;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _status = 'Importez un fichier Excel pour commencer.';
  }

  // --- LOGIQUE (Vos fonctions initiales _uploadFile et _generateQRCode) ---
  
  // Fonction utilitaire pour les messages d'état
  void _showStatusSnackBar(String message, {Color color = Colors.green}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
      _status = 'Sélection du fichier...';
      _qrCodes = [];
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        setState(() {
          _status = 'Aucun fichier sélectionné';
          _isLoading = false;
        });
        _showStatusSnackBar('Aucun fichier sélectionné', color: Colors.grey);
        return;
      }

      File file = File(result.files.single.path!);
      _selectedFile = file;
      setState(() => _status = 'Upload de ${result.files.single.name} en cours...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/upload-excel'),
      );
      request.files.add(await http.MultipartFile.fromPath('excel_file', file.path));
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['data'] != null) {
        setState(() {
          _excelData = List<List<dynamic>>.from(
              jsonData['data'].map((row) => List<dynamic>.from(row)));
          _status = 'Fichier chargé. Prêt pour la génération des QR codes.';
          _isLoading = false;
        });
        _showStatusSnackBar('Fichier chargé avec succès !');
      } else {
        setState(() {
          _status = jsonData['error'] ??
              'Erreur lors de l\'upload (code ${response.statusCode})';
          _isLoading = false;
        });
        _showStatusSnackBar(_status, color: Colors.red);
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur de connexion ou de fichier : $e';
        _isLoading = false;
      });
      _showStatusSnackBar('Erreur : $e', color: Colors.red);
    }
  }

  Future<void> _generateQRCode() async {
    if (_selectedFile == null) {
      _showStatusSnackBar('Veuillez d\'abord importer un fichier Excel.', color: Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Génération des QR codes en cours...';
      _qrCodes = [];
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/generate-qrcodes'),
      );
      request.files.add(await http.MultipartFile.fromPath('excel_file', _selectedFile!.path));
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['qrcodes'] != null) {
        final List<QRCodeItem> generatedQRCodes = (jsonData['qrcodes'] as List)
            .map((e) => QRCodeItem.fromJson(e as Map<String, dynamic>))
            .toList();
            
        setState(() {
          _qrCodes = generatedQRCodes;
          _status = 'QR codes générés avec succès ! (${_qrCodes.length} étudiants)';
          _isLoading = false;
        });
        _showStatusSnackBar(_status);

        // Navigation vers l'écran des QR codes après succès
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodesScreen(qrCodes: _qrCodes),
          ),
        );

      } else {
        setState(() {
          _status = jsonData['error'] ??
              'Erreur lors de la génération (code ${response.statusCode})';
          _isLoading = false;
        });
        _showStatusSnackBar(_status, color: Colors.red);
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur de connexion lors de la génération : $e';
        _isLoading = false;
      });
      _showStatusSnackBar('Erreur : $e', color: Colors.red);
    }
  }
  
  void _navigateToNotesScreen() {
    if (_qrCodes.isEmpty) {
      _showStatusSnackBar("Veuillez d'abord générer les QR codes (étape 2).", color: Colors.orange);
      return;
    }
    // Assurez-vous d'envoyer la copie des données générées
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotesScreen(allStudents: _qrCodes)),
    );
  }

  // Fonction pour effacer l'état
  void _clearData() {
    setState(() {
      _selectedFile = null;
      _excelData = [];
      _qrCodes = [];
      _status = "Importez un fichier Excel pour commencer.";
      _isLoading = false;
    });
    _showStatusSnackBar('Données et fichier effacés.', color: Colors.red);
  }

  // --- WIDGETS DE DESIGN (Design du Dashboard) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Données d\'Examen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _buildIcon('delete', color: Colors.white),
            tooltip: 'Effacer les données',
            onPressed: _clearData,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des actions rapides (Design Dashboard)
            _buildQuickActionCards(context),
            
            const SizedBox(height: 30),
            
            // Indicateur de statut
            _buildStatusCard(context),

            const SizedBox(height: 30),

            // Titre de la liste
            Text(
              'Aperçu du Fichier Importé (${_excelData.length > 0 ? _excelData.length - 1 : 0} lignes)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Affichage des données
            _buildDataList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFileLoaded = _selectedFile != null;
    final bool isQRCodesGenerated = _qrCodes.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workflow Examen',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          children: [
            // 1. Importer
            _buildQuickActionButton(
              context, '1. Importer Excel', 'upload_file', _isLoading ? null : _uploadFile, 
              color: theme.primaryColor,
              isActive: !_isLoading,
            ),
            // 2. Générer QR
            _buildQuickActionButton(
              context, 
              '2. Générer QR Codes', 
              'qr_code', 
              (isFileLoaded && !_isLoading) ? _generateQRCode : null, 
              color: Colors.orange.shade700,
              isActive: isFileLoaded && !_isLoading,
            ),
            // 3. Voir les Notes
            _buildQuickActionButton(
              context, 
              '3. Voir les Notes', 
              'assessment', 
              isQRCodesGenerated && !_isLoading ? _navigateToNotesScreen : null, 
              color: Colors.teal,
              isActive: isQRCodesGenerated && !_isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    if (_isLoading) {
      icon = Icons.hourglass_top;
      color = Colors.blue;
    } else if (_qrCodes.isNotEmpty) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (_selectedFile != null) {
      icon = Icons.task_alt;
      color = Colors.orange;
    } else if (_status.contains('Erreur')) {
      icon = Icons.error;
      color = Colors.red;
    } else {
      icon = Icons.info;
      color = Colors.grey;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _isLoading 
              ? SizedBox(
                  width: 28, 
                  height: 28, 
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(color)),
                )
              : Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statut Actuel', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  Text(
                    _status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("Traitement des données... Veuillez patienter."),
      ));
    }
    if (_excelData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "Les données du fichier Excel importé apparaîtront ici.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
      );
    }
    
    // Affichage des données du tableau
    return Card(
      elevation: 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).primaryColor.withOpacity(0.1)),
          columns: _excelData[0]
              .map((header) => DataColumn(
                label: Text(
                  header.toString(), 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ))
              .toList(),
          rows: _excelData.skip(1).take(10).map((row) { // Limiter à 10 lignes pour l'aperçu
            return DataRow(
              cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- Page QRCodesScreen (Nom de classe conservé) ---

class QRCodesScreen extends StatefulWidget {
  final List<QRCodeItem> qrCodes;
  const QRCodesScreen({required this.qrCodes, super.key});

  @override
  _QRCodesScreenState createState() => _QRCodesScreenState();
}

class _QRCodesScreenState extends State<QRCodesScreen> {
  bool _isGeneratingPDF = false;

  Future<void> _generatePDF() async {
    final validQRCodes = widget.qrCodes.map((qr) => {
      'student_id': qr.studentId,
      'nom': qr.firstName,
      'prenom': qr.lastName,
      'cin': qr.cin,
      'numero_inscri': qr.NINSCRI,
      'exam': qr.exam,
      'exam_date': qr.examDate,
      'qrcode': qr.qrcode,
    }).toList();


    if (validQRCodes.isEmpty) return;

    setState(() => _isGeneratingPDF = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/generate-pdf'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qrcodes': validQRCodes}),
      );

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('application/pdf') == true) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/qrcodes.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF des QR Codes généré avec succès !')));
            await OpenFile.open(file.path);
        }
      } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la génération du PDF des QR Codes: ${response.statusCode}'), backgroundColor: Colors.red));
        }
        debugPrint('Erreur génération PDF: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur de connexion pour le PDF: $e'), backgroundColor: Colors.red));
      }
      debugPrint('Erreur génération PDF: $e');
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Codes Générés'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.qrCodes.isNotEmpty)
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "${widget.qrCodes[0].exam} - ${widget.qrCodes[0].examDate} (${widget.qrCodes.length} étudiants)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.qrCodes.isEmpty
                  ? const Center(
                        child: Text(
                          'Aucun QR code à afficher',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                  : GridView.builder(
                        itemCount: widget.qrCodes.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final qr = widget.qrCodes[index];
                          Uint8List bytes;
                          try {
                            bytes = base64Decode(qr.qrcode);
                          } catch (_) {
                            return Card(
                              color: Colors.red.shade50,
                              child: const Center(
                                child: Text('QR Code invalide',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            );
                          }

                          return Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${qr.studentId} - ${qr.lastName} ${qr.firstName}",
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text("CIN: ${qr.cin}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Image.memory(bytes, width: 100, height: 100),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            if (widget.qrCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPDF ? null : _generatePDF,
                  icon: _isGeneratingPDF 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(_isGeneratingPDF ? 'Génération...' : 'Générer la liste PDF des QR Codes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Page NotesScreen (Nom de classe conservé) ---
class NotesScreen extends StatefulWidget {
  final List<QRCodeItem> allStudents; 
  const NotesScreen({required this.allStudents, super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<QRCodeItem> _studentsWithNotes; 
  String _status = '';
  bool _isLoading = false;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    // Crée une copie profonde pour pouvoir modifier `note` localement
    _studentsWithNotes = widget.allStudents.map((item) => QRCodeItem(
      hash: item.hash,
      qrcode: item.qrcode,
      studentId: item.studentId,
      firstName: item.firstName,
      lastName: item.lastName,
      cin: item.cin,
      exam: item.exam,
      examDate: item.examDate,
      NINSCRI: item.NINSCRI,
      note: item.note, 
    )).toList();
    _status = 'Importez le fichier de notes pour cet examen.';
  }

  Future<void> _uploadNotesFile() async {
    setState(() {
      _isLoading = true;
      _status = 'Sélection du fichier de notes...';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        setState(() {
          _status = 'Aucun fichier sélectionné';
          _isLoading = false;
        });
        return;
      }

      File file = File(result.files.single.path!);
      setState(() => _status = 'Upload des notes en cours...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/upload-notes'),
      );
      request.files.add(await http.MultipartFile.fromPath('excel_file', file.path));
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['students'] != null) {
        
        final Map<String, double> notesMap = {};
        for (var studentData in (jsonData['students'] as List)) {
          String ninscri = studentData['numero_inscri']?.toString() ?? '';
          double? note = double.tryParse(studentData['note']?.toString() ?? '');
          
          if (ninscri.isNotEmpty && note != null) {
            notesMap[ninscri] = note;
          }
        }
        
        int notesUpdated = 0;
        // Mise à jour de la liste locale (_studentsWithNotes)
        for (var student in _studentsWithNotes) {
          if (notesMap.containsKey(student.NINSCRI)) {
            student.note = notesMap[student.NINSCRI]; 
            notesUpdated++;
          }
        }

        setState(() {
          // Filtrer seulement ceux qui ont une note pour l'affichage du tableau
          _studentsWithNotes = _studentsWithNotes.where((s) => s.note != null).toList();
          _status = 'Notes mises à jour avec succès pour $notesUpdated étudiants !';
          _isLoading = false;
        });
      } else {
        setState(() {
        final error = jsonData['error'] ?? 'Erreur lors de l\'upload (code ${response.statusCode})';
          _status = 'Erreur: $error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur : $e';
        _isLoading = false;
      });
    }
  }

  // FONCTION POUR GÉNÉRER LE PDF DES NOTES
  Future<void> _generateNotesPDF() async {
    if (_studentsWithNotes.isEmpty) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Veuillez d\'abord importer un fichier de notes.'), backgroundColor: Colors.orange),
          );
      }
      setState(() => _status = 'Aucun étudiant avec notes disponible.');
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
      _status = 'Génération du PDF des notes en cours...';
    });

    try {
      final notesData = _studentsWithNotes
          .where((s) => s.note != null) 
          .map((s) => s.toJson())
          .toList();

      if (notesData.isEmpty) {
        setState(() {
          _status = 'Aucune note valide à inclure dans le PDF.';
          _isGeneratingPDF = false;
        });
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aucune note valide à inclure dans le PDF.'), backgroundColor: Colors.orange),
            );
        }
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/generate-notes-pdf'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes': notesData}),
      );

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('application/pdf') == true) {
        final directory = await getApplicationDocumentsDirectory(); 
        final filePath = '${directory.path}/notes_relevee.pdf';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _status = 'PDF généré et sauvegardé avec succès !';
            _isGeneratingPDF = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF du Relevé de Notes généré et sauvegardé !')),
          );

          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur lors de l\'ouverture du PDF : ${result.message}')),
            );
          }
        }
      } else {
        final errorJson = jsonDecode(response.body);
        if (mounted) {
            setState(() {
                _status = errorJson['error'] ?? 'Erreur lors de la génération du PDF (Code ${response.statusCode})';
                _isGeneratingPDF = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_status, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
        }
        debugPrint('Erreur génération PDF: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
          setState(() {
              _status = 'Erreur lors de la génération du PDF : $e';
              _isGeneratingPDF = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
      }
      debugPrint('Erreur génération PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNotes = _studentsWithNotes.any((s) => s.note != null);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Notes'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur d'examen
            if (widget.allStudents.isNotEmpty)
              Card(
                color: Colors.teal.shade50,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      _buildIcon('list_alt', color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        "Examen: ${widget.allStudents[0].exam} - Date: ${widget.allStudents[0].examDate}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Boutons d'action
           Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centre la Row si l'espace est libre
              children: [
                Expanded( // Le bouton prend l'espace disponible
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0), // Ajout d'une petite marge
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _isGeneratingPDF ? null : _uploadNotesFile,
                      icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.upload),
                      label: Text(_isLoading ? 'Chargement...' : 'Importer les notes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Réduction du padding horizontal
                      ),
                    ),
                  ),
                ),
                Expanded( // Le bouton prend l'espace disponible
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0), // Ajout d'une petite marge
                    child: ElevatedButton.icon(
                      onPressed: hasNotes && !_isGeneratingPDF && !_isLoading 
                          ? _generateNotesPDF 
                          : null, 
                      icon: _isGeneratingPDF 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_isGeneratingPDF ? 'Génération...' : 'Générer PDF des Notes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasNotes ? Colors.red : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Réduction du padding horizontal
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statut
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _status.contains('Erreur') ? Colors.red.shade800 : Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tableau des Notes
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_studentsWithNotes.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Aucune note importée pour le moment.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: Card(
                  elevation: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.teal.withOpacity(0.1)),
                          columns: const [
                            DataColumn(label: Text('Num. Inscri.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('CIN', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                          ],
                          rows: _studentsWithNotes.map((student) {
                            return DataRow(
                              cells: [
                                DataCell(Text(student.NINSCRI)),
                                DataCell(Text(student.lastName)), 
                                DataCell(Text(student.firstName)), 
                                DataCell(Text(student.cin)), 
                                DataCell(
                                    Text(
                                        student.note == null 
                                            ? 'N/A' 
                                            : student.note!.toStringAsFixed(2),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: student.note != null && student.note! < 10 ? Colors.red : Colors.green)
                                    )
                                ), 
                              ],
                            );
                          }).toList(),
                        ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}