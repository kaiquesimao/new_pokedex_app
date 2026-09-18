import type { applyD1Migrations } from 'cloudflare:test';

declare namespace Cloudflare {
  interface Env {
    DB: D1Database;
    FIREBASE_PROJECT_ID: string;
    CURSOR_ENCRYPTION_KEY: string;
    GAME_API_BASE_URL: string;
    CORS_ALLOWED_ORIGINS: string;
    TEST_MIGRATIONS: Parameters<typeof applyD1Migrations>[1];
  }
}

interface Env extends Cloudflare.Env {}
