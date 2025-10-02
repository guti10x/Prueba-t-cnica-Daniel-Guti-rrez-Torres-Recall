import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final HttpsCallable callable = _functions.httpsCallable('getUserNotes');
      final result = await callable();
      final notesData = List<Map<String, dynamic>>.from(result.data['notes']);
      setState(() {
        _notes = notesData;
      });
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('notes').add({
        'text': _noteController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser!.uid,
      });

      _noteController.clear();
      await _fetchNotes();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  void _openNoteDetail(Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Write a new note...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _notes.isEmpty
                        ? const Text('No notes yet.')
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              final text = note['text'] as String;
                              return ListTile(
                                title: Text(
                                  text.length > 50
                                      ? '${text.substring(0, 50)}...'
                                      : text,
                                ),
                                onTap: () => _openNoteDetail(note),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

// Nota: todavía necesitamos crear NoteDetailScreen
class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note['text'] ?? ''),
      ),
    );
  }
}
