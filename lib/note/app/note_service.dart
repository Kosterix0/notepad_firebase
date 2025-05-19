import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/note_state.dart';

class NoteNotifier
    extends StateNotifier<List<NoteState>> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _notesSubscription;

  NoteNotifier() : super([]) {
    _authSubscription = FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
          _handleAuthChange(user);
        });
  }

  void _handleAuthChange(User? user) {
    // Anuluj poprzednią subskrypcję
    _notesSubscription?.cancel();
    state = [];

    if (user != null) {
      _notesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((querySnapshot) {
            state =
                querySnapshot.docs.map((doc) {
                  return NoteState(
                    id: doc.id,
                    content: doc['content'],
                    createdAt:
                        (doc['createdAt'] as Timestamp)
                            .toDate(),
                  );
                }).toList();
          });
    }
  }

  Future<void> addNote(String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add({
          'content': content,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> editNote(
    String id,
    String newContent,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .update({'content': newContent});
  }

  Future<void> deleteNote(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .delete();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _notesSubscription?.cancel();
    super.dispose();
  }
}

final noteProvider =
    StateNotifierProvider<NoteNotifier, List<NoteState>>(
      (ref) {
        return NoteNotifier();
      },
    );
