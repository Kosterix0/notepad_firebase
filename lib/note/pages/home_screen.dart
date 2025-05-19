import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notatnik/note/app/note_service.dart';
import 'note_detail_screen.dart';
import 'package:notatnik/note/app/signInWithGoogle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signInScreen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final GoogleAuthService _authService =
      GoogleAuthService();

  HomeScreen({Key? key, required this.user})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user.displayName}"),
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.photoURL ?? "",
                  ),
                  radius: 40,
                ),
                SizedBox(height: 16),
                Text("Email: ${user.email}"),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final notes = ref.watch(noteProvider);
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.content),
                      subtitle: Text(
                        'Utworzono: ${DateFormat('dd.MM.yyyy HH:mm').format(note.createdAt)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          NoteDetailScreen(
                                            note: note,
                                          ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              ref
                                  .read(
                                    noteProvider
                                        .notifier,
                                  )
                                  .deleteNote(note.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            return Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _authService.signOut();
                    ref.invalidate(
                      noteProvider,
                    ); // Reset stanu
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignInScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Wyloguj'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                  ),
                ),
                Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
