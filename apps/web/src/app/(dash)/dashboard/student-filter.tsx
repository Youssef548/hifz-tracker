'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { Button } from '@hifz/ui';

export function StudentFilter({ initialValue = '' }: { initialValue?: string }) {
  const router = useRouter();
  const [value, setValue] = useState(initialValue);

  return (
    <form
      className="flex items-end gap-3"
      onSubmit={(event) => {
        event.preventDefault();
        const trimmed = value.trim();
        router.push(trimmed ? `/dashboard?studentId=${encodeURIComponent(trimmed)}` : '/dashboard');
      }}
    >
      <div className="flex flex-col gap-1">
        <label htmlFor="studentId" className="text-sm font-medium">
          Student ID
        </label>
        <input
          id="studentId"
          value={value}
          onChange={(event) => setValue(event.target.value)}
          className="rounded-brand border border-gray-300 px-3 py-2 font-mono text-sm"
          placeholder="student uuid"
        />
      </div>
      <Button type="submit">Show reviews</Button>
    </form>
  );
}
