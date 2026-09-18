import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Headers,
  Post,
  Query,
  Request,
  Res,
  UseGuards,
} from '@nestjs/common';
import { ApiOkResponse } from '@nestjs/swagger';
import { createZodDto, ZodResponse } from 'nestjs-zod';
import type { Response } from 'express';
import {
  CreateReviewRequestSchema,
  IDEMPOTENCY_KEY_HEADER,
  ReviewDtoSchema,
  ReviewListResponseSchema,
} from '@hifz/contracts';
import { JwtAuthGuard } from '../auth/jwt.strategy';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ReviewsService } from './reviews.service';

class CreateReviewDto extends createZodDto(CreateReviewRequestSchema) {}
class ReviewDtoClass extends createZodDto(ReviewDtoSchema) {}
class ReviewListResponseDto extends createZodDto(ReviewListResponseSchema) {}

@Controller('reviews')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  @Post()
  @Roles('STUDENT')
  @ZodResponse({ status: HttpStatus.CREATED, type: ReviewDtoClass })
  @ApiOkResponse({ type: ReviewDtoClass, description: 'Idempotent replay of an existing review' })
  async create(
    @Request() req: { user: { id: string; role: string } },
    @Headers(IDEMPOTENCY_KEY_HEADER) idempotencyKey: string | undefined,
    @Body() body: CreateReviewDto,
    @Res({ passthrough: true }) res: Response,
  ) {
    if (!idempotencyKey) {
      throw new BadRequestException(`${IDEMPOTENCY_KEY_HEADER} header is required`);
    }
    const { review, replayed } = await this.reviews.create(req.user.id, idempotencyKey, body);
    res.status(replayed ? 200 : 201);
    return review;
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ZodResponse({ status: HttpStatus.OK, type: ReviewListResponseDto })
  list(
    @Request() req: { user: { id: string; role: string } },
    @Query('studentId') studentId?: string,
  ) {
    return this.reviews.list(req.user, studentId);
  }
}
