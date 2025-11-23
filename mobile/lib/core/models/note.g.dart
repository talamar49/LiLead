// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  id: json['id'] as String,
  content: json['content'] as String,
  reminderAt: const NullableDateTimeConverter().fromJson(
    json['reminderAt'] as String?,
  ),
  reminderSent: json['reminderSent'] as bool? ?? false,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as String),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt'] as String),
  leadId: json['leadId'] as String,
  userId: json['userId'] as String,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'reminderAt': const NullableDateTimeConverter().toJson(instance.reminderAt),
  'reminderSent': instance.reminderSent,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
  'leadId': instance.leadId,
  'userId': instance.userId,
  'user': instance.user,
};
