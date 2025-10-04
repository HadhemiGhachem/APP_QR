import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _exams = [];

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  // Récupérer les examens depuis l'API
  Future<void> fetchExams() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/getExcelContent'));
      if (response.statusCode == 200) {
        setState(() {
          _exams = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des examens';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion au serveur';
        _isLoading = false;
      });
    }
  }

  // Importer et envoyer le fichier Excel au back-end
  Future<void> importExcel() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Sélectionner le fichier Excel
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      ); 

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Créer une requête multipart pour envoyer le fichier
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:8000/api/saveExcelContent'),
        );

        // Ajouter le fichier à la requête
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path),
        );

        // Envoyer la requête
        var response = await request.send();

        if (response.statusCode == 200) {
          // Rafraîchir la liste des examens après l'importation
          await fetchExams();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fichier importé avec succès')),
          );
        } else {
          setState(() {
            _error = 'Erreur lors de l\'envoi du fichier';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Aucun fichier sélectionné';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des examens'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: importExcel,
            tooltip: 'Importer un fichier Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _exams.isEmpty
                  ? const Center(child: Text('Aucun examen trouvé'))
                  : ListView.builder(
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        return ListTile(
                          title: Text(exam['examen'] ?? 'Examen ${index + 1}'),
                          subtitle: Text('Nom: ${exam['nom'] ?? ''} ${exam['prenom'] ?? ''}'),
                        );
                      },
                    ),
    );
  }
}