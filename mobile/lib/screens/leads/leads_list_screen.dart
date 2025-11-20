import 'package:flutter/material.dart';
import '../../core/models/lead.dart';
import '../../core/services/lead_service.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_service.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  late final LeadService _service;
  late Future<List<Lead>> _leadsFuture;

  @override
  void initState() {
    super.initState();
    final dio = ApiClient.createDio();
    final api = ApiService(dio, baseUrl: dio.options.baseUrl);
    _service = LeadService(api);
    _leadsFuture = _service.getLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leads')),
      body: FutureBuilder<List<Lead>>(
        future: _leadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final leads = snapshot.data ?? [];
          if (leads.isEmpty) {
            return const Center(child: Text('No leads found'));
          }

          return ListView.separated(
            itemCount: leads.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lead = leads[index];
              return ListTile(
                title: Text('${lead.name}${lead.lastName != null ? ' ${lead.lastName}' : ''}'),
                subtitle: Text(lead.phone),
                trailing: Text(lead.status.displayName),
              );
            },
          );
        },
      ),
    );
  }
}
