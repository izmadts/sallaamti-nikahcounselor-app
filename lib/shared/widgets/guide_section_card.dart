import 'package:flutter/material.dart';

import '../../core/theme/matchmaker_theme.dart';

// A titled card of paragraphs with a tiny built-in markup: "• " starts a
// bullet, **word** renders bold — enough for this app's guide-style
// content without pulling in a full markdown package. Extracted (15/16 Nov
// 2026) from the original /guide screen so the new Training Guide reuses
// the exact same rendering instead of duplicating it.
class GuideSectionCard extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  const GuideSectionCard({super.key, required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: MatchmakerTheme.plumDark)),
            const SizedBox(height: 10),
            for (final paragraph in paragraphs) GuideParagraph(text: paragraph),
          ],
        ),
      ),
    );
  }
}

class GuideParagraph extends StatelessWidget {
  final String text;
  const GuideParagraph({super.key, required this.text});

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
