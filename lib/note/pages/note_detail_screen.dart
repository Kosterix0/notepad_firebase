import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notatnik/note/app/note_service.dart';
import '../domain/note_state.dart';

class NoteDetailScreen extends ConsumerWidget {
  final NoteState? note;

  NoteDetailScreen({this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: note?.content ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          note == null
              ? 'Dodaj notatkę'
              : 'Edytuj notatkę',
        ),
        actions: [
          if (note != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                ref
                    .read(noteProvider.notifier)
                    .deleteNote(note!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Treść notatki',
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (note == null) {
                      ref
                          .read(noteProvider.notifier)
                          .addNote(controller.text);
                    } else {
                      ref
                          .read(noteProvider.notifier)
                          .editNote(
                            note!.id,
                            controller.text,
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    note == null
                        ? 'Zapisz'
                        : 'Zaktualizuj',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
