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
  final List<MatchScoreItem> breakdown;

  MatchScore({required this.level, required this.percentage, required this.considered, this.breakdown = const []});

  static MatchScore? fromJson(dynamic json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;
    return MatchScore(
      level: map['level'] as String?,
      percentage: map['percentage'] as int? ?? 0,
      considered: map['considered'] as int? ?? 0,
      breakdown: ((map['breakdown'] as List?) ?? const [])
          .map((e) => MatchScoreItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

// One of the client's saved Requirements, and whether this specific
// candidate matched it — mirrors Lead::matchScoreWith()'s $breakdown
// exactly, in the same order the weighting was computed in.
class MatchScoreItem {
  final String type;
  final String label;
  final String value;
  final String priority;
  final bool matched;

  MatchScoreItem({required this.type, required this.label, required this.value, required this.priority, required this.matched});

  factory MatchScoreItem.fromJson(Map<String, dynamic> json) => MatchScoreItem(
        type: json['type'] as String,
        label: json['label'] as String,
        value: json['value'] as String,
        priority: json['priority'] as String,
        matched: json['matched'] as bool? ?? false,
      );
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

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showExplanation(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$emoji $label (${score!.percentage}%)',
              style: TextStyle(color: color, fontSize: small ? 10 : 11, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: small ? 2 : 4),
            Icon(Icons.info_outline, size: small ? 11 : 13, color: color),
          ],
        ),
      ),
    );
  }

  void _showExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MatchScoreSheet(score: score!),
    );
  }
}

class _MatchScoreSheet extends StatelessWidget {
  final MatchScore score;
  const _MatchScoreSheet({required this.score});

  String _priorityLabel(String priority) => switch (priority) {
        'must_have' => 'Must Have (×3)',
        'preferred' => 'Preferred (×2)',
        _ => 'Flexible (×1)',
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How this ${score.percentage}% is calculated', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              'Each of the client\'s saved requirements is checked against this candidate\'s profile. Must Have counts 3×, Preferred 2×, Flexible 1× — the percentage is matched weight ÷ total weight, across only the requirements that could actually be checked.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (score.breakdown.isEmpty)
              Text('No requirements could be checked against this candidate.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
            else
              ...score.breakdown.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.matched ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: item.matched ? Colors.green.shade600 : Colors.red.shade400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.label}: ${item.value}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(_priorityLabel(item.priority), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
