import 'package:flutter/material.dart';

class FinancialSummaryBox extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;

  // Optional enhancements
  final double? maxValue;            // for progress indicator
  final String? subtitle;            // extra info text
  final VoidCallback? onTap;         // card click
  final bool showTrendUp;            // arrow indicator

  const FinancialSummaryBox({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.maxValue,
    this.subtitle,
    this.onTap,
    this.showTrendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (maxValue != null && maxValue! > 0)
        ? (value / maxValue!).clamp(0.0, 1.0)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON + TREND
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(width: 6),
                Icon(
                  showTrendUp ? Icons.trending_up : Icons.trending_down,
                  color: showTrendUp ? Colors.green : Colors.red,
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TITLE
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 6),

            /// VALUE
            Text(
              "₹ ${value.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
