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
import '../../widgets/shimmer_loading.dart';
import '../../widgets/animated_fab.dart';
import '../../config/theme.dart';
import '../leads/add_lead_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _pieAnimationController;
  late Animation<double> _pieAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize pie chart animation controller
    _pieAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pieAnimation = CurvedAnimation(
      parent: _pieAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).getStatistics();
      ref.read(leadProvider.notifier).getLeads(); // Load all leads to show recent ones
      _pieAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pieAnimationController.dispose();
    super.dispose();
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
              _pieAnimationController.reset();
              ref.read(leadProvider.notifier).getStatistics();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _pieAnimationController.forward();
                }
              });
            },
          ),
        ],
      ),
      body: leadState.isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats cards shimmer
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: List.generate(
                      4,
                      (index) => const ShimmerStatsCard()
                          .animate(delay: Duration(milliseconds: index * 100))
                          .fadeIn(duration: 400.ms),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Recent leads shimmer
                  ...List.generate(
                    5,
                    (index) => const ShimmerLeadListItem()
                        .animate(delay: Duration(milliseconds: index * 100))
                        .fadeIn(duration: 400.ms),
                  ),
                ],
              ),
            )
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
                        _pieAnimationController.reset();
                        await ref.read(leadProvider.notifier).getStatistics();
                        if (mounted) {
                          _pieAnimationController.forward();
                        }
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards Grid with staggered animation
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
                                ).animate()
                                  .fadeIn(duration: 400.ms, delay: 0.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                                DashboardStatsCard(
                                  title: l10n.conversionRate,
                                  value: '${stats.conversionRate.toStringAsFixed(1)}%',
                                  animatedValue: stats.conversionRate,
                                  isPercentage: true,
                                  icon: Icons.trending_up,
                                  color: Colors.green,
                                ).animate()
                                  .fadeIn(duration: 400.ms, delay: 100.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                                DashboardStatsCard(
                                  title: l10n.newLeads,
                                  value: stats.byStatus.newCount.toString(),
                                  animatedValue: stats.byStatus.newCount,
                                  icon: Icons.fiber_new,
                                  color: Colors.orange,
                                  onTap: () => context.go('/new-leads'),
                                ).animate()
                                  .fadeIn(duration: 400.ms, delay: 200.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                                DashboardStatsCard(
                                  title: l10n.wonLeads,
                                  value: stats.byStatus.closed.toString(),
                                  animatedValue: stats.byStatus.closed,
                                  icon: Icons.check_circle,
                                  color: Colors.purple,
                                  onTap: () => context.go('/closed'),
                                ).animate()
                                  .fadeIn(duration: 400.ms, delay: 300.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Pie Chart Section
                            Text(
                              l10n.leadsByStatus,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 16),
                            
                            AnimatedBuilder(
                              animation: _pieAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.5 + (_pieAnimation.value * 0.5),
                                  child: Opacity(
                                    opacity: _pieAnimation.value,
                                    child: SizedBox(
                                      height: 350,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                              setState(() {
                                                if (!event.isInterestedForInteractions ||
                                                    pieTouchResponse == null ||
                                                    pieTouchResponse.touchedSection == null) {
                                                  touchedIndex = -1;
                                                  return;
                                                }
                                                touchedIndex = pieTouchResponse
                                                    .touchedSection!.touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 60,
                                          sections: _getAnimatedSections(stats.byStatus, _pieAnimation.value),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Legend with staggered animation in 2x2 grid
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: _buildLegendItem(l10n.statusNew, stats.byStatus.newCount, AppTheme.newLeadColor)
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 600.ms)
                                        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 600.ms),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: _buildLegendItem(l10n.statusInProcess, stats.byStatus.inProcess, AppTheme.inProcessColor)
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 750.ms)
                                        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 750.ms),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: _buildLegendItem(l10n.statusClosed, stats.byStatus.closed, AppTheme.closedColor)
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 900.ms)
                                        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 900.ms),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: _buildLegendItem(l10n.statusNotRelevant, stats.byStatus.notRelevant, AppTheme.notRelevantColor)
                                        .animate()
                                        .fadeIn(duration: 500.ms, delay: 1050.ms)
                                        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 1050.ms),
                                    ),
                                  ],
                                ),
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
                              child: Stack(
                                children: [
                                  BarChart(
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
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
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
                                  // Overlay bar values
                                  ..._buildBarValueOverlays(stats.bySource),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Recent Activity Section
                            _buildRecentActivitySection(context, l10n, ref),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: AnimatedFab(
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

  Widget _buildLegendItem(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getAnimatedSections(StatusStats stats, double animationValue) {
    final total = stats.newCount + stats.inProcess + stats.closed + stats.notRelevant;
    if (total == 0) return [];

    int sectionIndex = 0;
    final sections = <PieChartSectionData>[];
    
    if (stats.newCount > 0) {
      sections.add(_buildAnimatedSection(
        stats.newCount, 
        total, 
        AppTheme.newLeadColor, 
        sectionIndex,
        animationValue,
      ));
      sectionIndex++;
    }
    
    if (stats.inProcess > 0) {
      sections.add(_buildAnimatedSection(
        stats.inProcess, 
        total, 
        AppTheme.inProcessColor, 
        sectionIndex,
        animationValue,
      ));
      sectionIndex++;
    }
    
    if (stats.closed > 0) {
      sections.add(_buildAnimatedSection(
        stats.closed, 
        total, 
        AppTheme.closedColor, 
        sectionIndex,
        animationValue,
      ));
      sectionIndex++;
    }
    
    if (stats.notRelevant > 0) {
      sections.add(_buildAnimatedSection(
        stats.notRelevant, 
        total, 
        AppTheme.notRelevantColor, 
        sectionIndex,
        animationValue,
      ));
      sectionIndex++;
    }
    
    return sections;
  }

  PieChartSectionData _buildAnimatedSection(
    int value, 
    int total, 
    Color color, 
    int index,
    double animationValue,
  ) {
    final percentage = (value / total) * 100;
    const fontSize = 18.0;
    const baseRadius = 80.0;
    
    // Stagger animation for each section
    final sectionDelay = index * 0.15;
    final adjustedAnimation = ((animationValue - sectionDelay) / (1 - sectionDelay)).clamp(0.0, 1.0);
    
    // Calculate animated values
    final animatedValue = value.toDouble() * adjustedAnimation;
    final isTouched = index == touchedIndex;
    final radius = isTouched ? baseRadius + 20 : baseRadius;
    final shadowElevation = isTouched ? 8.0 : 0.0;

    return PieChartSectionData(
      color: color,
      value: animatedValue,
      title: adjustedAnimation > 0.5 ? '${percentage.toStringAsFixed(0)}%' : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: isTouched ? [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
          ),
        ] : null,
      ),
      badgeWidget: isTouched ? Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ) : null,
      badgePositionPercentageOffset: 1.3,
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

  List<Widget> _buildBarValueOverlays(SourceStats stats) {
    final maxValue = _getMaxSourceCount(stats).toDouble() + 2;
    final values = [
      stats.facebook,
      stats.instagram,
      stats.whatsapp,
      stats.tiktok,
      stats.manual,
      stats.webhook,
    ];
    
    return List.generate(6, (index) {
      final value = values[index];
      if (value == 0) return const SizedBox.shrink();
      
      // Calculate position based on bar index and value
      // Chart has 6 bars evenly spaced with reserved space on left (40px)
      final chartWidth = MediaQuery.of(context).size.width - 32 - 40; // padding + left axis
      final barSpacing = chartWidth / 6;
      final xPosition = 40 + (barSpacing * index) + (barSpacing / 2) - 12; // centered on bar
      
      // Calculate y position based on value (inverted because chart coordinates)
      final chartHeight = 200 - 40; // total height - bottom axis
      final yPosition = chartHeight * (1 - (value / maxValue)) - 20; // 20px above bar
      
      return Positioned(
        left: xPosition,
        top: yPosition,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 1000 + (index * 100)))
          .slideY(begin: 0.5, end: 0, duration: 500.ms, delay: Duration(milliseconds: 1000 + (index * 100))),
      );
    });
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

  Widget _buildRecentActivitySection(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final leadState = ref.watch(leadProvider);
    final recentLeads = leadState.leads.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentActivity ?? 'Recent Activity',
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
              ).animate(delay: Duration(milliseconds: index * 100))
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
            );
          }).toList(),
      ],
    );
  }
}
