import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/auth/state/auth_controller.dart';

class AppUpdateStatus {
  final bool updateRequired;
  final String? updateUrl;
  const AppUpdateStatus({required this.updateRequired, this.updateUrl});
}

// Mirrors the member app's own appUpdateProvider — same shared backend
// endpoint, just ?app=matchmaker so it reads matchmaker_app_min_build
// instead. Checked once by SplashScreen before it routes anywhere else;
// fails open on any error so a check that can't complete never locks
// every counselor out.
final appUpdateProvider = FutureProvider<AppUpdateStatus>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;

    final client = ref.read(apiClientProvider);
    final data = await client.get('/meta/app-version', query: {'app': 'matchmaker'});

    final minimumBuild = data['minimum_build_number'] as int?;
    if (minimumBuild != null && currentBuild > 0 && currentBuild < minimumBuild) {
      return AppUpdateStatus(updateRequired: true, updateUrl: data['update_url'] as String?);
    }
  } catch (_) {
    // Fall through to "no update required" below.
  }

  return const AppUpdateStatus(updateRequired: false);
});
