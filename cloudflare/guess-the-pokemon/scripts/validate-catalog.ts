import { readFile } from 'node:fs/promises';
import { validateCatalog } from '../src/catalog_validation';

const path = 'catalog/catalog-v1.json';
const expectedCount = 1025;
const value = JSON.parse(await readFile(path, 'utf8')) as {
  version?: unknown;
  entries?: Array<Record<string, unknown>>;
};

if (value.version !== 'v1' || !Array.isArray(value.entries) || value.entries.length !== expectedCount) {
  throw new Error(`Catalog must be v1 with exactly ${expectedCount} entries`);
}
validateCatalog(value.entries);

console.log(`Validated ${value.entries.length} catalog entries`);
