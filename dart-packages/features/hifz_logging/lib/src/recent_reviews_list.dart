import 'package:flutter/material.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_data/hifz_data.dart';

import 'logging_strings.dart';

class RecentReviewsList extends StatelessWidget {
  const RecentReviewsList({super.key, required this.reviews, required this.strings});

  final List<ReviewRecord> reviews;
  final LoggingStrings strings;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(strings.emptyRecent),
      );
    }
    return Column(
      children: [
        for (final review in reviews)
          ListTile(
            key: ValueKey(review.id),
            title: Text(
              '${surahByNumber(review.surahNumber)?.nameAr ?? review.surahNumber} '
              '(${review.ayahFrom}-${review.ayahTo})',
            ),
            subtitle: Text(_qualityLabel(review.quality)),
            trailing: review.pendingSync
                ? Chip(
                    label: Text(strings.pendingSync),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
      ],
    );
  }

  String _qualityLabel(String quality) => switch (quality) {
        'GOOD' => strings.qualityGood,
        'FAIR' => strings.qualityFair,
        _ => strings.qualityPoor,
      };
}
