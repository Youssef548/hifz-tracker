import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { randomUUID } from 'node:crypto';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from '../src/app.module';
import { ErrorEnvelopeFilter } from '../src/filters/error-envelope.filter';
import { PrismaService } from '../src/prisma/prisma.service';

describe('reviews (e2e)', () => {
  let app: INestApplication;
  let db: PrismaService;
  let studentToken: string;
  let teacherToken: string;
  let studentId: string;
  const idem = randomUUID();

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ZodValidationPipe()) as unknown as ValidationPipe;
    app.useGlobalFilters(new ErrorEnvelopeFilter());
    await app.init();
    db = app.get(PrismaService);
    const s = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ name: 'Stu Dent', email: `stu-${Date.now()}@t.dev`, password: 'password123' });
    studentToken = s.body.accessToken;
    studentId = s.body.user.id;
    const t = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        name: 'Tea Cher',
        email: `tea-${Date.now()}@t.dev`,
        password: 'password123',
        role: 'TEACHER',
      });
    teacherToken = t.body.accessToken;
  });
  afterAll(async () => {
    await db.refreshToken.deleteMany({});
    await db.reviewLog.deleteMany({});
    await db.user.deleteMany({});
    await app.close();
  });

  const payload = { surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' as const };

  it('requires an idempotency key', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`)
      .send(payload)
      .expect(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('creates a review (201) and replays idempotently (200, same id)', async () => {
    const first = await request(app.getHttpServer())
      .post('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`)
      .set('Idempotency-Key', idem)
      .send(payload)
      .expect(201);
    const second = await request(app.getHttpServer())
      .post('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`)
      .set('Idempotency-Key', idem)
      .send(payload)
      .expect(200);
    expect(second.body.id).toBe(first.body.id);
    expect(first.body).toMatchObject({ surahNumber: 1, quality: 'GOOD', studentId });
  });

  it('students list only their own reviews', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200);
    expect(res.body.items.every((r: { studentId: string }) => r.studentId === studentId)).toBe(
      true,
    );
  });

  it('teachers must pass studentId', async () => {
    await request(app.getHttpServer())
      .get('/api/v1/reviews')
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(400);
    const res = await request(app.getHttpServer())
      .get(`/api/v1/reviews?studentId=${studentId}`)
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(200);
    expect(res.body.items.length).toBeGreaterThanOrEqual(1);
  });

  it('students cannot use teacher-only listing of others', async () => {
    await request(app.getHttpServer())
      .get(`/api/v1/reviews?studentId=${randomUUID()}`)
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200)
      .then((res) => expect(res.body.items).toHaveLength(1));
  });
});
