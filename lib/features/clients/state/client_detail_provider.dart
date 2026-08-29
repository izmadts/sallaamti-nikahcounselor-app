import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/client_list_screen.dart';

final clientDetailProvider = FutureProvider.family.autoDispose((ref, int leadId) async {
  final repo = ref.watch(clientRepositoryProvider);
  final data = await repo.show(leadId);
  return Map<String, dynamic>.from(data['client'] as Map);
});
