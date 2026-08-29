import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../state/client_detail_provider.dart';
import 'tabs/batches_tab.dart';
import 'tabs/consent_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/requirements_tab.dart';
import 'tabs/shortlist_tab.dart';

class ClientDetailScreen extends ConsumerWidget {
  final int leadId;
  const ClientDetailScreen({super.key, required this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clientDetailProvider(leadId));

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(async.value?['name'] as String? ?? '...'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.clientTabOverview),
              Tab(text: l10n.clientTabRequirements),
              Tab(text: l10n.clientTabShortlist),
              Tab(text: l10n.clientTabConsent),
              Tab(text: l10n.clientTabBatches),
            ],
          ),
        ),
        body: AsyncValueView(
          loading: async.isLoading,
          error: async.error,
          data: async.value,
          onRetry: () => ref.invalidate(clientDetailProvider(leadId)),
          builder: (client) => TabBarView(
            children: [
              OverviewTab(leadId: leadId, client: client),
              RequirementsTab(leadId: leadId, client: client),
              ShortlistTab(leadId: leadId, client: client),
              ConsentTab(leadId: leadId, client: client),
              BatchesTab(leadId: leadId, client: client),
            ],
          ),
        ),
      ),
    );
  }
}
