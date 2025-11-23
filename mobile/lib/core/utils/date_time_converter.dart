import 'package:json_annotation/json_annotation.dart';

/// Converts DateTime from UTC string to local time
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) {
    // Parse the UTC string and convert to local time
    return DateTime.parse(json).toLocal();
  }

  @override
  String toJson(DateTime object) {
    // Convert to UTC when sending to server
    return object.toUtc().toIso8601String();
  }
}

/// Converts nullable DateTime from UTC string to local time
class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    // Parse the UTC string and convert to local time
    return DateTime.parse(json).toLocal();
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) return null;
    // Convert to UTC when sending to server
    return object.toUtc().toIso8601String();
  }
}

