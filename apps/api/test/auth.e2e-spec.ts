import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from '../src/app.module';
import { ErrorEnvelopeFilter } from '../src/filters/error-envelope.filter';
import { PrismaService } from '../src/prisma/prisma.service';

describe('auth (e2e)', () => {
  let app: INestApplication;
  let db: PrismaService;
  const email = `skeleton-${Date.now()}@test.dev`;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ZodValidationPipe()) as unknown as ValidationPipe;
    app.useGlobalFilters(new ErrorEnvelopeFilter());
    await app.init();
    db = app.get(PrismaService);
  });
  afterAll(async () => {
    await db.refreshToken.deleteMany({});
    await db.user.deleteMany({});
    await app.close();
  });

  it('registers a student', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ name: 'Test Student', email, password: 'password123' })
      .expect(201);
    expect(res.body.user).toMatchObject({ email, role: 'STUDENT' });
    expect(res.body.accessToken).toBeTruthy();
    expect(res.body.refreshToken).toBeTruthy();
  });

  it('rejects duplicate email with CONFLICT envelope', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ name: 'Test Student', email, password: 'password123' })
      .expect(409);
    expect(res.body.error.code).toBe('CONFLICT');
  });

  it('logs in and returns tokens', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'password123' })
      .expect(200);
    expect(res.body.user.email).toBe(email);
  });

  it('rejects wrong password with INVALID_CREDENTIALS', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'wrong-password' })
      .expect(401);
    expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('me returns the authed user', async () => {
    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'password123' });
    const res = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);
    expect(res.body.email).toBe(email);
  });

  it('refresh rotates the refresh token', async () => {
    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'password123' });
    const first = login.body.refreshToken as string;
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(200);
    expect(res.body.refreshToken).not.toBe(first);
    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(401);
  });
});
