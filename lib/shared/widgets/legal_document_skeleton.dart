import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/skeleton_shimmer_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Document-style loading placeholder for Privacy / Terms pages.
class LegalDocumentSkeleton extends StatelessWidget {
  const LegalDocumentSkeleton({super.key});

  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(24, 8, 24, 32);

  static const List<double> _lineWidthFactors = [
    1.0,
    0.92,
    0.55,
    1.0,
    0.78,
    0.45,
    0.88,
    0.62,
  ];

  @override
  Widget build(BuildContext context) {
    final base = SkeletonShimmerColors.base(context);
    final highlight = SkeletonShimmerColors.highlight(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final factor in _lineWidthFactors) ...[
              FractionallySizedBox(
                widthFactor: factor,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
