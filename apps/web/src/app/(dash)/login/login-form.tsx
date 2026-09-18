'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ApiError, createApiClient } from '@hifz/api-sdk';
import { LoginRequestSchema, type LoginRequest } from '@hifz/contracts';
import { Button } from '@hifz/ui';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';

export function LoginForm() {
  const router = useRouter();
  const [banner, setBanner] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginRequest>({ resolver: zodResolver(LoginRequestSchema) });

  const onSubmit = async (values: LoginRequest) => {
    setBanner(null);
    try {
      await createApiClient({ baseUrl: API_URL }).auth.login(values);
      const res = await fetch('/api/auth/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(values),
      });
      if (!res.ok) throw new Error('Could not establish a session');
      const next = new URLSearchParams(window.location.search).get('next');
      router.push(next ?? '/dashboard');
    } catch (error) {
      setBanner(
        error instanceof ApiError && error.code === 'INVALID_CREDENTIALS'
          ? 'Invalid email or password'
          : 'Sign in failed. Please try again.',
      );
    }
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      noValidate
      className="flex w-full max-w-sm flex-col gap-4"
    >
      {banner ? (
        <p role="alert" className="rounded-brand bg-red-50 px-3 py-2 text-sm text-red-700">
          {banner}
        </p>
      ) : null}

      <div className="flex flex-col gap-1">
        <label htmlFor="email" className="text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          className="rounded-brand border border-gray-300 px-3 py-2"
          {...register('email')}
        />
        {errors.email ? <p className="text-sm text-red-600">{errors.email.message}</p> : null}
      </div>

      <div className="flex flex-col gap-1">
        <label htmlFor="password" className="text-sm font-medium">
          Password
        </label>
        <input
          id="password"
          type="password"
          autoComplete="current-password"
          className="rounded-brand border border-gray-300 px-3 py-2"
          {...register('password')}
        />
        {errors.password ? <p className="text-sm text-red-600">{errors.password.message}</p> : null}
      </div>

      <Button type="submit" disabled={isSubmitting}>
        Sign in
      </Button>
    </form>
  );
}
