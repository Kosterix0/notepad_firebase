import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/note_state.dart';

class NoteNotifier
    extends StateNotifier<List<NoteState>> {
  NoteNotifier() : super([]) {
    _loadNotes();
  }

  //wczytywanie notatek z local storage
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final List<dynamic> decoded = jsonDecode(
        notesJson,
      );
      state =
          decoded
              .map((note) => NoteState.fromJson(note))
              .toList();
    }
  }

  //zapis notatek w local storage
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = jsonEncode(
      state.map((note) => note.toJson()).toList(),
    );
    await prefs.setString('notes', notesJson);
  }

  //dodawanie nowej notatki
  void addNote(String content) {
    final newNote = NoteState(
      id:
          DateTime.now().millisecondsSinceEpoch
              .toString(),
      content: content,
      createdAt: DateTime.now(),
    );
    state = [...state, newNote];
    _saveNotes();
  }

  //edytowanie notatki
  void editNote(String id, String newContent) {
    state =
        state.map((note) {
          if (note.id == id) {
            return note.copyWith(content: newContent);
          }
          return note;
        }).toList();
    _saveNotes();
  }

  //usuwanie notatki
  void deleteNote(String id) {
    state =
        state.where((note) => note.id != id).toList();
    _saveNotes();
  }
}

//provider dla listy notatek
final noteProvider =
    StateNotifierProvider<NoteNotifier, List<NoteState>>(
      (ref) {
        return NoteNotifier();
      },
    );
