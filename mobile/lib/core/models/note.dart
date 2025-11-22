import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String leadId;
  final String userId;
  final User? user;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.leadId,
    required this.userId,
    this.user,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
