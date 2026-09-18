import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_data/hifz_data.dart';

import 'hifz_logging_providers.dart';
import 'logging_strings.dart';
import 'recent_reviews_list.dart';

/// Arabic RTL form for logging a review.
///
/// Mirrors the contract rules client-side (ayah range within the surah and
/// `ayahTo >= ayahFrom`) so an obvious mistake never reaches the outbox.
class LogReviewScreen extends ConsumerStatefulWidget {
  const LogReviewScreen({super.key, this.studentId});

  final String? studentId;

  @override
  ConsumerState<LogReviewScreen> createState() => _LogReviewScreenState();
}

class _LogReviewScreenState extends ConsumerState<LogReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController(text: '1');
  final _toController = TextEditingController(text: '1');

  SurahInfo _surah = kSurahs.first;
  ReviewQuality _quality = ReviewQuality.GOOD;
  List<ReviewRecord> _recent = const [];
  String? _error;
  StreamSubscription<int>? _pendingSubscription;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _pendingSubscription = ref.read(syncWorkerProvider).pendingCountStream.listen((count) {
      if (mounted) setState(() => _pending = count);
    });
    unawaited(_loadRecent());
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final items = await ref.read(reviewRepositoryProvider).listCached();
    if (mounted) setState(() => _recent = items);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = CreateReviewRequest(
      (builder) => builder
        ..surahNumber = _surah.number
        ..ayahFrom = int.parse(_fromController.text)
        ..ayahTo = int.parse(_toController.text)
        ..quality = _quality,
    );

    final result = await ref
        .read(reviewRepositoryProvider)
        .logReview(request, studentId: widget.studentId);

    if (!mounted) return;
    result.when(
      ok: (record) => setState(() => _recent = [record, ..._recent]),
      err: (failure) => setState(() => _error = failure.message),
    );
  }

  String? _validateAyah(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 1 || parsed > _surah.ayahCount) {
      return ref.read(loggingStringsProvider).rangeError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(loggingStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        actions: [
          if (_pending > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: Chip(
                  key: const Key('outbox-badge'),
                  label: Text('$_pending'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<SurahInfo>(
              key: const Key('surah-field'),
              initialValue: _surah,
              decoration: InputDecoration(labelText: strings.surah),
              items: [
                for (final surah in kSurahs)
                  DropdownMenuItem(
                    value: surah,
                    child: Text('${surah.nameAr} (${surah.number})'),
                  ),
              ],
              onChanged: (value) => setState(() => _surah = value ?? _surah),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('ayah-from-field'),
              controller: _fromController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: strings.ayahFrom),
              validator: _validateAyah,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('ayah-to-field'),
              controller: _toController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: strings.ayahTo),
              validator: (value) {
                final basic = _validateAyah(value);
                if (basic != null) return basic;
                final from = int.parse(_fromController.text);
                if (int.parse(value!) < from) return strings.rangeError;
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(strings.quality, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final quality in ReviewQuality.values)
                  ChoiceChip(
                    key: Key('quality-${quality.name}'),
                    label: Text(_qualityLabel(strings, quality)),
                    selected: _quality == quality,
                    onSelected: (_) => setState(() => _quality = quality),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  key: const Key('submit-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              key: const Key('submit-button'),
              onPressed: _submit,
              child: Text(strings.submit),
            ),
            const SizedBox(height: 24),
            Text(strings.recentReviews, style: Theme.of(context).textTheme.titleSmall),
            RecentReviewsList(reviews: _recent, strings: strings),
          ],
        ),
      ),
    );
  }

  String _qualityLabel(LoggingStrings strings, ReviewQuality quality) => switch (quality) {
        ReviewQuality.GOOD => strings.qualityGood,
        ReviewQuality.FAIR => strings.qualityFair,
        _ => strings.qualityPoor,
      };
}
