import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/lead.dart';
import '../../core/utils/action_launcher.dart';
import '../../providers/providers.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/note_item.dart';
import '../../config/theme.dart';
import 'edit_lead_screen.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> {
  late Lead _lead;
  final TextEditingController _noteController = TextEditingController();
  bool _isNotesLoading = false;

  @override
  void initState() {
    super.initState();
    _lead = widget.lead;
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isNotesLoading = true);
    await ref.read(leadProvider.notifier).getNotes(_lead.id);
    setState(() => _isNotesLoading = false);
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    final content = _noteController.text.trim();
    _noteController.clear();
    FocusScope.of(context).unfocus();

    final success = await ref.read(leadProvider.notifier).addNote(_lead.id, content);
    if (success) {
      // Notes are refreshed automatically by addNote in LeadNotifier
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add note')),
        );
      }
    }
  }

  Future<void> _updateStatus(LeadStatus newStatus) async {
    final success = await ref.read(leadProvider.notifier).updateLead(_lead.id, {'status': newStatus.toString().split('.').last});
    if (success) {
      setState(() {
        _lead = _lead.copyWith(status: newStatus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = ref.watch(leadProvider).currentLeadNotes;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_lead.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => EditLeadScreen(lead: _lead),
              ).then((_) {
                // Refresh the lead data after editing
                ref.read(leadProvider.notifier).getLeads(status: _lead.status);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _getStatusColor(_lead.status),
                          child: Text(
                            _getInitials(_lead.name),
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ).animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutBack)
                          .fadeIn(duration: 300.ms),
                        const SizedBox(height: 16),
                        Text(
                          _lead.name,
                          style: theme.textTheme.headlineMedium,
                        ).animate(delay: 100.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, duration: 400.ms),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_lead.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _lead.status.toString().split('.').last,
                            style: TextStyle(
                              color: _getStatusColor(_lead.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, duration: 400.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.call,
                        label: l10n.call,
                        onTap: () => ActionLauncher.launchPhone(_lead.phone),
                        color: Colors.green,
                      ),
                      _ActionButton(
                        icon: Icons.message,
                        label: 'WhatsApp',
                        onTap: () => ActionLauncher.launchWhatsApp(_lead.phone),
                        color: Colors.green.shade700,
                      ),
                      _ActionButton(
                        icon: Icons.email,
                        label: l10n.email,
                        onTap: () => _lead.email != null ? ActionLauncher.launchEmail(_lead.email!) : null,
                        color: Colors.blue,
                      ),
                    ],
                  ).animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                  const SizedBox(height: 24),

                  // Details Section
                  _SectionHeader(title: l10n.details),
                  _DetailRow(icon: Icons.phone, value: _lead.phone),
                  if (_lead.email != null) _DetailRow(icon: Icons.email, value: _lead.email!),
                  if (_lead.company != null) _DetailRow(icon: Icons.business, value: _lead.company!),
                  _DetailRow(icon: Icons.source, value: _lead.source.toString().split('.').last),
                  if (_lead.value > 0) _DetailRow(icon: Icons.attach_money, value: _lead.value.toString()),
                  
                  const SizedBox(height: 24),

                  // Status Change
                  _SectionHeader(title: l10n.status),
                  Wrap(
                    spacing: 8,
                    children: LeadStatus.values.map((status) {
                      final isSelected = _lead.status == status;
                      return ChoiceChip(
                        label: Text(_getStatusLabel(status, l10n)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) _updateStatus(status);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // Notes Section
                  _SectionHeader(title: l10n.notes),
                  if (_isNotesLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (notes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.noNotes,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...notes.map((note) => NoteItem(note: note)),
                ],
              ),
            ),
          ),
          
          // Add Note Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: l10n.addNote,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addNote,
                    icon: const Icon(Icons.send),
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.NEW: return AppTheme.newLeadColor;
      case LeadStatus.IN_PROCESS: return AppTheme.inProcessColor;
      case LeadStatus.CLOSED: return AppTheme.closedColor;
      case LeadStatus.NOT_RELEVANT: return AppTheme.notRelevantColor;
    }
  }

  String _getStatusLabel(LeadStatus status, AppLocalizations l10n) {
    switch (status) {
      case LeadStatus.NEW: return l10n.statusNew;
      case LeadStatus.IN_PROCESS: return l10n.statusInProcess;
      case LeadStatus.CLOSED: return l10n.statusClosed;
      case LeadStatus.NOT_RELEVANT: return l10n.statusNotRelevant;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _DetailRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
