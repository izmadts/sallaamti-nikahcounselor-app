import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_store.dart';

// null = not yet chosen (first launch) → the router sends the user to the
// language picker before anything else.
final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(),
);

class LocaleController extends StateNotifier<Locale?> {
  late final Future<void> _restoring;

  LocaleController() : super(null) {
    _restoring = _restore();
  }

  Future<void> _restore() async {
    final code = await SecureStore.readLocale();
    if (code != null) {
      state = Locale(code);
    }
  }

  // Awaited by the splash screen before it decides whether to show the
  // language picker. Without this, `state` was read (via ref.watch) one
  // frame after construction — before the async secure-storage read above
  // had any chance to complete — so a returning user with an already-saved
  // locale still saw `null` and got sent to the picker every single time
  // the app opened, not just on first install.
  Future<Locale?> ensureRestored() async {
    await _restoring;
    return state;
  }

  Future<void> choose(String code) async {
    await SecureStore.saveLocale(code);
    state = Locale(code);
  }
}
