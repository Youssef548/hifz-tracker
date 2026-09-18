import { NextResponse, type NextRequest } from 'next/server';

export function middleware(req: NextRequest) {
  const hasSession = req.cookies.has('at') || req.cookies.has('rt');
  if (!hasSession) {
    const url = req.nextUrl.clone();
    url.pathname = '/login';
    url.searchParams.set('next', req.nextUrl.pathname);
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

export const config = { matcher: ['/dashboard/:path*'] };
