#!/usr/bin/env node

/**
 * Script to extract ABIs from Forge build artifacts and create a convenient exports file.
 * Run after `forge build` to prepare ABIs for TypeScript/JavaScript consumption.
 */

import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, '..');

const contracts = [
  { name: 'AssociationsStore', path: 'AssociationsStore.sol/AssociationsStore.json' },
  { name: 'AssociatedAccounts', path: 'AssociatedAccounts.sol/AssociatedAccounts.json' },
];

// Ensure abis directory exists
const abisDir = join(rootDir, 'abis');
mkdirSync(abisDir, { recursive: true });

const exports = [];

for (const contract of contracts) {
  try {
    const artifactPath = join(rootDir, 'out', contract.path);
    const artifact = JSON.parse(readFileSync(artifactPath, 'utf-8'));
    
    // Write individual ABI file
    const abiPath = join(abisDir, `${contract.name}.ts`);
    const abiContent = `export const ${contract.name.charAt(0).toLowerCase() + contract.name.slice(1)}Abi = ${JSON.stringify(artifact.abi, null, 2)} as const;\n`;
    writeFileSync(abiPath, abiContent);
    
    exports.push(`export { ${contract.name.charAt(0).toLowerCase() + contract.name.slice(1)}Abi } from './${contract.name}.js';`);
    
    console.log(`✓ Generated ABI for ${contract.name}`);
  } catch (error) {
    console.warn(`⚠ Could not process ${contract.name}: ${error.message}`);
  }
}

// Write index file
const indexPath = join(abisDir, 'index.ts');
writeFileSync(indexPath, exports.join('\n') + '\n');
console.log(`✓ Generated index file`);

console.log('\nABIs prepared successfully!');

