
import 'package:json_annotation/json_annotation.dart';
import 'note.dart';

part 'lead.g.dart';

enum LeadStatus {
  @JsonValue('NEW')
  NEW,
  @JsonValue('IN_PROCESS')
  IN_PROCESS,
  @JsonValue('CLOSED')
  CLOSED,
  @JsonValue('NOT_RELEVANT')
  NOT_RELEVANT,
}

enum LeadSource {
  @JsonValue('FACEBOOK')
  FACEBOOK,
  @JsonValue('INSTAGRAM')
  INSTAGRAM,
  @JsonValue('WHATSAPP')
  WHATSAPP,
  @JsonValue('TIKTOK')
  TIKTOK,
  @JsonValue('MANUAL')
  MANUAL,
  @JsonValue('WEBHOOK')
  WEBHOOK,
}

@JsonSerializable()
class Lead {
  final String id;
  final String name;
  final String? lastName;
  final String phone;
  final String? email;
  final String? company;
  final double value;
  final LeadStatus status;
  final LeadSource source;
  final Map<String, dynamic>? customFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<Note>? notes;

  Lead({
    required this.id,
    required this.name,
    this.lastName,
    required this.phone,
    this.email,
    this.company,
    this.value = 0,
    required this.status,
    required this.source,
    this.customFields,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.notes,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
  Map<String, dynamic> toJson() => _$LeadToJson(this);

  String get fullName => lastName != null ? '$name $lastName' : name;

  Lead copyWith({
    String? id,
    String? name,
    String? lastName,
    String? phone,
    String? email,
    String? company,
    double? value,
    LeadStatus? status,
    LeadSource? source,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<Note>? notes,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      value: value ?? this.value,
      status: status ?? this.status,
      source: source ?? this.source,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
    );
  }
}

// Extension for status display
extension LeadStatusExtension on LeadStatus {
  String get displayName {
    switch (this) {
      case LeadStatus.NEW:
        return 'New';
      case LeadStatus.IN_PROCESS:
        return 'In Process';
      case LeadStatus.CLOSED:
        return 'Closed';
      case LeadStatus.NOT_RELEVANT:
        return 'Not Relevant';
    }
  }
}

// Extension for source display
extension LeadSourceExtension on LeadSource {
  String get displayName {
    switch (this) {
      case LeadSource.FACEBOOK:
        return 'Facebook';
      case LeadSource.INSTAGRAM:
        return 'Instagram';
      case LeadSource.WHATSAPP:
        return 'WhatsApp';
      case LeadSource.TIKTOK:
        return 'TikTok';
      case LeadSource.MANUAL:
        return 'Manual';
      case LeadSource.WEBHOOK:
        return 'Webhook';
    }
  }
}
