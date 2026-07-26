'use strict';

const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(root, 'build', 'fragments.json'), 'utf8'));
const bundle = fs.readFileSync(path.join(root, 'dist', 'main.lua'), 'utf8');
const expected = `${manifest.map((relativePath) => fs.readFileSync(path.join(root, relativePath), 'utf8').replace(/\r?\n?$/, '')).join('\n')}\n`;

if (bundle !== expected) {
    throw new Error('dist/main.lua does not match the ordered source fragments. Run npm run build.');
}

if (!bundle.startsWith('return function(env)')) {
    throw new Error('The WinWare library factory contract is missing.');
}

console.log(`Bundle integrity passed for ${manifest.length} fragments`);
