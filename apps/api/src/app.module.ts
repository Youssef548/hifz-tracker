import { Module } from '@nestjs/common';
import { HealthController } from './modules/health/health.controller';
import { AuthModule } from './modules/auth/auth.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, AuthModule, ReviewsModule],
  controllers: [HealthController],
  providers: [],
})
export class AppModule {}
