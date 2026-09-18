import { z } from 'zod';

export const ReviewQualitySchema = z.enum(['GOOD', 'FAIR', 'POOR']);
export type ReviewQuality = z.infer<typeof ReviewQualitySchema>;

export const CreateReviewRequestSchema = z
  .object({
    surahNumber: z.number().int().min(1).max(114),
    ayahFrom: z.number().int().min(1),
    ayahTo: z.number().int().min(1),
    quality: ReviewQualitySchema,
    loggedAt: z.coerce.date().optional(),
  })
  .refine((v) => v.ayahTo >= v.ayahFrom, { message: 'ayahTo must be >= ayahFrom' });
export type CreateReviewRequest = z.infer<typeof CreateReviewRequestSchema>;

export const ReviewDtoSchema = z.object({
  id: z.string().uuid(),
  studentId: z.string().uuid(),
  surahNumber: z.number().int(),
  ayahFrom: z.number().int(),
  ayahTo: z.number().int(),
  quality: ReviewQualitySchema,
  loggedAt: z.string().datetime(),
});
export type ReviewDto = z.infer<typeof ReviewDtoSchema>;

export const ReviewListResponseSchema = z.object({ items: z.array(ReviewDtoSchema) });
export type ReviewListResponse = z.infer<typeof ReviewListResponseSchema>;

export const IDEMPOTENCY_KEY_HEADER = 'Idempotency-Key';
