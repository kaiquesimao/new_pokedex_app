export const DIFFICULTY_BANDS = [
  { id: 'easy', minId: 1, maxId: 151 },
  { id: 'medium', minId: 152, maxId: 386 },
  { id: 'hard', minId: 387, maxId: 1025 },
] as const;

export type Difficulty = (typeof DIFFICULTY_BANDS)[number]['id'];

export interface ValidatedCatalogEntry {
  id: number;
  slug: string;
  name: string;
  label: string;
  spriteUrl: string;
  difficulty: Difficulty;
}

export function difficultyForId(id: number): Difficulty {
  const band = DIFFICULTY_BANDS.find((candidate) => id >= candidate.minId && id <= candidate.maxId);
  if (!band) throw new Error(`Pokemon ID is outside the supported catalog: ${id}`);
  return band.id;
}

export function validateCatalog(value: unknown): ValidatedCatalogEntry[] {
  if (!Array.isArray(value) || value.length !== 1025) {
    throw new Error(`Runtime catalog must contain 1025 entries, got ${Array.isArray(value) ? value.length : 0}`);
  }

  return value.map((candidate, index) => {
    if (!isEntry(candidate) || candidate.id !== index + 1
      || candidate.slug.trim().length === 0 || candidate.name.trim().length === 0
      || candidate.label.trim().length === 0 || !isHttpsUrl(candidate.spriteUrl)
      || candidate.difficulty !== difficultyForId(candidate.id)) {
      throw new Error(`Catalog entry ${index + 1} is invalid`);
    }
    return candidate;
  });
}

function isEntry(value: unknown): value is ValidatedCatalogEntry {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) return false;
  const entry = value as Record<string, unknown>;
  return Number.isSafeInteger(entry.id) && typeof entry.slug === 'string'
    && typeof entry.name === 'string' && typeof entry.label === 'string'
    && typeof entry.spriteUrl === 'string'
    && (entry.difficulty === 'easy' || entry.difficulty === 'medium' || entry.difficulty === 'hard');
}

function isHttpsUrl(value: string): boolean {
  try {
    return new URL(value).protocol === 'https:';
  } catch {
    return false;
  }
}
