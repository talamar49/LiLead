// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
  byStatus: StatusStats.fromJson(json['byStatus'] as Map<String, dynamic>),
  bySource: SourceStats.fromJson(json['bySource'] as Map<String, dynamic>),
  total: (json['total'] as num).toInt(),
  conversionRate: (json['conversionRate'] as num).toDouble(),
  recentLeads: (json['recentLeads'] as num).toInt(),
);

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'byStatus': instance.byStatus,
      'bySource': instance.bySource,
      'total': instance.total,
      'conversionRate': instance.conversionRate,
      'recentLeads': instance.recentLeads,
    };

StatusStats _$StatusStatsFromJson(Map<String, dynamic> json) => StatusStats(
  newCount: (json['new'] as num).toInt(),
  inProcess: (json['inProcess'] as num).toInt(),
  closed: (json['closed'] as num).toInt(),
  notRelevant: (json['notRelevant'] as num).toInt(),
);

Map<String, dynamic> _$StatusStatsToJson(StatusStats instance) =>
    <String, dynamic>{
      'new': instance.newCount,
      'inProcess': instance.inProcess,
      'closed': instance.closed,
      'notRelevant': instance.notRelevant,
    };

SourceStats _$SourceStatsFromJson(Map<String, dynamic> json) => SourceStats(
  facebook: (json['facebook'] as num).toInt(),
  instagram: (json['instagram'] as num).toInt(),
  whatsapp: (json['whatsapp'] as num).toInt(),
  tiktok: (json['tiktok'] as num).toInt(),
  manual: (json['manual'] as num).toInt(),
  webhook: (json['webhook'] as num).toInt(),
);

Map<String, dynamic> _$SourceStatsToJson(SourceStats instance) =>
    <String, dynamic>{
      'facebook': instance.facebook,
      'instagram': instance.instagram,
      'whatsapp': instance.whatsapp,
      'tiktok': instance.tiktok,
      'manual': instance.manual,
      'webhook': instance.webhook,
    };
