'use strict';

const childProcess = require('child_process');
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const candidates = [
    path.join(root, 'tools', 'luau', 'luau-compile.exe'),
    path.join(root, '..', 'winware', 'tools', 'luau', 'luau-compile.exe'),
];
const compiler = candidates.find((candidate) => fs.existsSync(candidate));

if (!compiler) {
    throw new Error('Luau compiler not found. Place it in tools/luau or keep the sibling winware workspace available.');
}

const result = childProcess.spawnSync(compiler, [path.join(root, 'dist', 'main.lua')], {
    cwd: root,
    encoding: 'utf8',
});

if (result.error) {
    throw result.error;
}

if (result.status !== 0) {
    process.stderr.write(result.stdout || '');
    process.stderr.write(result.stderr || '');
    process.exitCode = result.status || 1;
} else {
    console.log('Luau compile passed');
}
