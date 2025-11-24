import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/models/note.dart';
import '../core/services/notification_service.dart';
import '../providers/providers.dart';
import '../providers/lead_provider.dart';
import '../l10n/app_localizations.dart';

class NoteItem extends ConsumerWidget {
  final Note note;
  final String leadId;
  final String? leadName;

  const NoteItem({
    super.key, 
    required this.note, 
    required this.leadId,
    this.leadName,
  });

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

  String _formatDateWithLocalizedMonth(DateTime date, AppLocalizations l10n) {
    final month = _getLocalizedMonth(date.month, l10n);
    final day = date.day;
    final time = DateFormat('HH:mm').format(date);
    return '$month $day, $time';
  }

  Future<void> _deleteNote(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(leadProvider.notifier).deleteNote(leadId, note.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.noteDeleted : l10n.noteDeleteFailed),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final contentController = TextEditingController(text: note.content);
    DateTime? selectedReminder = note.reminderAt;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.editNote),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: l10n.noteContent,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedReminder != null
                            ? '${l10n.reminder}: ${_formatDateWithLocalizedMonth(selectedReminder!, l10n)}'
                            : l10n.noReminder,
                        style: TextStyle(
                          color: selectedReminder != null ? Theme.of(context).primaryColor : null,
                          fontWeight: selectedReminder != null ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                    if (selectedReminder != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => selectedReminder = null),
                        tooltip: l10n.clearReminder,
                      ),
                    IconButton(
                      icon: const Icon(Icons.alarm),
                      onPressed: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedReminder ?? now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedReminder ?? now),
                          );
                          if (time != null) {
                            setState(() {
                              selectedReminder = DateTime(
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
                      tooltip: l10n.setReminder,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newContent = contentController.text.trim();
                if (newContent.isEmpty) return;

                Navigator.pop(context);
                
                final success = await ref.read(leadProvider.notifier).updateNote(
                  leadId,
                  note.id,
                  content: newContent,
                  reminderAt: selectedReminder,
                  clearReminder: selectedReminder == null && note.reminderAt != null,
                );

                if (success) {
                  // Handle notification rescheduling
                  final notificationService = NotificationService();
                  
                  // Cancel old notification if it existed
                  if (note.reminderAt != null) {
                    final oldNotificationId = note.reminderAt!.millisecondsSinceEpoch ~/ 1000;
                    await notificationService.cancelNotification(oldNotificationId);
                  }
                  
                  // Schedule new notification if reminder was set
                  final reminderTime = selectedReminder;
                  if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
                    await notificationService.scheduleNotification(
                      id: reminderTime.millisecondsSinceEpoch ~/ 1000,
                      title: 'Reminder: ${leadName ?? "Lead"}',
                      body: newContent,
                      scheduledDateTime: reminderTime,
                      payload: 'lead_$leadId',
                    );
                    
                    if (context.mounted) {
                      final minutesUntil = reminderTime.difference(DateTime.now()).inMinutes;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.noteUpdated}\n✓ Reminder updated for $minutesUntil minutes from now'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    return;
                  }
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.noteUpdated : l10n.noteUpdateFailed),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final date = note.createdAt;
    final formattedDate = _formatDateWithLocalizedMonth(date, l10n);

    // Use app's card colors
    final cardColor = isDark 
        ? theme.colorScheme.surface 
        : theme.cardTheme.color ?? Colors.white;
    
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark 
        ? const Color(0xFF8E8E93) 
        : const Color(0xFF667781);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showEditDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _deleteNote(context, ref),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: isDark 
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (note.reminderAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateWithLocalizedMonth(note.reminderAt!, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(), // Spacer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (note.user != null)
                        Text(
                          note.user!.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: subtextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
