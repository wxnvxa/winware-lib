'use strict';

const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'fragments.json'), 'utf8'));
const output = path.join(root, 'dist', 'main.lua');
const fragments = manifest.map((relativePath) => {
    const file = path.join(root, relativePath);
    if (!fs.existsSync(file)) {
        throw new Error(`Missing library fragment: ${relativePath}`);
    }
    return fs.readFileSync(file, 'utf8').replace(/\r?\n?$/, '');
});

fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, `${fragments.join('\n')}\n`, 'utf8');
console.log(`Built ${manifest.length} fragments -> ${path.relative(root, output)}`);
