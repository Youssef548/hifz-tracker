import { describe, expect, it } from 'vitest';
import {
  AuthResponseSchema, ErrorEnvelopeSchema, LoginRequestSchema, RegisterRequestSchema, RoleSchema,
} from '../src/index';

describe('auth contracts', () => {
  it('accepts a valid register payload and defaults role to STUDENT', () => {
    const parsed = RegisterRequestSchema.parse({
      name: 'Ahmad', email: 'a@b.com', password: 'password123',
    });
    expect(parsed.role).toBe('STUDENT');
  });
  it('rejects short passwords and bad emails', () => {
    expect(RegisterRequestSchema.safeParse({ name: 'A', email: 'nope', password: 'short' }).success).toBe(false);
  });
  it('allows only STUDENT or TEACHER self-registration', () => {
    expect(RegisterRequestSchema.safeParse({ name: 'x x', email: 'a@b.com', password: 'password123', role: 'ADMIN' }).success).toBe(false);
    expect(RoleSchema.parse('TEACHER')).toBe('TEACHER');
  });
  it('parses login request', () => {
    expect(LoginRequestSchema.parse({ email: 'a@b.com', password: 'pw' })).toBeTruthy();
  });
  it('parses a full auth response', () => {
    const ok = AuthResponseSchema.safeParse({
      user: { id: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11', name: 'A', email: 'a@b.com', role: 'STUDENT' },
      accessToken: 'aa', refreshToken: 'rr',
    });
    expect(ok.success).toBe(true);
  });
  it('parses the error envelope', () => {
    expect(ErrorEnvelopeSchema.parse({ error: { code: 'X', message: 'm' } })).toBeTruthy();
  });
});
