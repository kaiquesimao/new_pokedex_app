/**
 * Seeds Firestore legal_documents using Firebase CLI credentials.
 *
 * Prerequisites:
 *   1. firebase login
 *   2. npm install (in scripts/)
 *   3. firebase deploy --only firestore:rules
 *
 * Run from project root:
 *   node scripts/seed_legal_documents.cjs
 */

const { readFileSync } = require('node:fs');
const { dirname, join } = require('node:path');
const {
  getGlobalDefaultAccount,
  getAccessToken,
} = require('firebase-tools/lib/auth');
const scopes = require('firebase-tools/lib/scopes');

const projectId = 'pokedex-app-c5e90';
const bundledVersion = '2026-07-06';
const collection = 'legal_documents';

const authScopes = [
  scopes.CLOUD_PLATFORM,
  scopes.EMAIL,
  scopes.OPENID,
];

const seeds = [
  { docId: 'terms_pt_BR', slug: 'terms', locale: 'pt_BR', asset: 'terms_pt_br.md' },
  { docId: 'terms_en', slug: 'terms', locale: 'en', asset: 'terms_en.md' },
  { docId: 'privacy_pt_BR', slug: 'privacy', locale: 'pt_BR', asset: 'privacy_pt_br.md' },
  { docId: 'privacy_en', slug: 'privacy', locale: 'en', asset: 'privacy_en.md' },
  {
    docId: 'account_deletion_pt_BR',
    slug: 'account_deletion',
    locale: 'pt_BR',
    asset: 'account_deletion_pt_br.md',
  },
  {
    docId: 'account_deletion_en',
    slug: 'account_deletion',
    locale: 'en',
    asset: 'account_deletion_en.md',
  },
];

const rootDir = join(dirname(__filename), '..');
const assetsDir = join(rootDir, 'assets', 'legal');

function firestoreFields({ slug, locale, markdown }) {
  return {
    slug: { stringValue: slug },
    locale: { stringValue: locale },
    markdown: { stringValue: markdown },
    version: { stringValue: bundledVersion },
    updatedAt: { timestampValue: new Date().toISOString() },
    published: { booleanValue: true },
  };
}

async function upsertDocument(accessToken, docId, fields) {
  const url =
    `https://firestore.googleapis.com/v1/projects/${projectId}` +
    `/databases/(default)/documents/${collection}/${docId}`;

  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Firestore write failed for ${docId}: ${response.status} ${body}`);
  }
}

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Run `firebase login` first.');
  }

  const tokens = await getAccessToken(
    account.tokens.refresh_token,
    authScopes,
  );
  const accessToken = tokens.access_token;

  for (const seed of seeds) {
    const markdown = readFileSync(join(assetsDir, seed.asset), 'utf8');
    await upsertDocument(
      accessToken,
      seed.docId,
      firestoreFields({
        slug: seed.slug,
        locale: seed.locale,
        markdown,
      }),
    );
    console.log(`Seeded ${collection}/${seed.docId}`);
  }

  console.log('Done.');
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exit(1);
});
