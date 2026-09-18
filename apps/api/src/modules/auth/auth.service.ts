import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import type { RegisterRequest } from '@hifz/contracts';
import { InvalidRefreshTokenError, TokenService } from './token.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly db: PrismaService,
    private readonly tokens: TokenService,
  ) {}

  async register(body: RegisterRequest) {
    const existing = await this.db.user.findUnique({ where: { email: body.email } });
    if (existing) throw new ConflictException('Email already registered');
    const user = await this.db.user.create({
      data: {
        email: body.email,
        name: body.name,
        role: body.role,
        passwordHash: await bcrypt.hash(body.password, 12),
      },
    });
    return this.tokens.issue(user);
  }

  async login(email: string, password: string) {
    const user = await this.db.user.findUnique({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.tokens.issue(user);
  }

  async refresh(refreshToken: string) {
    try {
      return await this.tokens.rotate(refreshToken);
    } catch (e) {
      if (e instanceof InvalidRefreshTokenError)
        throw new UnauthorizedException('Invalid refresh token');
      throw e;
    }
  }
}
