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
        id: json['id'] as int,
        name: json['name'] as String,
        tagline: json['tagline'] as String?,
        description: json['description'] as String?,
        features: (json['features'] as List?) ?? [],
        // Laravel's decimal:2 cast serializes price as a string ("1000.00"),
        // not a JSON number — 'as num' threw on every real response.
        price: num.parse(json['price'].toString()),
        currency: json['currency'] as String?,
        durationDays: json['duration_days'] as int?,
        proposalLimit: json['proposal_limit'] as int?,
        consultantLevel: json['consultant_level'] as String?,
        isOneTime: json['is_one_time'] as bool? ?? false,
        color: json['color'] as String?,
      );
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
