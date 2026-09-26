import 'package:fitness_screen/core/app_colors.dart';
import 'package:fitness_screen/models/activity_segment.dart';
import 'package:fitness_screen/widgets/rounded_card.dart';
import 'package:fitness_screen/widgets/top_bar.dart';
import 'package:flutter/material.dart';

const _todaySegments = [
  ActivitySegment(label: '1h 15min', percent: 45, color: AppColors.barStrong),
  ActivitySegment(label: '1h 10min', percent: 38, color: AppColors.barMedium),
  ActivitySegment(label: '25min', percent: 17, color: AppColors.barLight),
];

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TopBar(),
            ),
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text('Statistics', style: textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          _TimelineRow(
                            icon: _TimelineIcon.done(),
                            card: _StatCard(
                              color: AppColors.lilac,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('2.5H', style: textTheme.headlineLarge),
                                  const SizedBox(height: 16),
                                  const _SegmentedBar(segments: _todaySegments),
                                ],
                              ),
                            ),
                          ),
                          const _TimelineRow(
                            icon: _TimelineIcon.active(),
                            card: _StatCard(
                              color: AppColors.mint,
                              child: SizedBox(height: 120),
                            ),
                          ),
                          _TimelineRow(
                            icon: _TimelineIcon.pending(),
                            card: _StatCard(
                              color: AppColors.peach,
                              child: SizedBox(height: 80),
                            ),
                            isLast: true,
                          ),
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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.card,
    this.isLast = false,
  });

  final Widget icon;
  final Widget card;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 8),
                icon,
                Expanded(
                  child: isLast
                      ? const SizedBox.shrink()
                      : Center(
                          child: Container(width: 1, color: AppColors.barLight),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

// class _TimelineRow extends StatelessWidget {
//   const _TimelineRow({
//     required this.icon,
//     required this.card,
//     this.isLast = false,
//   });

//   final Widget icon;
//   final Widget card;
//   final bool isLast;

//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Timeline
//           SizedBox(
//             width: 28,
//             child: Column(
//               children: [
//                 const SizedBox(height: 8),
//                 icon,
//                 Expanded(
//                   child: isLast
//                       ? const SizedBox.shrink()
//                       : Center(
//                           child: Container(width: 1, color: AppColors.barLight),
//                         ),
//                 ),
//               ],
//             ),
//           ),

//           // Gap between timeline and card
//           const SizedBox(width: 12),

//           // Card
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 16),
//               child: card,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _TimelineIcon extends StatelessWidget {
  const _TimelineIcon.done()
    : background = AppColors.dark,
      iconData = Icons.check,
      iconColor = AppColors.white;

  const _TimelineIcon.active()
    : background = AppColors.mint,
      iconData = Icons.graphic_eq,
      iconColor = AppColors.dark;

  const _TimelineIcon.pending()
    : background = AppColors.barLight,
      iconData = null,
      iconColor = null;

  final Color background;
  final IconData? iconData;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: iconData == null
          ? null
          : Icon(iconData, size: 14, color: iconColor),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RoundedCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'July, 14 Sat',
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    'View All',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
          // Placeholder for card content (progress bar / chart)
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.segments});
  final List<ActivitySegment> segments;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final segment in segments)
              Expanded(
                flex: segment.percent,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.label,
                        style: labelStyle?.copyWith(fontSize: 9),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 1,
                        height: segment.percent.toDouble(),
                        color: AppColors.barLight,
                      ),
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: segment.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final segment in segments)
              Expanded(
                flex: segment.percent,
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${segment.percent}%',
                        style: labelStyle?.copyWith(
                          fontSize: 10,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
