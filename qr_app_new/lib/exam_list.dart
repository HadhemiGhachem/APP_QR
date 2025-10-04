import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExamList extends StatefulWidget {
  final List<dynamic> exams;

  const ExamList({Key? key, required this.exams}) : super(key: key);

  @override
  State<ExamList> createState() => _ExamListState();
}

class _ExamListState extends State<ExamList> {
  String? _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Liste des examens'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _error != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : widget.exams.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun examen disponible',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.exams.length,
                      itemBuilder: (context, index) {
                        final exam = widget.exams[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              exam['examen'] ?? 'Examen ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Nom: ${exam['nom']} ${exam['prenom']}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Examen sélectionné : ${exam['examen']}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}