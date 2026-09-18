import boundaries from 'eslint-plugin-boundaries';
import importPlugin from 'eslint-plugin-import';

// `importRules: false` omits eslint-plugin-import here, for consumers (e.g. the
// Next app, whose eslint-config-next already registers a plugin named `import`)
// where redefining that plugin key would make ESLint throw. Such a consumer can
// still enable `import/no-extraneous-dependencies` in a rules-only config, since
// the plugin is already registered for the same files by its own preset.
export function defineConfig({ type, importRules = true }) {
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
    plugins: importRules ? { boundaries, import: importPlugin } : { boundaries },
    settings: {
      'boundaries/include': ['apps/**', 'packages/**'],
      'boundaries/elements': elements,
      // Without an import resolver, eslint-module-utils falls back to the node
      // resolver without .ts/.tsx extensions, so extensionless relative
      // imports of TS files come back unresolved and boundaries silently
      // skips element-types checks on them.
      'import/resolver': { node: { extensions: ['.js', '.ts', '.tsx'] } },
    },
    rules: {
      'boundaries/element-types': ['error', { default: 'disallow', rules: [
        // Apps may import packages (never other apps).
        { from: 'app', allow: ['package'] },
        // Packages may import other packages, except the shared tooling ones.
        { from: 'package', allow: [['package', { packageName: '!(config|eslint-config)' }]] },
      ]}],
      ...(importRules ? { 'import/no-extraneous-dependencies': 'error' } : {}),
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
