import { cookies } from 'next/headers';

export const AT_COOKIE = 'at';
export const RT_COOKIE = 'rt';

export async function getSessionTokens(): Promise<{
  accessToken?: string;
  refreshToken?: string;
}> {
  const jar = await cookies();
  return { accessToken: jar.get(AT_COOKIE)?.value, refreshToken: jar.get(RT_COOKIE)?.value };
}
