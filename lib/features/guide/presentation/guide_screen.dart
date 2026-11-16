import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/guide_section_card.dart';
import '../domain/guide_content.dart';

class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
    final sections = GuideContent.forLocale(languageCode);
    final isRtl = languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guideTitle)),
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: sections.length,
          itemBuilder: (context, index) => GuideSectionCard(title: sections[index].title, paragraphs: sections[index].paragraphs),
        ),
      ),
    );
  }
}
