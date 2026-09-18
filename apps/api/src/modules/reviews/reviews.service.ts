import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import type { CreateReviewRequest, ReviewDto } from '@hifz/contracts';

@Injectable()
export class ReviewsService {
  constructor(private readonly db: PrismaService) {}

  async create(
    studentId: string,
    idempotencyKey: string,
    body: CreateReviewRequest,
  ): Promise<{ review: ReviewDto; replayed: boolean }> {
    const existing = await this.db.reviewLog.findUnique({ where: { idempotencyKey } });
    if (existing) return { review: this.toDto(existing), replayed: true };
    const created = await this.db.reviewLog.create({
      data: {
        studentId,
        idempotencyKey,
        surahNumber: body.surahNumber,
        ayahFrom: body.ayahFrom,
        ayahTo: body.ayahTo,
        quality: body.quality,
        loggedAt: body.loggedAt ?? new Date(),
      },
    });
    return { review: this.toDto(created), replayed: false };
  }

  async list(requester: { id: string; role: string }, studentId?: string) {
    let target = studentId;
    if (requester.role === 'STUDENT') target = requester.id;
    else if (!target) throw new BadRequestException('studentId is required for teachers');
    const rows = await this.db.reviewLog.findMany({
      where: { studentId: target },
      orderBy: { loggedAt: 'desc' },
      take: 100,
    });
    return { items: rows.map((r) => this.toDto(r)) };
  }

  private toDto(r: {
    id: string;
    studentId: string;
    surahNumber: number;
    ayahFrom: number;
    ayahTo: number;
    quality: string;
    loggedAt: Date;
  }): ReviewDto {
    return {
      id: r.id,
      studentId: r.studentId,
      surahNumber: r.surahNumber,
      ayahFrom: r.ayahFrom,
      ayahTo: r.ayahTo,
      quality: r.quality as ReviewDto['quality'],
      loggedAt: r.loggedAt.toISOString(),
    };
  }
}
