import { describe, expect, it } from 'vitest';
import { CreateReviewRequestSchema, IDEMPOTENCY_KEY_HEADER } from '../src/index';

describe('review contracts', () => {
  it('accepts a valid review', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' }).success).toBe(true);
  });
  it('rejects surah out of range and bad quality', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 115, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' }).success).toBe(false);
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GREAT' }).success).toBe(false);
  });
  it('rejects ayahTo < ayahFrom', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 2, ayahFrom: 10, ayahTo: 5, quality: 'FAIR' }).success).toBe(false);
  });
  it('exports the idempotency header name', () => {
    expect(IDEMPOTENCY_KEY_HEADER).toBe('Idempotency-Key');
  });
});
