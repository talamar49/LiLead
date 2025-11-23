// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lead _$LeadFromJson(Map<String, dynamic> json) => Lead(
  id: json['id'] as String,
  name: json['name'] as String,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  company: json['company'] as String?,
  value: (json['value'] as num?)?.toDouble() ?? 0,
  status: $enumDecode(_$LeadStatusEnumMap, json['status']),
  source: $enumDecode(_$LeadSourceEnumMap, json['source']),
  customFields: json['customFields'] as Map<String, dynamic>?,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as String),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt'] as String),
  userId: json['userId'] as String,
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LeadToJson(Lead instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'lastName': instance.lastName,
  'phone': instance.phone,
  'email': instance.email,
  'company': instance.company,
  'value': instance.value,
  'status': _$LeadStatusEnumMap[instance.status]!,
  'source': _$LeadSourceEnumMap[instance.source]!,
  'customFields': instance.customFields,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
  'userId': instance.userId,
  'notes': instance.notes,
};

const _$LeadStatusEnumMap = {
  LeadStatus.NEW: 'NEW',
  LeadStatus.IN_PROCESS: 'IN_PROCESS',
  LeadStatus.CLOSED: 'CLOSED',
  LeadStatus.NOT_RELEVANT: 'NOT_RELEVANT',
};

const _$LeadSourceEnumMap = {
  LeadSource.FACEBOOK: 'FACEBOOK',
  LeadSource.INSTAGRAM: 'INSTAGRAM',
  LeadSource.WHATSAPP: 'WHATSAPP',
  LeadSource.TIKTOK: 'TIKTOK',
  LeadSource.MANUAL: 'MANUAL',
  LeadSource.WEBHOOK: 'WEBHOOK',
};
