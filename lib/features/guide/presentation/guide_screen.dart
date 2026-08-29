import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
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
          itemBuilder: (context, index) => _GuideSectionCard(section: sections[index], index: index),
        ),
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  final GuideSection section;
  final int index;
  const _GuideSectionCard({required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(section.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: MatchmakerTheme.plumDark)),
            const SizedBox(height: 10),
            for (final paragraph in section.paragraphs) _GuideParagraph(text: paragraph),
          ],
        ),
      ),
    );
  }
}

// Tiny renderer for the guide content's markup: "• " starts a bullet,
// **word** renders bold — enough for this content without pulling in a
// full markdown package.
class _GuideParagraph extends StatelessWidget {
  final String text;
  const _GuideParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final isBullet = text.startsWith('• ');
    final body = isBullet ? text.substring(2) : text;
    final spans = _parseBold(body);

    final content = RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.5, height: 1.5, color: Colors.grey.shade800), children: spans));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isBullet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 2, right: 6), child: Text('•', style: TextStyle(fontWeight: FontWeight.w800, color: MatchmakerTheme.plum))),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }

  List<TextSpan> _parseBold(String source) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var lastEnd = 0;

    for (final match in pattern.allMatches(source)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: source.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)));
      lastEnd = match.end;
    }
    if (lastEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastEnd)));
    }
    return spans;
  }
}
