# Dominant

Scripts for Roblox executors. One loader, one shared core, one module per game.

## Running
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/dominant/main/loader.lua"))()
```
Replace `USER` in `loader.lua` (the `BASE` variable) with your repository path.

## Layout
- `loader.lua`: entry point
- `core/`: loader, config, settings, Vind wrapper, key system, startup
- `shared/ui_common.lua`: Home and Settings tabs used by every game
- `games/`: one folder per game, plus `index.lua` to detect it
- `reference/`: original scripts used for porting

## Adding a game
1. Create `games/<name>/init.lua` (see `CONTEXT.md` for the contract).
2. Add an entry to `games/index.lua` with a detection function.

## Contributing with AI
Give `CONTEXT.md` to the model before asking for changes.
