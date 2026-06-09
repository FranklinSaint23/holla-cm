import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: HollaColors.grey300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _shimmerWrap(Widget child) {
  return Shimmer.fromColors(
    baseColor: HollaColors.grey300,
    highlightColor: HollaColors.grey100,
    child: child,
  );
}

class SkeletonPartnerCard extends StatelessWidget {
  const SkeletonPartnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 200, height: 120, radius: 20),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 140, height: 14),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 100, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonNearbyCard extends StatelessWidget {
  const SkeletonNearbyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _ShimmerBox(width: 64, height: 64, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 120, height: 11),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 80, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}