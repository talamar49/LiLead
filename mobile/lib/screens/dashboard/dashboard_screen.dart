import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lead_provider.dart';
import '../../core/models/statistics.dart';
import '../../core/models/lead.dart';
import '../../widgets/dashboard_stats_card.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/lead_list_item.dart';
import '../../config/theme.dart';
import '../leads/add_lead_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).getStatistics();
      ref.read(leadProvider.notifier).getLeads(); // Load all leads to show recent ones
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leadState = ref.watch(leadProvider);
    final stats = leadState.statistics;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatar(size: 36),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(leadProvider.notifier).getStatistics();
            },
          ),
        ],
      ),
      body: leadState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : leadState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.errorGeneric),
                      ElevatedButton(
                        onPressed: () => ref.read(leadProvider.notifier).getStatistics(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : stats == null
                  ? Center(child: Text(l10n.noData))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(leadProvider.notifier).getStatistics();
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.4,
                              children: [
                                DashboardStatsCard(
                                  title: l10n.totalLeads,
                                  value: stats.total.toString(),
                                  animatedValue: stats.total,
                                  icon: Icons.people,
                                  color: Colors.blue,
                                  onTap: () => context.go('/all-leads'),
                                ),
                                DashboardStatsCard(
                                  title: l10n.conversionRate,
                                  value: '${stats.conversionRate.toStringAsFixed(1)}%',
                                  animatedValue: stats.conversionRate,
                                  isPercentage: true,
                                  icon: Icons.trending_up,
                                  color: Colors.green,
                                ),
                                DashboardStatsCard(
                                  title: l10n.newLeads,
                                  value: stats.byStatus.newCount.toString(),
                                  animatedValue: stats.byStatus.newCount,
                                  icon: Icons.fiber_new,
                                  color: Colors.orange,
                                  onTap: () => context.go('/new-leads'),
                                ),
                                DashboardStatsCard(
                                  title: l10n.wonLeads,
                                  value: stats.byStatus.closed.toString(),
                                  animatedValue: stats.byStatus.closed,
                                  icon: Icons.check_circle,
                                  color: Colors.purple,
                                  onTap: () => context.go('/closed'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Pie Chart Section
                            Text(
                              l10n.leadsByStatus,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            SizedBox(
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  sections: _getSections(stats.byStatus),
                                ),
                              ).animate()
                                .scale(duration: 1000.ms, curve: Curves.easeOutBack)
                                .fadeIn(duration: 1000.ms),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Legend
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildLegendItem(l10n.statusNew, stats.byStatus.newCount, AppTheme.newLeadColor),
                                _buildLegendItem(l10n.statusInProcess, stats.byStatus.inProcess, AppTheme.inProcessColor),
                                _buildLegendItem(l10n.statusClosed, stats.byStatus.closed, AppTheme.closedColor),
                                _buildLegendItem(l10n.statusNotRelevant, stats.byStatus.notRelevant, AppTheme.notRelevantColor),
                              ],
                            ),

                            const SizedBox(height: 32),
                            
                            // Source Chart Section
                            Text(
                              l10n.leadsBySource ?? 'Leads by Source',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxSourceCount(stats.bySource).toDouble() + 2,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          rod.toY.round().toString(),
                                          const TextStyle(color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) => _getTitles(value, meta, context),
                                        reservedSize: 40,
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _getBarGroups(stats.bySource),
                                ),
                              ).animate()
                                .slideY(begin: 0.3, duration: 1000.ms, curve: Curves.easeOutQuart)
                                .fadeIn(duration: 1000.ms),
                            ),
                            const SizedBox(height: 32),
                            
                            // Recent Leads Section
                            _buildRecentLeadsSection(context, l10n, ref),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddLeadScreen(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $value'),
      ],
    );
  }

  List<PieChartSectionData> _getSections(StatusStats stats) {
    final total = stats.newCount + stats.inProcess + stats.closed + stats.notRelevant;
    if (total == 0) return [];

    return [
      if (stats.newCount > 0) _buildSection(stats.newCount, total, AppTheme.newLeadColor),
      if (stats.inProcess > 0) _buildSection(stats.inProcess, total, AppTheme.inProcessColor),
      if (stats.closed > 0) _buildSection(stats.closed, total, AppTheme.closedColor),
      if (stats.notRelevant > 0) _buildSection(stats.notRelevant, total, AppTheme.notRelevantColor),
    ];
  }

  PieChartSectionData _buildSection(int value, int total, Color color) {
    final percentage = (value / total) * 100;
    const fontSize = 16.0;
    const radius = 50.0;

    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${percentage.toStringAsFixed(0)}%',
      radius: radius,
      titleStyle: const TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'NEW': return AppTheme.newLeadColor;
      case 'CONTACTED':
      case 'QUALIFIED':
      case 'PROPOSAL_SENT':
      case 'NEGOTIATION': return AppTheme.inProcessColor;
      case 'WON': return AppTheme.closedColor;
      case 'LOST': return AppTheme.errorColor;
      default: return AppTheme.notRelevantColor;
    }
  }

  int _getMaxSourceCount(SourceStats stats) {
    return [
      stats.facebook,
      stats.instagram,
      stats.whatsapp,
      stats.tiktok,
      stats.manual,
      stats.webhook
    ].reduce((curr, next) => curr > next ? curr : next);
  }

  Widget _getTitles(double value, TitleMeta meta, BuildContext context) {
    Widget icon;
    switch (value.toInt()) {
      case 0:
        // Facebook
        icon = SvgPicture.asset(
          'assets/images/facebook_logo.svg',
          width: 24,
          height: 24,
        );
        break;
      case 1:
        // Instagram
        icon = SvgPicture.asset(
          'assets/images/instagram_logo.svg',
          width: 24,
          height: 24,
        );
        break;
      case 2:
        // WhatsApp
        icon = SvgPicture.asset(
          'assets/images/whatsapp_logo.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFF25D366), BlendMode.srcIn),
        );
        break;
      case 3:
        // TikTok
        icon = SvgPicture.asset(
          'assets/images/tiktok_logo.svg',
          width: 24,
          height: 24,
        );
        break;
      case 4:
        // Manual
        icon = const Icon(
          Icons.edit,
          size: 24,
          color: Colors.orange,
        );
        break;
      case 5:
        // Webhook
        icon = const Icon(
          Icons.webhook,
          size: 24,
          color: Colors.teal,
        );
        break;
      default:
        icon = const SizedBox.shrink();
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: icon,
    );
  }

  List<BarChartGroupData> _getBarGroups(SourceStats stats) {
    return [
      _makeGroupData(0, stats.facebook.toDouble(), Colors.blue),
      _makeGroupData(1, stats.instagram.toDouble(), Colors.purple),
      _makeGroupData(2, stats.whatsapp.toDouble(), Colors.green),
      _makeGroupData(3, stats.tiktok.toDouble(), Colors.black),
      _makeGroupData(4, stats.manual.toDouble(), Colors.orange),
      _makeGroupData(5, stats.webhook.toDouble(), Colors.teal),
    ];
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLeadsSection(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final leadState = ref.watch(leadProvider);
    final recentLeads = leadState.leads.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentLeads ?? 'Recent Leads',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/all-leads'),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.viewAll ?? 'View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentLeads.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noLeadsFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentLeads.asMap().entries.map((entry) {
            final index = entry.key;
            final lead = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LeadListItem(
                lead: lead,
                showStatus: true,
                onReturn: () {
                  ref.read(leadProvider.notifier).getStatistics();
                  ref.read(leadProvider.notifier).getLeads();
                },
              ).animate(delay: Duration(milliseconds: index * 100))
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
            );
          }).toList(),
      ],
    );
  }
}
