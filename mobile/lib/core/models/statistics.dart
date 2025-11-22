import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable()
class Statistics {
  final StatusStats byStatus;
  final SourceStats bySource;
  final int total;
  final double conversionRate;
  final int recentLeads;

  Statistics({
    required this.byStatus,
    required this.bySource,
    required this.total,
    required this.conversionRate,
    required this.recentLeads,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

@JsonSerializable()
class StatusStats {
  @JsonKey(name: 'new')
  final int newCount;
  final int inProcess;
  final int closed;
  final int notRelevant;

  StatusStats({
    required this.newCount,
    required this.inProcess,
    required this.closed,
    required this.notRelevant,
  });

  factory StatusStats.fromJson(Map<String, dynamic> json) =>
      _$StatusStatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatusStatsToJson(this);
}

@JsonSerializable()
class SourceStats {
  final int facebook;
  final int instagram;
  final int whatsapp;
  final int tiktok;
  final int manual;
  final int webhook;

  SourceStats({
    required this.facebook,
    required this.instagram,
    required this.whatsapp,
    required this.tiktok,
    required this.manual,
    required this.webhook,
  });

  factory SourceStats.fromJson(Map<String, dynamic> json) =>
      _$SourceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SourceStatsToJson(this);
}
