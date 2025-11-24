import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/lead.dart';
import '../../config/theme.dart';
import '../l10n/app_localizations.dart';

class LeadListItem extends ConsumerStatefulWidget {
  final Lead lead;
  final bool showStatus;
  final VoidCallback? onReturn;

  const LeadListItem({
    super.key, 
    required this.lead,
    this.showStatus = false,
    this.onReturn,
  });

  @override
  ConsumerState<LeadListItem> createState() => _LeadListItemState();
}

class _LeadListItemState extends ConsumerState<LeadListItem> {
  bool _isPressed = false;

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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Format date
    final date = widget.lead.createdAt;
    final formattedDate = _formatDateWithLocalizedMonth(date, l10n);

    return GestureDetector(
      key: ValueKey('lead-${widget.lead.id}'),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        await context.push('/leads/${widget.lead.id}', extra: widget.lead);
        // Call the callback when returning from detail screen
        widget.onReturn?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed 
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02))
              : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Status Icon with pulse animation and hero
              Hero(
                tag: 'lead_status_${widget.lead.id}',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.lead.status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getStatusEmoji(widget.lead.status),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).shimmer(
                  delay: 2000.ms,
                  duration: 1500.ms,
                  color: _getStatusColor(widget.lead.status).withOpacity(0.3),
                ),
              ),
              const SizedBox(width: 12),
              
              // Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lead.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.lead.company ?? widget.lead.email ?? widget.lead.phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.lead.notes != null && widget.lead.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? const Color(0xFF2C2C2E) 
                            : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 14,
                              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.lead.notes!.first.content,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6E6E73),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Date / Status Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.lead.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(widget.lead.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(widget.lead.status, l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(widget.lead.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (widget.showStatus) const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.lead.value > 0)
                    Text(
                      '\$${NumberFormat('#,###').format(widget.lead.value)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.NEW:
        return AppTheme.newLeadColor;
      case LeadStatus.IN_PROCESS:
        return AppTheme.inProcessColor;
      case LeadStatus.CLOSED:
        return AppTheme.closedColor;
      case LeadStatus.NOT_RELEVANT:
        return AppTheme.notRelevantColor;
    }
  }


  String _getStatusEmoji(LeadStatus status) {
    switch (status) {
      case LeadStatus.NEW:
        return '🔥'; // Fire for hot lead
      case LeadStatus.IN_PROCESS:
        return '🕐'; // Clock for in process
      case LeadStatus.CLOSED:
        return '✅'; // Check mark for closed
      case LeadStatus.NOT_RELEVANT:
        return '❌'; // X for not relevant
    }
  }

  String _getStatusLabel(LeadStatus status, AppLocalizations l10n) {
    switch (status) {
      case LeadStatus.NEW:
        return l10n.statusNew;
      case LeadStatus.IN_PROCESS:
        return l10n.statusInProcess;
      case LeadStatus.CLOSED:
        return l10n.statusClosed;
      case LeadStatus.NOT_RELEVANT:
        return l10n.statusNotRelevant;
    }
  }
}
