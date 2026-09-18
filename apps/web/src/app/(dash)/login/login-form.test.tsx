import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { LoginForm } from './login-form';

const push = vi.fn();
vi.mock('next/navigation', () => ({ useRouter: () => ({ push }) }));

const login = vi.fn();
vi.mock('@hifz/api-sdk', () => ({
  createApiClient: () => ({ auth: { login: (...a: unknown[]) => login(...a) } }),
}));

describe('LoginForm', () => {
  beforeEach(() => {
    login.mockReset();
    push.mockReset();
    vi.unstubAllGlobals();
  });

  it('shows a validation error for an invalid email', async () => {
    render(<LoginForm />);
    await userEvent.type(screen.getByLabelText('Email'), 'not-an-email');
    await userEvent.type(screen.getByLabelText('Password'), 'password123');
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(await screen.findByText(/invalid email/i)).toBeTruthy();
    expect(login).not.toHaveBeenCalled();
  });

  it('submits valid credentials, posts the session, and navigates', async () => {
    login.mockResolvedValue({
      user: { id: 'u1', role: 'TEACHER' },
      accessToken: 'at',
      refreshToken: 'rt',
    });
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(null, { status: 204 })));
    render(<LoginForm />);
    await userEvent.type(screen.getByLabelText('Email'), 'teacher@test.dev');
    await userEvent.type(screen.getByLabelText('Password'), 'password123');
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
    await waitFor(() => expect(push).toHaveBeenCalledWith('/dashboard'));
  });
});
