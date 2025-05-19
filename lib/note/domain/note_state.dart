import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_state.freezed.dart';
part 'note_state.g.dart';

@freezed
class NoteState with _$NoteState {
  const factory NoteState({
    required String id,
    required String content,
    required DateTime createdAt,
  }) = _NoteState;

  factory NoteState.fromJson(
    Map<String, dynamic> json,
  ) => _$NoteStateFromJson(json);
}
