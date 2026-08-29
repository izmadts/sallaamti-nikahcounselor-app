import 'package:flutter/material.dart';

// Filled, color-coded status pill — matches the project's standing
// "charming, filled-color UI, not flat/outline" convention.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.forLeadStatus(String status) {
    final colors = {
      'new': Colors.blue,
      'contacted': Colors.amber,
      'interested': Colors.purple,
      'registered': Colors.green,
      'not_interested': Colors.grey,
      'closed': Colors.grey,
    };
    return StatusChip(label: _humanize(status), color: colors[status] ?? Colors.grey);
  }

  factory StatusChip.forCommissionStatus(String status) {
    final colors = {
      'pending': Colors.amber,
      'approved': Colors.blue,
      'paid': Colors.green,
    };
    return StatusChip(label: _humanize(status), color: colors[status] ?? Colors.grey);
  }

  static String _humanize(String value) {
    final spaced = value.replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color.withValues(alpha: 0.9), fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
