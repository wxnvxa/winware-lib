# WinWare Lib

Modular source distribution of the WinWare UI library.

The original public contract is preserved: the built output returns `function(env)`, then exposes the legacy `Library` table and UI helpers through the returned table. It expects the same `env` contract as `ww/Library.lua` did.

## Layout

- `src/fragments/` contains ordered source fragments.
- `build/fragments.json` is the single source of truth for fragment order.
- `dist/main.lua` is the executor-ready bundle.
- `build/extract-legacy.ps1` is the one-time extraction script used to split the legacy `ww/Library.lua` source without changing behavior.

## Commands

```powershell
npm run build
npm run check
npm test
```

`npm run check` uses the local Luau compiler when available, otherwise the compiler from the sibling `winware` workspace.

## WinWare Figma build

The NeverLose-based WinWare Figma port and its standalone example are available in [`figma/`](figma/README.md).

```luau
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/wxnvxa/winware-lib/main/figma/example.luau"
))()
```
