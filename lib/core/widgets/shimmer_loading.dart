import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Attractive shimmer loading widget for initial app load
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? Colors.grey.shade800 
        : Colors.grey.shade300;
    final highlightColor = isDark 
        ? Colors.grey.shade700 
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            _buildHeaderShimmer(),
            const SizedBox(height: 24),
            
            // Stats cards shimmer
            Row(
              children: [
                Expanded(child: _buildStatCardShimmer()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardShimmer()),
              ],
            ),
            const SizedBox(height: 24),
            
            // Section title
            _buildRoundedBox(width: 150, height: 20),
            const SizedBox(height: 16),
            
            // Habit tiles shimmer
            _buildHabitTileShimmer(),
            _buildHabitTileShimmer(),
            _buildHabitTileShimmer(),
            
            const SizedBox(height: 24),
            
            // Routines section
            _buildRoundedBox(width: 180, height: 20),
            const SizedBox(height: 16),
            
            // Routine card shimmer
            _buildRoutineCardShimmer(),
            const SizedBox(height: 12),
            _buildRoutineCardShimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoundedBox(width: 100, height: 14),
            const SizedBox(height: 8),
            _buildRoundedBox(width: 160, height: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoundedBox(width: 40, height: 40),
          const SizedBox(height: 12),
          _buildRoundedBox(width: 60, height: 24),
          const SizedBox(height: 8),
          _buildRoundedBox(width: 100, height: 14),
        ],
      ),
    );
  }

  Widget _buildHabitTileShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          _buildRoundedBox(width: 50, height: 14),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildRoundedBox(width: double.infinity, height: 16)),
        ],
      ),
    );
  }

  Widget _buildRoutineCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoundedBox(width: 140, height: 16),
                const SizedBox(height: 8),
                _buildRoundedBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Shimmer loading for routine detail page
class ShimmerRoutineDetail extends StatelessWidget {
  const ShimmerRoutineDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            // Habit items
            for (int i = 0; i < 5; i++) ...[
              _buildHabitItemShimmer(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItemShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 70,
    );
  }
}
