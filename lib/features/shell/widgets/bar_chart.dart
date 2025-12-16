import 'package:flutter/material.dart';

/// Widget de barra para gráfico de estadísticas semanales
class BarChart extends StatelessWidget {
  final String label;
  final double height;
  final int count;
  final bool isHighlighted;

  const BarChart({
    super.key,
    required this.label,
    required this.height,
    this.count = 0,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Text(
            '$count',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
          ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: height > 0 ? (100 * height).clamp(10, 100) : 10,
          decoration: BoxDecoration(
            color: isHighlighted 
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }
}
