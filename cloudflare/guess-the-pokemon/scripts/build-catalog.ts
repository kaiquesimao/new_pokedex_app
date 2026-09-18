import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const API_URL = 'https://pokeapi.co/api/v2/pokemon?limit=1025&offset=0';
const OUTPUT_PATH = resolve('catalog/catalog-v1.json');
const EXPECTED_COUNT = 1025;

interface ResourceList {
  count: number;
  results: Array<{ name: string; url: string }>;
}

interface CatalogEntry {
  id: number;
  slug: string;
  name: string;
  label: string;
  spriteUrl: string;
  difficulty: 'easy' | 'medium' | 'hard';
}

const response = await fetch(API_URL, {
  headers: { accept: 'application/json' },
});
if (!response.ok) {
  throw new Error(`PokeAPI request failed (${response.status})`);
}

const resourceList = (await response.json()) as ResourceList;
const entries = resourceList.results.map(toCatalogEntry);
entries.sort((left, right) => left.id - right.id);
assertCatalog(entries, resourceList);

await mkdir(resolve('catalog'), { recursive: true });
await writeFile(
  OUTPUT_PATH,
  `${JSON.stringify({
    version: 'v1',
    source: API_URL,
    generatedAt: new Date().toISOString(),
    entries,
  }, null, 2)}\n`,
);
console.log(`Wrote ${entries.length} catalog entries to ${OUTPUT_PATH}`);

function toCatalogEntry(resource: ResourceList['results'][number]): CatalogEntry {
  const id = resourceId(resource.url);
  return {
    id,
    slug: resource.name,
    name: resource.name,
    label: toLabel(resource.name),
    spriteUrl: `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png`,
    difficulty: difficultyForId(id),
  };
}

function assertCatalog(entries: CatalogEntry[], resourceList: ResourceList): void {
  if (resourceList.count < EXPECTED_COUNT || entries.length !== EXPECTED_COUNT) {
    throw new Error(
      `Expected exactly ${EXPECTED_COUNT} base Pokemon, got ${entries.length}`,
    );
  }

  const ids = entries.map((entry) => entry.id);
  const expectedIds = Array.from({ length: EXPECTED_COUNT }, (_, index) => index + 1);
  if (JSON.stringify(ids) !== JSON.stringify(expectedIds)) {
    throw new Error('Catalog IDs must contain every base Pokemon from 1 through 1025');
  }
}

function resourceId(url: string): number {
  const match = url.match(/\/([0-9]+)\/?$/);
  if (!match) {
    throw new Error(`Unexpected PokeAPI resource URL: ${url}`);
  }
  return Number(match[1]);
}

function difficultyForId(id: number): CatalogEntry['difficulty'] {
  if (id <= 151) return 'easy';
  if (id <= 386) return 'medium';
  return 'hard';
}

function toLabel(name: string): string {
  return name.replace(/(^|-)(\w)/g, (_, separator: string, character: string) =>
    `${separator}${character.toUpperCase()}`,
  );
}
