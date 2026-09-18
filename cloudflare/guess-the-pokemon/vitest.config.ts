import { cloudflareTest } from '@cloudflare/vitest-plugin';
import path from 'node:path';
import { defineConfig } from 'vitest/config';

export default defineConfig(async () => ({
  plugins: [
    cloudflareTest({
      miniflare: {
        bindings: {
          TEST_MIGRATIONS: await import('@cloudflare/vitest-plugin').then(({ readD1Migrations }) =>
            readD1Migrations(path.join(import.meta.dirname, 'migrations'))),
        },
      },
      wrangler: { configPath: './wrangler.toml' },
    }),
  ],
}));
