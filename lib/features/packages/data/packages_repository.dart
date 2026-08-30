import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/state/auth_controller.dart';

class NikahPackageInfo {
  final int id;
  final String name;
  final String? tagline;
  final String? description;
  final List<dynamic> features;
  final num price;
  final String? currency;
  final int? durationDays;
  final int? proposalLimit;
  final String? consultantLevel;
  final bool isOneTime;
  final String? color;

  NikahPackageInfo({
    required this.id,
    required this.name,
    this.tagline,
    this.description,
    required this.features,
    required this.price,
    this.currency,
    this.durationDays,
    this.proposalLimit,
    this.consultantLevel,
    required this.isOneTime,
    this.color,
  });

  factory NikahPackageInfo.fromJson(Map<String, dynamic> json) => NikahPackageInfo(
        id: _asInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        tagline: json['tagline']?.toString(),
        description: json['description']?.toString(),
        features: _asList(json['features']),
        // Laravel's decimal:2 cast serializes price as a string ("1000.00"),
        // not a JSON number.
        price: num.tryParse(json['price'].toString()) ?? 0,
        currency: json['currency']?.toString(),
        durationDays: _asInt(json['duration_days']),
        proposalLimit: _asInt(json['proposal_limit']),
        consultantLevel: json['consultant_level']?.toString(),
        isOneTime: json['is_one_time'] == true || json['is_one_time'] == 1,
        color: json['color']?.toString(),
      );

  // A JSON array with non-sequential PHP keys (e.g. a feature list edited
  // down over time without reindexing) serializes as a JSON *object*, not
  // an array — 'as List' threw on any package whose features had that
  // shape. Falls back to the map's values, or [] for anything else.
  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value is Map) return value.values.toList();
    return [];
  }

  // Handles an int, a numeric string, or a decimal-cast string like the
  // price field above.
  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class PackagesRepository {
  final ApiClient _client;
  PackagesRepository(this._client);

  Future<List<NikahPackageInfo>> index() async {
    final data = await _client.get('/matchmaker/meta/packages');
    return (data['packages'] as List).map((e) => NikahPackageInfo.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final packagesRepositoryProvider = Provider((ref) => PackagesRepository(ref.watch(apiClientProvider)));

final packagesProvider = FutureProvider.autoDispose((ref) => ref.watch(packagesRepositoryProvider).index());
