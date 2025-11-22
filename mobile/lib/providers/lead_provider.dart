import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/lead.dart';
import '../core/models/note.dart';
import '../core/models/statistics.dart';
import '../core/services/lead_service.dart';
import 'providers.dart';

// State
class LeadState {
  final bool isLoading;
  final List<Lead> leads;
  final List<Note> currentLeadNotes;
  final Statistics? statistics;
  final String? error;
  final String searchQuery;

  LeadState({
    this.isLoading = false,
    this.leads = const [],
    this.currentLeadNotes = const [],
    this.statistics,
    this.error,
    this.searchQuery = '',
  });

  LeadState copyWith({
    bool? isLoading,
    List<Lead>? leads,
    List<Note>? currentLeadNotes,
    Statistics? statistics,
    String? error,
    String? searchQuery,
  }) {
    return LeadState(
      isLoading: isLoading ?? this.isLoading,
      leads: leads ?? this.leads,
      currentLeadNotes: currentLeadNotes ?? this.currentLeadNotes,
      statistics: statistics ?? this.statistics,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Lead> get filteredLeads {
    if (searchQuery.isEmpty) return leads;
    return leads.where((lead) {
      final query = searchQuery.toLowerCase();
      return lead.name.toLowerCase().contains(query) ||
          (lead.phone.toLowerCase().contains(query)) ||
          (lead.company?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
}

// Notifier
class LeadNotifier extends StateNotifier<LeadState> {
  final LeadService _leadService;

  LeadNotifier(this._leadService) : super(LeadState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> getLeads({LeadStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leads = await _leadService.getLeads(status: status);
      state = state.copyWith(isLoading: false, leads: leads);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createLead(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _leadService.createLead(
        name: data['name'],
        phone: data['phone'],
        email: data['email'],
        // Add other fields as needed
        source: data['source'] != null ? LeadSource.values.firstWhere((e) => e.toString().split('.').last == data['source']) : null,
      );
      // Refresh leads handled by caller or automatic refresh
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> getNotes(String leadId) async {
    // Don't set global loading for notes to avoid flickering main list if possible, 
    // but here we use single state. Let's use a separate loading flag if needed, 
    // but for now reuse isLoading or just update notes silently if we want.
    // Better to just update notes.
    try {
      final notes = await _leadService.getLeadNotes(leadId);
      state = state.copyWith(currentLeadNotes: notes);
    } catch (e) {
      // Handle error silently or show snackbar in UI
      print('Error fetching notes: $e');
    }
  }

  Future<bool> addNote(String leadId, String content) async {
    try {
      await _leadService.addNote(leadId, content);
      await getNotes(leadId); // Refresh notes
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLead(String id, Map<String, dynamic> data) async {
    try {
      await _leadService.updateLead(
        id,
        status: data['status'] != null ? LeadStatus.values.firstWhere((e) => e.toString().split('.').last == data['status']) : null,
      );
      // Refresh leads if needed, or update locally
      // For now, let's just return true and let UI refresh
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getStatistics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _leadService.getStatistics();
      state = state.copyWith(isLoading: false, statistics: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final leadProvider = StateNotifierProvider<LeadNotifier, LeadState>((ref) {
  final leadService = ref.watch(leadServiceProvider);
  return LeadNotifier(leadService);
});
