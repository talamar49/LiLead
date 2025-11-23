import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../providers/lead_provider.dart';
import '../../core/models/lead.dart';
import '../../core/models/lead.dart';
import '../../widgets/lead_list_item.dart';
import '../../widgets/slide_in_list_item.dart';
import '../../widgets/user_avatar.dart';

class ClosedLeadsScreen extends ConsumerStatefulWidget {
  const ClosedLeadsScreen({super.key});

  @override
  ConsumerState<ClosedLeadsScreen> createState() => _ClosedLeadsScreenState();
}

class _ClosedLeadsScreenState extends ConsumerState<ClosedLeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).getLeads(status: LeadStatus.CLOSED);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leadsState = ref.watch(leadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.closed),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatar(size: 36),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(leadProvider.notifier).getLeads(status: LeadStatus.CLOSED);
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
            ),
          ),
          Expanded(
            child: leadsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : leadsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.errorGeneric),
                            ElevatedButton(
                              onPressed: () => ref.read(leadProvider.notifier).getLeads(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : leadsState.filteredLeads.isEmpty
                        ? Center(
                            child: Text(l10n.noLeadsFound),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(leadProvider.notifier).getLeads(status: LeadStatus.CLOSED);
                            },
                            child: ListView.builder(
                              itemCount: leadsState.filteredLeads.length,
                              itemBuilder: (context, index) {
                                final lead = leadsState.filteredLeads[index];
                                return SlideInListItem(
                                  index: index,
                                  child: LeadListItem(
                                    lead: lead,
                                    onReturn: () {
                                      ref.read(leadProvider.notifier).getLeads(status: LeadStatus.CLOSED);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/leads/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
