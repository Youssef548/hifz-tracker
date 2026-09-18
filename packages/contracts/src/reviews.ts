import { z } from 'zod';

export const ReviewQualitySchema = z
  .enum(['GOOD', 'FAIR', 'POOR'])
  .meta({ id: 'ReviewQuality' });
export type ReviewQuality = z.infer<typeof ReviewQualitySchema>;

export const CreateReviewRequestSchema = z
  .object({
    surahNumber: z.number().int().min(1).max(114),
    ayahFrom: z.number().int().min(1),
    ayahTo: z.number().int().min(1),
    quality: ReviewQualitySchema,
    // ISO string rather than z.coerce.date(): zod cannot express Date in JSON
    // Schema, which breaks OpenAPI generation (and therefore the Dart client).
    loggedAt: z.iso.datetime().optional(),
  })
  .meta({ id: 'CreateReviewRequest' })
  .refine((v) => v.ayahTo >= v.ayahFrom, { message: 'ayahTo must be >= ayahFrom' });
export type CreateReviewRequest = z.infer<typeof CreateReviewRequestSchema>;

export const ReviewDtoSchema = z
  .object({
    id: z.string().uuid(),
    studentId: z.string().uuid(),
    surahNumber: z.number().int(),
    ayahFrom: z.number().int(),
    ayahTo: z.number().int(),
    quality: ReviewQualitySchema,
    loggedAt: z.string().datetime(),
  })
  .meta({ id: 'ReviewDto' });
export type ReviewDto = z.infer<typeof ReviewDtoSchema>;

export const ReviewListResponseSchema = z
  .object({ items: z.array(ReviewDtoSchema) })
  .meta({ id: 'ReviewListResponse' });
export type ReviewListResponse = z.infer<typeof ReviewListResponseSchema>;

export const IDEMPOTENCY_KEY_HEADER = 'Idempotency-Key';
