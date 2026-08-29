import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/state/auth_controller.dart';

class PaymentAccounts {
  final String? jazzcashNumber;
  final String? jazzcashAccountTitle;
  final String? easypaisaNumber;
  final String? bankName;
  final String? bankAccountTitle;
  final String? bankAccountNumber;
  final String? bankAccountIban;

  PaymentAccounts({
    this.jazzcashNumber,
    this.jazzcashAccountTitle,
    this.easypaisaNumber,
    this.bankName,
    this.bankAccountTitle,
    this.bankAccountNumber,
    this.bankAccountIban,
  });

  bool get isEmpty =>
      [jazzcashNumber, easypaisaNumber, bankAccountNumber, bankAccountIban].every((v) => v == null || v.isEmpty);

  factory PaymentAccounts.fromJson(Map<String, dynamic> json) => PaymentAccounts(
        jazzcashNumber: json['jazzcash_number'] as String?,
        jazzcashAccountTitle: json['jazzcash_account_title'] as String?,
        easypaisaNumber: json['easypaisa_number'] as String?,
        bankName: json['bank_name'] as String?,
        bankAccountTitle: json['bank_account_title'] as String?,
        bankAccountNumber: json['bank_account_number'] as String?,
        bankAccountIban: json['bank_account_iban'] as String?,
      );
}

class PaymentAccountsRepository {
  final ApiClient _client;
  PaymentAccountsRepository(this._client);

  Future<PaymentAccounts> show() async {
    final data = await _client.get('/matchmaker/meta/payment-accounts');
    return PaymentAccounts.fromJson(data);
  }
}

final paymentAccountsRepositoryProvider = Provider((ref) => PaymentAccountsRepository(ref.watch(apiClientProvider)));

final paymentAccountsProvider = FutureProvider.autoDispose((ref) => ref.watch(paymentAccountsRepositoryProvider).show());
