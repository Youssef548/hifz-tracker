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
import { ApiResponse } from '@nestjs/swagger';
import { createZodDto, ZodResponse } from 'nestjs-zod';
import {
  AuthResponseSchema,
  AuthUserSchema,
  LoginRequestSchema,
  RefreshRequestSchema,
  RegisterRequestSchema,
  type AuthUser,
} from '@hifz/contracts';
import { ErrorEnvelopeDto } from '../../filters/error-envelope.dto';
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
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, type: ErrorEnvelopeDto })
  @ApiResponse({ status: HttpStatus.CONFLICT, type: ErrorEnvelopeDto })
  register(@Body() body: RegisterDto) {
    return this.auth.register(body);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ZodResponse({ status: HttpStatus.OK, type: AuthResponseDto })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, type: ErrorEnvelopeDto })
  @ApiResponse({ status: HttpStatus.UNAUTHORIZED, type: ErrorEnvelopeDto })
  login(@Body() body: LoginDto) {
    return this.auth.login(body.email, body.password);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ZodResponse({ status: HttpStatus.OK, type: AuthResponseDto })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, type: ErrorEnvelopeDto })
  @ApiResponse({ status: HttpStatus.UNAUTHORIZED, type: ErrorEnvelopeDto })
  refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @ZodResponse({ status: HttpStatus.OK, type: AuthUserDto })
  @ApiResponse({ status: HttpStatus.UNAUTHORIZED, type: ErrorEnvelopeDto })
  me(@Request() req: { user: AuthUser }) {
    return req.user;
  }
}
