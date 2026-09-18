import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { createZodDto, ZodResponse } from 'nestjs-zod';
import {
  AuthResponseSchema,
  AuthUserSchema,
  LoginRequestSchema,
  RefreshRequestSchema,
  RegisterRequestSchema,
  type AuthUser,
} from '@hifz/contracts';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.strategy';
import { RolesGuard } from './roles.guard';

class RegisterDto extends createZodDto(RegisterRequestSchema) {}
class LoginDto extends createZodDto(LoginRequestSchema) {}
class RefreshDto extends createZodDto(RefreshRequestSchema) {}
class AuthUserDto extends createZodDto(AuthUserSchema) {}
class AuthResponseDto extends createZodDto(AuthResponseSchema) {}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @ZodResponse({ status: HttpStatus.CREATED, type: AuthResponseDto })
  register(@Body() body: RegisterDto) {
    return this.auth.register(body);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ZodResponse({ status: HttpStatus.OK, type: AuthResponseDto })
  login(@Body() body: LoginDto) {
    return this.auth.login(body.email, body.password);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ZodResponse({ status: HttpStatus.OK, type: AuthResponseDto })
  refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @ZodResponse({ status: HttpStatus.OK, type: AuthUserDto })
  me(@Request() req: { user: AuthUser }) {
    return req.user;
  }
}
