import { describe, expect, it } from 'vitest';

import {
  CATALOG,
  DIFFICULTY_BANDS,
  chooseRound,
  validateCatalog,
} from '../src/catalog';

describe('chooseRound', () => {
  it('returns one target and four unique base Pokemon options', () => {
    const round = chooseRound('seed-a', 1);
    const ids = round.options.map((option) => option.id);

    expect(round.options).toHaveLength(4);
    expect(new Set(ids).size).toBe(4);
    expect(ids).toContain(round.target.id);
    expect(round.options.every((option) => option.isTarget)).toBe(false);
    expect(round.options.filter((option) => option.isTarget)).toHaveLength(1);
  });

  it('is deterministic for the same seed and round', () => {
    expect(chooseRound('seed-a', 3)).toEqual(
      chooseRound('seed-a', 3),
    );
  });

  it('changes selection when the round changes', () => {
    expect(chooseRound('seed-a', 1)).not.toEqual(
      chooseRound('seed-a', 2),
    );
  });

  it('only selects entries from the requested explicit difficulty band', () => {
    const round = chooseRound('seed-a', 1, 'hard');

    expect(round.difficulty).toBe('hard');
    expect(round.options.every((option) => option.difficulty === 'hard')).toBe(
      true,
    );
  });
});

describe('catalog metadata', () => {
  it('rejects invalid metadata and difficulty assignments at runtime', () => {
    const entries = Array.from({ length: 1025 }, (_, index) => ({
      id: index + 1,
      slug: `pokemon-${index + 1}`,
      name: 'Bulbasaur',
      label: 'Bulbasaur',
      spriteUrl: `https://example.test/${index + 1}.png`,
      difficulty: index === 0 ? 'medium' : index < 151 ? 'easy' : index < 386 ? 'medium' : 'hard',
    }));
    expect(() => validateCatalog(entries)).toThrow('Catalog entry 1 is invalid');
  });

  it('ships unique base Pokemon entries with display and sprite metadata', () => {
    expect(CATALOG).toHaveLength(1025);
    expect(new Set(CATALOG.map((entry) => entry.id)).size).toBe(1025);
    expect(CATALOG.map((entry) => entry.id)).toEqual(
      Array.from({ length: 1025 }, (_, index) => index + 1),
    );
    expect(
      CATALOG.every(
        (entry) =>
          entry.id >= 1 &&
          entry.id <= 1025 &&
          entry.slug.length > 0 &&
          entry.name.length > 0 &&
          entry.label.length > 0 &&
          entry.spriteUrl.startsWith('https://'),
      ),
    ).toBe(true);
  });

  it('defines ordered, non-overlapping difficulty bands', () => {
    expect(DIFFICULTY_BANDS).toEqual([
      { id: 'easy', minId: 1, maxId: 151 },
      { id: 'medium', minId: 152, maxId: 386 },
      { id: 'hard', minId: 387, maxId: 1025 },
    ]);
    for (const band of DIFFICULTY_BANDS) {
      expect(CATALOG.filter((entry) => entry.difficulty === band.id).length).toBeGreaterThanOrEqual(4);
    }
  });
});
