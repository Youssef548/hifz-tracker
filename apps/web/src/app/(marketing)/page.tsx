import Link from 'next/link';
import { Button } from '@hifz/ui';

const features = [
  {
    title: 'Student logging',
    body: 'Students record surah, ayah range and review quality from the mobile app.',
  },
  {
    title: 'Teacher dashboard',
    body: 'Teachers see their students’ recent reviews and progress at a glance.',
  },
  {
    title: 'Offline queue',
    body: 'Reviews logged without connectivity are queued and synced automatically.',
  },
];

export default function MarketingPage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-5xl flex-col px-6 py-16">
      <section className="flex flex-col items-start gap-6">
        <h1 className="text-4xl font-semibold tracking-tight">Hifz Tracker</h1>
        <p className="max-w-2xl text-lg text-gray-600">
          A Quran memorization tracker for students and teachers. Students log recitations from
          the Arabic-first mobile app; teachers follow a live roster on the web dashboard.
        </p>
        <Link href="/login">
          <Button>Sign in</Button>
        </Link>
      </section>

      <section className="mt-16 grid gap-6 sm:grid-cols-3">
        {features.map((feature) => (
          <article key={feature.title} className="rounded-brand border border-gray-200 p-6">
            <h2 className="text-base font-medium">{feature.title}</h2>
            <p className="mt-2 text-sm text-gray-600">{feature.body}</p>
          </article>
        ))}
      </section>
    </main>
  );
}
