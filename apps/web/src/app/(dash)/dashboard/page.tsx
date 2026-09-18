import { redirect } from 'next/navigation';
import { ApiError, createApiClient } from '@hifz/api-sdk';
import { surahByNumber } from '@hifz/quran';
import { getSessionTokens } from '@/lib/session';
import { StudentFilter } from './student-filter';

const API_URL = process.env.API_URL ?? 'http://localhost:3001/api/v1';

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: Promise<{ studentId?: string }>;
}) {
  const { accessToken } = await getSessionTokens();
  if (!accessToken) redirect('/login');

  const { studentId } = await searchParams;
  const api = createApiClient({ baseUrl: API_URL, getAccessToken: () => accessToken });

  let reviews: Awaited<ReturnType<typeof api.reviews.list>>['items'] = [];
  let error: string | null = null;
  if (studentId) {
    try {
      reviews = (await api.reviews.list(studentId)).items;
    } catch (caught) {
      if (caught instanceof ApiError && caught.status === 401) redirect('/login');
      error = caught instanceof ApiError ? caught.message : 'Could not load reviews';
    }
  }

  return (
    <main className="mx-auto max-w-4xl px-6 py-10">
      <h1 className="text-2xl font-semibold">Dashboard</h1>
      <p className="mt-1 text-sm text-gray-600">Recent reviews for a student.</p>

      <div className="mt-6">
        <StudentFilter initialValue={studentId ?? ''} />
      </div>

      {error ? (
        <p role="alert" className="mt-6 rounded-brand bg-red-50 px-3 py-2 text-sm text-red-700">
          {error}
        </p>
      ) : null}

      {!studentId ? (
        <p className="mt-8 text-sm text-gray-600">
          Enter a student id to see their reviews.
          {/* The skeleton has no student roster endpoint yet. */}
        </p>
      ) : (
        <table className="mt-8 w-full border-collapse text-sm">
          <thead>
            <tr className="border-b border-gray-200 text-left">
              <th className="py-2 font-medium">Student</th>
              <th className="py-2 font-medium">Surah</th>
              <th className="py-2 font-medium">Ayahs</th>
              <th className="py-2 font-medium">Quality</th>
              <th className="py-2 font-medium">Logged at</th>
            </tr>
          </thead>
          <tbody>
            {reviews.map((review) => {
              const surah = surahByNumber(review.surahNumber);
              return (
                <tr key={review.id} className="border-b border-gray-100">
                  <td className="py-2 font-mono text-xs">{review.studentId}</td>
                  <td className="py-2">
                    {surah ? `${surah.nameAr} (${review.surahNumber})` : review.surahNumber}
                  </td>
                  <td className="py-2">
                    {review.ayahFrom}–{review.ayahTo}
                  </td>
                  <td className="py-2">{review.quality}</td>
                  <td className="py-2">{new Date(review.loggedAt).toLocaleString()}</td>
                </tr>
              );
            })}
            {reviews.length === 0 ? (
              <tr>
                <td colSpan={5} className="py-4 text-gray-500">
                  No reviews yet.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      )}
    </main>
  );
}
