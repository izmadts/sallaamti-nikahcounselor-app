import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchmaker_app/core/api/api_client.dart';
import 'package:matchmaker_app/features/auth/state/auth_controller.dart';
import 'package:matchmaker_app/features/clients/presentation/client_list_screen.dart';
import 'package:matchmaker_app/features/notifications/data/notification_repository.dart';
import 'package:matchmaker_app/l10n/generated/app_localizations.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    if (path == '/matchmaker/clients') {
      return {
        'clients': [
          {
            'id': 1,
            'name': 'Test Client',
            'gender': 'female',
            'phone': '03001234567',
            'email': null,
            'status': 'new',
            'source': 'walk_in',
            'assigned_to': null,
            'is_converted': false,
            'nikah_profile_id': 5,
            'next_follow_up_at': null,
            'created_at': DateTime.now().toIso8601String(),
            'unread_message_count': 0,
          },
        ],
        'current_page': 1,
        'last_page': 1,
        'total': 1,
        'stats': {'new': 1, 'contacted': 0, 'registered': 0, 'follow_ups_due': 0},
        'can_manage_team': false,
      };
    }
    return {};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async => null,
  );

  testWidgets('Clients list renders cards without throwing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_FakeApiClient()),
          unreadNotificationCountProvider.overrideWith((ref) => Stream.value(0)),
        ],
        child: MaterialApp(
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ClientListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Test Client'), findsOneWidget);
  });
}
