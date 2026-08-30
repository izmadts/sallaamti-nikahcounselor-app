import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/state/auth_controller.dart';

class MatchmakerEnums {
  final Map<String, String> consentTypes;
  final Map<String, String> consentMethods;
  final Map<String, String> leadStatuses;
  final Map<String, String> leadSources;
  final Map<String, String> lookingFor;
  final Map<String, String> requirementPriorities;
  final Map<String, String> requirementTypes;

  MatchmakerEnums({
    required this.consentTypes,
    required this.consentMethods,
    required this.leadStatuses,
    required this.leadSources,
    required this.lookingFor,
    required this.requirementPriorities,
    required this.requirementTypes,
  });

  factory MatchmakerEnums.fromJson(Map<String, dynamic> json) => MatchmakerEnums(
        consentTypes: _map(json['consent_types']),
        consentMethods: _map(json['consent_methods']),
        leadStatuses: _map(json['lead_statuses']),
        leadSources: _map(json['lead_sources']),
        lookingFor: _map(json['looking_for']),
        requirementPriorities: _map(json['requirement_priorities']),
        requirementTypes: _map(json['requirement_types']),
      );

  static Map<String, String> _map(dynamic raw) =>
      Map<String, dynamic>.from(raw as Map? ?? {}).map((k, v) => MapEntry(k, v.toString()));
}

// Fetched once and cached for the session — these enums almost never
// change, and every picker across the app reads from this single provider
// instead of refetching per screen.
final enumsProvider = FutureProvider<MatchmakerEnums>((ref) async {
  final client = ref.watch(apiClientProvider);
  final data = await client.get('/matchmaker/meta/enums');
  return MatchmakerEnums.fromJson(data);
});
