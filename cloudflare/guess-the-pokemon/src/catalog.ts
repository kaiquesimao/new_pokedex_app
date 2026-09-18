import catalogAsset from '../catalog/catalog-v1.json';
import {
  DIFFICULTY_BANDS,
  difficultyForId,
  validateCatalog,
  type Difficulty,
} from './catalog_validation';

export { DIFFICULTY_BANDS, difficultyForId, validateCatalog } from './catalog_validation';
export type { Difficulty } from './catalog_validation';

export interface CatalogEntry {
  id: number;
  slug: string;
  name: string;
  label: string;
  spriteUrl: string;
  difficulty: Difficulty;
}

export interface RoundOption extends CatalogEntry {
  isTarget: boolean;
}

export interface RoundSelection {
  difficulty: Difficulty;
  target: CatalogEntry;
  options: RoundOption[];
}

export const CATALOG: CatalogEntry[] = validateCatalog(catalogAsset.entries);

export function chooseRound(
  seed: string,
  round: number,
  requestedDifficulty?: Difficulty,
  catalog: readonly CatalogEntry[] = CATALOG,
): RoundSelection {
  if (!Number.isInteger(round) || round < 0) {
    throw new Error('Round must be a non-negative integer');
  }

  const difficulty = requestedDifficulty ?? difficultyForRound(round);
  const candidates = catalog
    .filter((entry) => entry.difficulty === difficulty)
    .sort((left, right) => left.id - right.id);

  if (candidates.length < 4) {
    throw new Error(`Difficulty band does not contain four catalog entries: ${difficulty}`);
  }

  const random = seededRandom(`${seed}:${round}:${difficulty}`);
  const shuffled = shuffle(candidates, random);
  const selected = shuffled.slice(0, 4);
  const targetIndex = Math.floor(random() * selected.length);
  const target = selected[targetIndex];

  return {
    difficulty,
    target,
    options: shuffle(
      selected.map((entry) => ({ ...entry, isTarget: entry.id === target.id })),
      random,
    ),
  };
}

function difficultyForRound(round: number): Difficulty {
  return DIFFICULTY_BANDS[Math.min(Math.floor(round / 5), 2)].id;
}

function seededRandom(value: string): () => number {
  let state = hash(value) || 0x9e3779b9;

  return () => {
    state += 0x6d2b79f5;
    let result = Math.imul(state ^ (state >>> 15), 1 | state);
    result ^= result + Math.imul(result ^ (result >>> 7), 61 | result);
    return ((result ^ (result >>> 14)) >>> 0) / 4294967296;
  };
}

function hash(value: string): number {
  let result = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    result ^= value.charCodeAt(index);
    result = Math.imul(result, 16777619);
  }
  return result >>> 0;
}

function shuffle<T>(items: readonly T[], random: () => number): T[] {
  const result = [...items];
  for (let index = result.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(random() * (index + 1));
    [result[index], result[swapIndex]] = [result[swapIndex], result[index]];
  }
  return result;
}
