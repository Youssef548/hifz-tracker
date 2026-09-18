import { createZodDto } from 'nestjs-zod';
import { ErrorEnvelopeSchema } from '@hifz/contracts';

/**
 * Documents the error envelope the global `ErrorEnvelopeFilter` emits, so it
 * lands in the OpenAPI document and every generated client gets the shape.
 */
export class ErrorEnvelopeDto extends createZodDto(ErrorEnvelopeSchema) {}
