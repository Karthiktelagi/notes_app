import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';

class NoteProviderHive extends ChangeNotifier {
  final Box<Note> _box = Hive.box<Note>('notesBox');
  List<Note> _notes = [];

  NoteProviderHive() {
    _load();
  }

  void _load() {
    _notes = _box.values.toList().reversed.toList();
    notifyListeners();
  }

  List<Note> get notes => _notes;

  Future<void> addNote(String title, String content) async {
    final note = Note(title: title, content: content);
    await _box.add(note);
    _load();
  }

  Future<void> updateNote(Note note, String title, String content) async {
    note.title = title;
    note.content = content;
    note.updatedAt = DateTime.now();
    await note.save();
    _load();
  }

  Future<void> deleteNoteAt(int index) async {
    final key = _box.keyAt(_box.length - 1 - index);
    await _box.delete(key);
    _load();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      _load();
    } else {
      final q = query.toLowerCase();
      _notes = _box.values
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q))
          .toList()
          .reversed
          .toList();
      notifyListeners();
    }
  }
}
