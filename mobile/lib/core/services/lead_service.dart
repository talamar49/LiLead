import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../models/lead.dart';
import '../models/note.dart';
import '../models/statistics.dart';

class LeadService {
  final ApiService _apiService;

  LeadService(this._apiService);

  Future<List<Lead>> getLeads({LeadStatus? status, LeadSource? source}) async {
    try {
      final response = await _apiService.getLeads(
        status: status?.name.toUpperCase(),
        source: source?.name.toUpperCase(),
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lead> createLead({
    required String name,
    String? lastName,
    required String phone,
    String? email,
    LeadSource? source,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final body = {
        'name': name,
        if (lastName != null) 'lastName': lastName,
        'phone': phone,
        if (email != null) 'email': email,
        if (source != null) 'source': source.name.toUpperCase(),
        if (customFields != null) 'customFields': customFields,
      };

      final response = await _apiService.createLead(body);
      if (response.success && response.data != null) return response.data!;
      throw Exception(response.error ?? 'Failed to create lead');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lead> getLead(String id) async {
    try {
      final response = await _apiService.getLead(id);
      if (response.success && response.data != null) return response.data!;
      throw Exception(response.error ?? 'Lead not found');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteLead(String id) async {
    try {
      await _apiService.deleteLead(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Note>> getLeadNotes(String leadId) async {
    try {
      final response = await _apiService.getLeadNotes(leadId);
      if (response.success && response.data != null) return response.data!;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Note> addNote(String leadId, String content) async {
    try {
      final response = await _apiService.addNote(leadId, {'content': content});
      if (response.success && response.data != null) return response.data!;
      throw Exception(response.error ?? 'Failed to add note');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lead> updateLead(
    String id, {
    String? name,
    String? lastName,
    String? phone,
    String? email,
    LeadStatus? status,
    LeadSource? source,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (lastName != null) body['lastName'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (status != null) body['status'] = status.name.toUpperCase();
      if (source != null) body['source'] = source.name.toUpperCase();
      if (customFields != null) body['customFields'] = customFields;

      final response = await _apiService.updateLead(id, body);
      if (response.success && response.data != null) return response.data!;
      throw Exception(response.error ?? 'Failed to update lead');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Statistics> getStatistics() async {
    try {
      final response = await _apiService.getStatistics();
      if (response.success && response.data != null) return response.data!;
      throw Exception(response.error ?? 'Failed to load statistics');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
    }
    return 'An error occurred';
  }
}
