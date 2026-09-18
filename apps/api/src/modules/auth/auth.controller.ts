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
import { createZodDto } from 'nestjs-zod';
import {
  LoginRequestSchema,
  RefreshRequestSchema,
  RegisterRequestSchema,
} from '@hifz/contracts';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.strategy';
import { RolesGuard } from './roles.guard';

class RegisterDto extends createZodDto(RegisterRequestSchema) {}
class LoginDto extends createZodDto(LoginRequestSchema) {}
class RefreshDto extends createZodDto(RefreshRequestSchema) {}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  register(@Body() body: RegisterDto) {
    return this.auth.register(body);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() body: LoginDto) {
    return this.auth.login(body.email, body.password);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  me(@Request() req: { user: { id: string; email: string; name: string; role: string } }) {
    return req.user;
  }
}
