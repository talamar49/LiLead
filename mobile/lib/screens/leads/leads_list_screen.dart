import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../providers/lead_provider.dart';
import '../../core/models/lead.dart';
import '../../core/models/statistics.dart';
import '../../widgets/lead_list_item.dart';
import '../../widgets/slide_in_list_item.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/animated_fab.dart';
import '../../widgets/animated_empty_state.dart';
import '../../widgets/dashboard_stats_card.dart';
import 'add_lead_screen.dart';

class LeadsListScreen extends ConsumerStatefulWidget {
  const LeadsListScreen({super.key});

  @override
  ConsumerState<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends ConsumerState<LeadsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).getLeads();
      ref.read(leadProvider.notifier).getStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leadsState = ref.watch(leadProvider);
    final stats = leadsState.statistics;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recentActivity ?? 'Recent Activity'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatar(size: 36),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(leadProvider.notifier).getLeads();
              ref.read(leadProvider.notifier).getStatistics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: l10n.search ?? 'Search',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                ref.read(leadProvider.notifier).setSearchQuery(value);
              },
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.grey.shade100),
            ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          ),
          Expanded(
            child: leadsState.isLoading
                ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const ShimmerLeadListItem()
                          .animate(delay: Duration(milliseconds: index * 50))
                          .fadeIn(duration: 400.ms);
                    },
                  )
                : leadsState.error != null
                    ? AnimatedErrorState(
                        message: l10n.errorGeneric,
                        onRetry: () {
                          ref.read(leadProvider.notifier).getLeads();
                        },
                        retryLabel: l10n.retry,
                      )
                    : leadsState.filteredLeads.isEmpty
                        ? AnimatedEmptyState(
                            icon: Icons.inbox_outlined,
                            message: l10n.noLeadsFound,
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(leadProvider.notifier).getLeads();
                              await ref.read(leadProvider.notifier).getStatistics();
                            },
                            child: CustomScrollView(
                              slivers: [
                                // Recent Activity Section
                                if (stats != null) ...[
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.recentActivity ?? 'Recent Activity',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ).animate()
                                            .fadeIn(duration: 400.ms)
                                            .slideX(begin: -0.1, end: 0, duration: 400.ms),
                                          const SizedBox(height: 12),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                _buildActivityCard(
                                                  context,
                                                  l10n.totalLeads,
                                                  stats.total.toString(),
                                                  Icons.people,
                                                  Colors.blue,
                                                  0,
                                                ),
                                                const SizedBox(width: 12),
                                                _buildActivityCard(
                                                  context,
                                                  l10n.newLeads,
                                                  stats.byStatus.newCount.toString(),
                                                  Icons.fiber_new,
                                                  Colors.orange,
                                                  1,
                                                ),
                                                const SizedBox(width: 12),
                                                _buildActivityCard(
                                                  context,
                                                  l10n.statusInProcess,
                                                  stats.byStatus.inProcess.toString(),
                                                  Icons.hourglass_empty,
                                                  Colors.amber,
                                                  2,
                                                ),
                                                const SizedBox(width: 12),
                                                _buildActivityCard(
                                                  context,
                                                  l10n.wonLeads,
                                                  stats.byStatus.closed.toString(),
                                                  Icons.check_circle,
                                                  Colors.green,
                                                  3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                      child: Text(
                                        l10n.allLeads ?? 'Leads List',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ).animate()
                                        .fadeIn(duration: 400.ms, delay: 200.ms)
                                        .slideX(begin: -0.1, end: 0, duration: 400.ms),
                                    ),
                                  ),
                                ],
                                // Leads List
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final lead = leadsState.filteredLeads[index];
                                      return SlideInListItem(
                                        index: index,
                                        child: LeadListItem(
                                          lead: lead,
                                          showStatus: true,
                                        ),
                                      );
                                    },
                                    childCount: leadsState.filteredLeads.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(
        heroTag: 'leads_list_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddLeadScreen(),
          );
        },
        icon: Icons.add,
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? const Color(0xFF3A3A3C) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
