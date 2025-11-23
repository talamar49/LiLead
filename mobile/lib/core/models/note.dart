import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import '../utils/date_time_converter.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String content;
  @NullableDateTimeConverter()
  final DateTime? reminderAt;
  final bool reminderSent;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;
  final String leadId;
  final String userId;
  final User? user;

  Note({
    required this.id,
    required this.content,
    this.reminderAt,
    this.reminderSent = false,
    required this.createdAt,
    required this.updatedAt,
    required this.leadId,
    required this.userId,
    this.user,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? content,
    DateTime? reminderAt,
    bool clearReminder = false,
    bool? reminderSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? leadId,
    String? userId,
    User? user,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      reminderSent: reminderSent ?? this.reminderSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      leadId: leadId ?? this.leadId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }
}
