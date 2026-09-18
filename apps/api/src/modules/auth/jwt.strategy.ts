import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard, PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { JwtPayload } from './token.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_ACCESS_SECRET ?? '',
    });
  }

  validate(payload: JwtPayload) {
    if (!payload?.sub) throw new UnauthorizedException();
    return { id: payload.sub, email: payload.email, name: payload.name, role: payload.role };
  }
}

export class JwtAuthGuard extends AuthGuard('jwt') {}
