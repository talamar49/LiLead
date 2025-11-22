import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/lead.dart';
import '../../config/theme.dart';

class LeadListItem extends StatelessWidget {
  final Lead lead;

  const LeadListItem({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Format date
    final date = lead.createdAt;
    final formattedDate = DateFormat('MMM d').format(date);

    return InkWell(
      onTap: () {
        context.push('/leads/${lead.id}', extra: lead);
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
            // Avatar / Initials
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(lead.status),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(lead.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                ],
              ),
            ),
            
            // Date / Status Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
}
