import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/lead.dart';
import '../../config/theme.dart';
import '../l10n/app_localizations.dart';

class LeadListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Format date
    final date = lead.createdAt;
    final formattedDate = DateFormat('MMM d').format(date);

    return InkWell(
      key: ValueKey('lead-${lead.id}'),
      onTap: () async {
        await context.push('/leads/${lead.id}', extra: lead);
        // Call the callback when returning from detail screen
        onReturn?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(lead.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _getStatusEmoji(lead.status),
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lead.company ?? lead.email ?? lead.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lead.notes != null && lead.notes!.isNotEmpty) ...[
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
                              lead.notes!.first.content,
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
                if (showStatus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(lead.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(lead.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(lead.status, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(lead.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (showStatus) const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 4),
                if (lead.value > 0)
                  Text(
                    '\$${NumberFormat('#,###').format(lead.value)}',
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

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
