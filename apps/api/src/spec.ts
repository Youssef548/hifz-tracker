import 'dotenv/config';
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { cleanupOpenApiDoc } from 'nestjs-zod';
import { AppModule } from './app.module';
import { validateEnv } from './config/env';

async function main() {
  validateEnv();
  const app = await NestFactory.create(AppModule, { logger: false });
  app.setGlobalPrefix('api/v1');
  const config = new DocumentBuilder()
    .setTitle('Hifz Tracker API')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = cleanupOpenApiDoc(SwaggerModule.createDocument(app, config));
  const out = resolve(__dirname, '../../../generated/openapi.json');
  mkdirSync(resolve(__dirname, '../../../generated'), { recursive: true });
  writeFileSync(out, JSON.stringify(document, null, 2));
  await app.close();
  console.log(`wrote ${out}`);
}
void main();
