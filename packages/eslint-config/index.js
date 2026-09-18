import boundaries from 'eslint-plugin-boundaries';
import importPlugin from 'eslint-plugin-import';

export function defineConfig({ type }) {
  const isApp = type.startsWith('app-');
  const elements = [
    { type: 'app', pattern: 'apps/*' },
    // `packageName` capture lets rules distinguish ordinary packages from the
    // shared tooling packages (@hifz/config, @hifz/eslint-config), which are
    // build/lint-time only and must never be imported by other packages.
    { type: 'package', pattern: 'packages/*', capture: ['packageName'] },
    { type: 'dart', pattern: 'dart-packages/*' },
  ];
  const rules = [];
  rules.push({
    files: ['**/*.{ts,tsx}'],
    plugins: { boundaries, import: importPlugin },
    settings: {
      'boundaries/include': ['apps/**', 'packages/**'],
      'boundaries/elements': elements,
    },
    rules: {
      'boundaries/element-types': ['error', { default: 'disallow', rules: [
        // Apps may import packages (never other apps).
        { from: 'app', allow: ['package'] },
        // Packages may import other packages, except the shared tooling ones.
        { from: 'package', allow: [['package', { packageName: '!(config|eslint-config)' }]] },
      ]}],
      'import/no-extraneous-dependencies': 'error',
    },
  });
  if (isApp) {
    rules.push({
      files: ['apps/*/src/**/*.{ts,tsx}'],
      rules: { 'boundaries/no-unknown': 'error' },
    });
  }
  return rules;
}
