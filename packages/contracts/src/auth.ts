import { z } from 'zod';

export const RoleSchema = z.enum(['STUDENT', 'TEACHER', 'ADMIN']).meta({ id: 'Role' });
export type Role = z.infer<typeof RoleSchema>;

export const RegisterRequestSchema = z
  .object({
    name: z.string().min(2).max(100),
    email: z.string().email(),
    password: z.string().min(8).max(72),
    role: z.enum(['STUDENT', 'TEACHER']).default('STUDENT'),
  })
  .meta({ id: 'RegisterRequest' });
export type RegisterRequest = z.infer<typeof RegisterRequestSchema>;

export const LoginRequestSchema = z
  .object({ email: z.string().email(), password: z.string().min(1) })
  .meta({ id: 'LoginRequest' });
export type LoginRequest = z.infer<typeof LoginRequestSchema>;

export const RefreshRequestSchema = z
  .object({ refreshToken: z.string().min(1) })
  .meta({ id: 'RefreshRequest' });
export type RefreshRequest = z.infer<typeof RefreshRequestSchema>;

export const AuthUserSchema = z
  .object({
    id: z.string().uuid(),
    name: z.string(),
    email: z.string().email(),
    role: RoleSchema,
  })
  .meta({ id: 'AuthUser' });
export type AuthUser = z.infer<typeof AuthUserSchema>;

export const AuthResponseSchema = z
  .object({
    user: AuthUserSchema,
    accessToken: z.string(),
    refreshToken: z.string(),
  })
  .meta({ id: 'AuthResponse' });
export type AuthResponse = z.infer<typeof AuthResponseSchema>;
