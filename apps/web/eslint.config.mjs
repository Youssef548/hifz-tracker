import { dirname } from 'path';
import { fileURLToPath } from 'url';
import { FlatCompat } from '@eslint/eslintrc';
import { defineConfig } from '@hifz/eslint-config';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({ baseDirectory: __dirname });

const eslintConfig = [
  ...compat.extends('next/core-web-vitals', 'next/typescript'),
  ...defineConfig({ type: 'app-web', importRules: false }),
  {
    files: ['**/*.{ts,tsx}'],
    rules: { 'import/no-extraneous-dependencies': 'error' },
  },
  {
    ignores: [
      'node_modules/**',
      '.next/**',
      'out/**',
      'build/**',
      'next-env.d.ts',
      // Serwist build output — minified, regenerated on every build.
      'public/sw.js',
    ],
  },
];

export default eslintConfig;
