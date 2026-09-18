import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { createHash, randomBytes } from 'node:crypto';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthResponse, AuthUser } from '@hifz/contracts';

export interface JwtPayload {
  sub: string;
  email: string;
  name: string;
  role: string;
}

@Injectable()
export class TokenService {
  constructor(
    private readonly jwt: JwtService,
    private readonly db: PrismaService,
  ) {}

  async issue(user: {
    id: string;
    email: string;
    name: string;
    role: string;
  }): Promise<AuthResponse> {
    const accessToken = await this.jwt.signAsync<JwtPayload>({
      sub: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    });
    const refreshToken = randomBytes(48).toString('hex');
    const ttlDays = Number(process.env.REFRESH_TOKEN_TTL_DAYS ?? 30);
    await this.db.refreshToken.create({
      data: {
        tokenHash: this.hash(refreshToken),
        userId: user.id,
        expiresAt: new Date(Date.now() + ttlDays * 86_400_000),
      },
    });
    const authUser: AuthUser = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role as AuthUser['role'],
    };
    return { user: authUser, accessToken, refreshToken };
  }

  async rotate(refreshToken: string): Promise<AuthResponse> {
    const record = await this.db.refreshToken.findUnique({
      where: { tokenHash: this.hash(refreshToken) },
      include: { user: true },
    });
    if (!record || record.expiresAt < new Date()) throw new InvalidRefreshTokenError();
    await this.db.refreshToken.delete({ where: { id: record.id } });
    return this.issue(record.user);
  }

  private hash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}

export class InvalidRefreshTokenError extends Error {}
