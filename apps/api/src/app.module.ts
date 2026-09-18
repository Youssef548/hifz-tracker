import { Module } from '@nestjs/common';
import { HealthController } from './modules/health/health.controller';
import { AuthModule } from './modules/auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [HealthController],
  providers: [],
})
export class AppModule {}
