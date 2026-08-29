import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_store.dart';
import '../../auth/state/auth_controller.dart';

class CertificateStatus {
  final bool hasCertificate;
  final String? certificateNumber;
  final DateTime? issuedAt;
  final String? mailingAddress;
  final DateTime? cardRequestedAt;
  final DateTime? cardDispatchedAt;

  CertificateStatus({
    required this.hasCertificate,
    this.certificateNumber,
    this.issuedAt,
    this.mailingAddress,
    this.cardRequestedAt,
    this.cardDispatchedAt,
  });

  factory CertificateStatus.fromJson(Map<String, dynamic> json) => CertificateStatus(
        hasCertificate: json['has_certificate'] as bool? ?? false,
        certificateNumber: json['certificate_number'] as String?,
        issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
        mailingAddress: json['mailing_address'] as String?,
        cardRequestedAt: json['card_requested_at'] != null ? DateTime.parse(json['card_requested_at'] as String) : null,
        cardDispatchedAt: json['card_dispatched_at'] != null ? DateTime.parse(json['card_dispatched_at'] as String) : null,
      );
}

class CertificateRepository {
  final ApiClient _client;
  CertificateRepository(this._client);

  Future<CertificateStatus> show() async {
    final data = await _client.get('/matchmaker/certificate');
    return CertificateStatus.fromJson(data);
  }

  Future<void> requestDispatch() => _client.post('/matchmaker/certificate/request-dispatch');

  // The PDF endpoint isn't JSON, so this bypasses ApiClient's helpers and
  // talks to Dio directly — same base URL/bearer-token pattern, just a
  // binary response saved straight to a temp file for share_plus to hand
  // off to the OS (open/save/share), since a viewer sandbox can't render
  // a PDF byte stream on its own.
  Future<File> downloadPdf() async {
    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    final token = await SecureStore.readToken();

    final response = await dio.get<List<int>>(
      '/matchmaker/certificate/download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Sallaamti-Nikah-Counselor-ID.pdf');
    await file.writeAsBytes(response.data!);
    return file;
  }
}

final certificateRepositoryProvider = Provider((ref) => CertificateRepository(ref.watch(apiClientProvider)));

final certificateStatusProvider = FutureProvider.autoDispose((ref) => ref.watch(certificateRepositoryProvider).show());
