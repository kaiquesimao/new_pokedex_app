import { readdir, readFile } from 'node:fs/promises';

const files = (await readdir('migrations'))
  .filter((file) => /^\d{4}_[a-z0-9_]+\.sql$/.test(file))
  .sort();
if (files.length === 0) throw new Error('At least one D1 migration is required');

for (const [index, file] of files.entries()) {
  if (Number(file.slice(0, 4)) !== index + 1) {
    throw new Error(`Migration sequence must be contiguous: ${file}`);
  }
  if ((await readFile(`migrations/${file}`, 'utf8')).trim().length === 0) {
    throw new Error(`Migration is empty: ${file}`);
  }
}

console.log(`Validated ${files.length} D1 migrations`);
