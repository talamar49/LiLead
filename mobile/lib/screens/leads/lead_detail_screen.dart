import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/lead.dart';
import '../../core/models/note.dart';
import '../../core/utils/action_launcher.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/battery_optimization_helper.dart';
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
  DateTime? _selectedReminderDateTime;

  @override
  void initState() {
    super.initState();
    _lead = widget.lead;
    _fetchNotes();
  }

  String _getLocalizedMonth(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.monthJan;
      case 2: return l10n.monthFeb;
      case 3: return l10n.monthMar;
      case 4: return l10n.monthApr;
      case 5: return l10n.monthMay;
      case 6: return l10n.monthJun;
      case 7: return l10n.monthJul;
      case 8: return l10n.monthAug;
      case 9: return l10n.monthSep;
      case 10: return l10n.monthOct;
      case 11: return l10n.monthNov;
      case 12: return l10n.monthDec;
      default: return '';
    }
  }

  String _formatDateWithLocalizedMonth(DateTime date, AppLocalizations l10n, {bool includeYear = false}) {
    final month = _getLocalizedMonth(date.month, l10n);
    final day = date.day;
    final time = DateFormat('HH:mm').format(date);
    if (includeYear) {
      return '$month $day, ${date.year} $time';
    }
    return '$month $day, $time';
  }

  Future<void> _fetchNotes() async {
    setState(() => _isNotesLoading = true);
    await ref.read(leadProvider.notifier).getNotes(_lead.id);
    setState(() => _isNotesLoading = false);
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final content = _noteController.text.trim();
    final reminderAt = _selectedReminderDateTime;
    _noteController.clear();
    _selectedReminderDateTime = null;
    FocusScope.of(context).unfocus();

    final success = await ref.read(leadProvider.notifier).addNote(
      _lead.id,
      content,
      reminderAt: reminderAt,
    );
    
    if (success) {
      // Schedule local notification if reminder is set
      if (reminderAt != null) {
        final notificationService = NotificationService();
        
        // Verify time is in future
        if (reminderAt.isBefore(DateTime.now())) {
          if (mounted) {
            _showFloatingSnackBar(
              l10n.reminderInPast,
              Colors.orange,
            );
          }
        } else {
          final scheduled = await notificationService.scheduleNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
            title: '${l10n.reminder}: ${_lead.name}',
            body: content,
            scheduledDateTime: reminderAt,
            payload: 'lead_${_lead.id}',
          );
          
          if (mounted) {
            if (scheduled) {
              final timeUntil = reminderAt.difference(DateTime.now());
              final minutesUntil = timeUntil.inMinutes;
              _showFloatingSnackBar(
                l10n.reminderSetFor(minutesUntil),
                Colors.green,
              );
            } else {
              _showFloatingSnackBar(
                l10n.reminderFailed,
                Colors.red,
              );
            }
          }
        }
      } else {
        // Just show simple note added message
        if (mounted) {
          _showFloatingSnackBar(
            l10n.noteAdded,
            Colors.green,
          );
        }
      }
      
      // Notes are refreshed automatically by addNote in LeadNotifier
      if (mounted) {
        setState(() {}); // Refresh to clear reminder button state
      }
    } else {
      if (mounted) {
        _showFloatingSnackBar(
          l10n.noteAddFailed,
          Colors.red,
        );
      }
    }
  }

  void _showFloatingSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickReminderDateTime() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    // Request notification permissions when user tries to set first reminder
    // This will automatically request POST_NOTIFICATIONS (shows dialog)
    // and SCHEDULE_EXACT_ALARM (opens settings page) if needed
    final notificationService = NotificationService();
    final hasPermission = await notificationService.requestPermissions();
    
    if (!hasPermission) {
      if (!mounted) return;
      // Show message only if permissions are still denied
      _showFloatingSnackBar(
        l10n.notificationPermissionDenied,
        Colors.red,
      );
      return;
    }
    
    // Check battery optimization (critical for Nothing Phone and similar devices)
    if (!mounted) return;
    final isBatteryOptDisabled = await BatteryOptimizationHelper.isBatteryOptimizationDisabled();
    if (!isBatteryOptDisabled) {
      if (!mounted) return;
      // Show warning about battery optimization
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.batteryOptimizationTitle)),
            ],
          ),
          content: Text(l10n.batteryOptimizationMessage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.skip),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await BatteryOptimizationHelper.requestDisableBatteryOptimization();
                // Wait a moment then continue with date picker
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: Text(l10n.fixNow),
            ),
          ],
        ),
      );
      
      if (!mounted) return;
    }
    
    // Pick date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    
    if (selectedDate == null) return;
    
    // Pick time
    if (!mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedReminderDateTime ?? now),
    );
    
    if (selectedTime == null) return;
    
    setState(() {
      _selectedReminderDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _updateStatus(LeadStatus newStatus) async {
    final originalStatus = widget.lead.status; // Store original status before update
    final success = await ref.read(leadProvider.notifier).updateLead(_lead.id, {'status': newStatus.toString().split('.').last});
    if (success) {
      setState(() {
        _lead = _lead.copyWith(status: newStatus);
      });
      // Refresh the original status list so the lead is removed from that view
      ref.read(leadProvider.notifier).getLeads(status: originalStatus);
      // Refresh statistics to update dashboard charts
      ref.read(leadProvider.notifier).getStatistics();
    }
  }

  Future<void> _showScheduleDialog(BuildContext context, AppLocalizations l10n) async {
    final titleController = TextEditingController(text: 'פגישה עם ${_lead.name}');
    final descriptionController = TextEditingController(text: 'טלפון: ${_lead.phone}');
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('קבע אירוע'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'כותרת',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'תיאור',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                _formatDateWithLocalizedMonth(selectedDateTime, l10n, includeYear: true),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('ביטול'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ActionLauncher.launchGoogleCalendar(
                      title: titleController.text,
                      details: descriptionController.text,
                      startDateTime: selectedDateTime,
                      endDateTime: selectedDateTime.add(const Duration(hours: 1)),
                      emails: _lead.email != null ? [_lead.email!] : null,
                    );
                  },
                  child: Text('קבע ביומן'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime? _getNextReminder(List<Note> notes) {
    if (notes.isEmpty) return null;
    
    final now = DateTime.now();
    final upcomingReminders = notes
        .where((note) => note.reminderAt != null && note.reminderAt!.isAfter(now))
        .map((note) => note.reminderAt!)
        .toList()
      ..sort();
    
    return upcomingReminders.isEmpty ? null : upcomingReminders.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('DEBUG: Source: ${_lead.source}, Localized: ${_getLocalizedSourceLabel(_lead.source, l10n)}');
    final notes = ref.watch(leadProvider).currentLeadNotes;
    final theme = Theme.of(context);
    final nextReminder = _getNextReminder(notes);

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
                // Note: We don't refresh the lead list here to avoid affecting the previous screen's filter
                // The list screens will refresh when the user navigates back to them
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getStatusColor(_lead.status).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Hero(
                            tag: 'lead_status_${_lead.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                _getStatusEmoji(_lead.status),
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ).animate()
                            .scale(duration: 400.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 300.ms),
                        ),
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
                            _getStatusLabel(_lead.status, l10n),
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
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        onTap: () => ActionLauncher.launchWhatsApp(_lead.phone),
                        color: const Color(0xFF25D366), // WhatsApp green
                        imageAsset: 'assets/images/whatsapp_logo.svg',
                      ),
                      _ActionButton(
                        icon: Icons.email,
                        label: l10n.email,
                        onTap: () => _lead.email != null ? ActionLauncher.launchEmail(_lead.email!) : null,
                        color: const Color(0xFFEA4335), // Gmail red
                        imageAsset: 'assets/images/gmail_logo.png',
                      ),
                      _ActionButton(
                        icon: Icons.calendar_today,
                        label: l10n.scheduleOnCalendar,
                        onTap: () => _showScheduleDialog(context, l10n),
                        color: const Color(0xFF4285F4), // Google Calendar blue
                        imageAsset: 'assets/images/google_calendar_logo.png',
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
                  _DetailRow(icon: Icons.source, value: _getLocalizedSourceLabel(_lead.source, l10n)),
                  if (_lead.value > 0) _DetailRow(icon: Icons.attach_money, value: _lead.value.toString()),
                  if (nextReminder != null) 
                    _DetailRow(
                      icon: Icons.notifications_active,
                      value: '${l10n.reminder}: ${_formatDateWithLocalizedMonth(nextReminder, l10n, includeYear: true)}',
                    ),
                  
                  const SizedBox(height: 24),

                  // Status Change
                  _SectionHeader(title: l10n.status),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<LeadStatus>(
                      value: _lead.status,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: LeadStatus.values.map((status) {
                        return DropdownMenuItem<LeadStatus>(
                          value: status,
                          child: Row(
                            children: [
                              Text(
                                _getStatusEmoji(status),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(_getStatusLabel(status, l10n)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          _updateStatus(newStatus);
                        }
                      },
                    ),
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
                    ...notes.map((note) => NoteItem(
                      note: note, 
                      leadId: _lead.id,
                      leadName: _lead.name,
                    )),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedReminderDateTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alarm, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.reminder}: ${_formatDateWithLocalizedMonth(_selectedReminderDateTime!, l10n)}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => setState(() => _selectedReminderDateTime = null),
                            child: Icon(Icons.close, size: 16, color: theme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  Row(
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
                        onPressed: _pickReminderDateTime,
                        icon: Icon(
                          _selectedReminderDateTime != null ? Icons.alarm_on : Icons.alarm_add,
                        ),
                        color: _selectedReminderDateTime != null ? theme.primaryColor : Colors.grey,
                      ),
                      IconButton(
                        onPressed: _addNote,
                        icon: const Icon(Icons.send),
                        color: theme.primaryColor,
                      ),
                    ],
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

  String _getLocalizedSourceLabel(LeadSource source, AppLocalizations l10n) {
    switch (source) {
      case LeadSource.FACEBOOK: return l10n.sourceFacebook;
      case LeadSource.INSTAGRAM: return l10n.sourceInstagram;
      case LeadSource.WHATSAPP: return l10n.sourceWhatsApp;
      case LeadSource.TIKTOK: return l10n.sourceTikTok;
      case LeadSource.MANUAL: return l10n.sourceManual;
      case LeadSource.WEBHOOK: return l10n.sourceWebhook;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _getStatusEmoji(LeadStatus status) {
    switch (status) {
      case LeadStatus.NEW: return '🔥'; // Fire for hot lead
      case LeadStatus.IN_PROCESS: return '🕐'; // Clock for in process
      case LeadStatus.CLOSED: return '✅'; // Check mark for closed
      case LeadStatus.NOT_RELEVANT: return '❌'; // X for not relevant
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final String? imageAsset;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.imageAsset,
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
              child: imageAsset != null
                  ? (imageAsset!.endsWith('.svg')
                      ? SvgPicture.asset(
                          imageAsset!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          semanticsLabel: label,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          placeholderBuilder: (context) => Icon(icon, color: color, size: 28),
                        )
                      : Image.asset(
                          imageAsset!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ))
                  : Icon(icon, color: color, size: 28),
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
