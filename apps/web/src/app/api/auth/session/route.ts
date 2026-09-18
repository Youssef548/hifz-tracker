import { NextResponse } from 'next/server';
import { createApiClient } from '@hifz/api-sdk';
import { ErrorCodes, LoginRequestSchema, RefreshRequestSchema } from '@hifz/contracts';

const API_URL = process.env.API_URL ?? 'http://localhost:3001/api/v1';
const ACCESS_TTL = Number(process.env.JWT_ACCESS_TTL ?? 900);

function cookieOptions(maxAge: number) {
  return {
    httpOnly: true,
    sameSite: 'lax' as const,
    secure: process.env.NODE_ENV === 'production',
    maxAge,
  };
}

function applySession(
  res: NextResponse,
  tokens: { accessToken: string; refreshToken: string },
): NextResponse {
  res.cookies.set('at', tokens.accessToken, cookieOptions(ACCESS_TTL));
  res.cookies.set('rt', tokens.refreshToken, {
    ...cookieOptions(30 * 86_400),
    path: '/api/auth/session',
  });
  return res;
}

export async function POST(req: Request) {
  const parsed = LoginRequestSchema.safeParse(await req.json().catch(() => null));
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: ErrorCodes.VALIDATION_ERROR, message: 'Invalid payload' } },
      { status: 400 },
    );
  }
  try {
    const auth = await createApiClient({ baseUrl: API_URL }).auth.login(parsed.data);
    return applySession(new NextResponse(null, { status: 204 }), auth);
  } catch {
    return NextResponse.json(
      { error: { code: ErrorCodes.INVALID_CREDENTIALS, message: 'Invalid email or password' } },
      { status: 401 },
    );
  }
}

export async function PUT(req: Request) {
  const cookieHeader = req.headers.get('cookie') ?? '';
  const rt = cookieHeader
    .split(';')
    .map((part) => part.trim())
    .find((part) => part.startsWith('rt='))
    ?.slice(3);
  const parsed = RefreshRequestSchema.safeParse({ refreshToken: rt });
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: ErrorCodes.UNAUTHORIZED, message: 'No refresh token' } },
      { status: 401 },
    );
  }
  try {
    const auth = await createApiClient({ baseUrl: API_URL }).auth.refresh(parsed.data.refreshToken);
    return applySession(new NextResponse(null, { status: 204 }), auth);
  } catch {
    return NextResponse.json(
      { error: { code: ErrorCodes.UNAUTHORIZED, message: 'Invalid refresh token' } },
      { status: 401 },
    );
  }
}

export async function DELETE() {
  const res = new NextResponse(null, { status: 204 });
  res.cookies.set('at', '', { ...cookieOptions(0) });
  res.cookies.set('rt', '', { ...cookieOptions(0), path: '/api/auth/session' });
  return res;
}
