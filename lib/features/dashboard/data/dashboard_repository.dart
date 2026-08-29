import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/state/auth_controller.dart';

class DashboardData {
  final Map<String, int> stats;
  final List<Map<String, dynamic>> followUps;
  final List<Map<String, dynamic>> recentActivity;

  DashboardData({required this.stats, required this.followUps, required this.recentActivity});

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        stats: Map<String, dynamic>.from(json['stats'] as Map).map((k, v) => MapEntry(k, v as int)),
        followUps: List<Map<String, dynamic>>.from((json['follow_ups'] as List).map((e) => Map<String, dynamic>.from(e as Map))),
        recentActivity: List<Map<String, dynamic>>.from((json['recent_activity'] as List).map((e) => Map<String, dynamic>.from(e as Map))),
      );
}

class DashboardRepository {
  final ApiClient _client;
  DashboardRepository(this._client);

  Future<DashboardData> fetch() async {
    final data = await _client.get('/matchmaker/dashboard');
    return DashboardData.fromJson(data);
  }
}
