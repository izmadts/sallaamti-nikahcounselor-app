import 'package:flutter/material.dart';

// How well a candidate fits a client's stated Requirements — computed
// server-side by Lead::matchScoreWith() from must_have/preferred/flexible
// requirement items. `level` is null when there's nothing to judge by (no
// Requirements saved yet, or none of them are types the algorithm can
// compare against a profile), which is genuinely different from a
// low-scoring match and must not render as one.
class MatchScore {
  final String? level;
  final int percentage;
  final int considered;

  MatchScore({required this.level, required this.percentage, required this.considered});

  static MatchScore? fromJson(dynamic json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;
    return MatchScore(
      level: map['level'] as String?,
      percentage: map['percentage'] as int? ?? 0,
      considered: map['considered'] as int? ?? 0,
    );
  }
}

class MatchScoreBadge extends StatelessWidget {
  final MatchScore? score;
  final bool small;
  const MatchScoreBadge({super.key, required this.score, this.small = false});

  @override
  Widget build(BuildContext context) {
    final level = score?.level;
    if (level == null) return const SizedBox.shrink();

    final (color, emoji, label) = switch (level) {
      'high' => (Colors.green.shade600, '🟢', 'High match'),
      'medium' => (Colors.amber.shade700, '🟡', 'Medium match'),
      _ => (Colors.grey.shade600, '⚪', 'Low match'),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        '$emoji $label (${score!.percentage}%)',
        style: TextStyle(color: color, fontSize: small ? 10 : 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
