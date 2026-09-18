/**
 * Compile-time proof that the API's generated contract still lines up with the
 * zod schemas `@hifz/contracts` declares. Response drift would otherwise only
 * surface at runtime; here it fails `tsc`.
 *
 * Types only — nothing is re-exported from `src/index.ts`, so the public surface
 * of `@hifz/api-sdk` is unchanged.
 */
import type {
  AuthResponse,
  AuthUser,
  ReviewDto,
  ReviewListResponse,
} from '@hifz/contracts';
import type { components } from './generated/schema';

type Generated = components['schemas'];
type MustExtend<Actual extends Expected, Expected> = Actual;

export type _AuthUser = MustExtend<Generated['AuthUser_Output'], AuthUser>;
export type _AuthResponse = MustExtend<Generated['AuthResponse_Output'], AuthResponse>;
export type _ReviewDto = MustExtend<Generated['ReviewDto_Output'], ReviewDto>;
export type _ReviewList = MustExtend<Generated['ReviewListResponse_Output'], ReviewListResponse>;
