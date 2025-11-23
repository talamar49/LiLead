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
import 'add_lead_screen.dart';

class NewLeadsScreen extends ConsumerStatefulWidget {
  const NewLeadsScreen({super.key});

  @override
  ConsumerState<NewLeadsScreen> createState() => _NewLeadsScreenState();
}

class _NewLeadsScreenState extends ConsumerState<NewLeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leadProvider.notifier).getLeads(status: LeadStatus.NEW);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leadsState = ref.watch(leadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newLeads),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatar(size: 36),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(leadProvider.notifier).getLeads(status: LeadStatus.NEW);
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
                            Text(
                              l10n.errorGeneric,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(leadProvider.notifier).getLeads(status: LeadStatus.NEW);
                              },
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : leadsState.filteredLeads.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noLeadsFound,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(leadProvider.notifier).getLeads(status: LeadStatus.NEW);
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
                                      ref.read(leadProvider.notifier).getLeads(status: LeadStatus.NEW);
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
}
