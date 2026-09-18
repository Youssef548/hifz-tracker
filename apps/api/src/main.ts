import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from './app.module';
import { ErrorEnvelopeFilter } from './filters/error-envelope.filter';
import { validateEnv } from './config/env';

async function bootstrap() {
  const env = validateEnv();
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ZodValidationPipe());
  app.useGlobalFilters(new ErrorEnvelopeFilter());
  app.enableCors({ origin: process.env.WEB_URL?.split(',') ?? true, credentials: true });
  await app.listen(env.PORT);
}
void bootstrap();
