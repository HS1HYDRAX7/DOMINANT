# Dominant repository: context for AI contributors

Read this file completely before changing anything.

## Goal
Roblox executor scripts (Vind UI + Ophyn key system). One loader, one shared core,
one module per game. The loader downloads modules at runtime through `modules:require`.

## Structure
- `loader.lua`: entry point users run. Only file with the base URL. Do not add logic here.
- `core/config.lua`: all user-facing constants (title, keys, URLs, folders). Edit here only.
- `core/modules.lua`: module loader (download, compile, cache). Do not change its contract.
- `core/base.lua`: runtime context `ctx` (settings, hooks, loops, bindings, session, unload).
- `core/ui.lua`: Vind control helpers (`ctx.ui`). Use these instead of raw Vind calls.
- `core/vind.lua`: loads Vind from `config.VindUrl`. Single URL, no fallbacks.
- `core/keysystem.lua`: Ophyn key system. Called by app, not by games.
- `core/app.lua`: startup order. Games never call it.
- `games/index.lua`: registry. Adds a game by name, detection function, and key system ids.
- `games/<game>/init.lua`: game module (see contract below).
- `shared/ui_common.lua`: Home and Settings tabs. Identical for every game.
- `reference/`: original uploaded scripts. Read-only source material for porting.

## Module contract (games/<game>/init.lua)
Return a table:
- `Name` (string): shown in Home.
- `Init(ctx)`: register settings and hooks. Runs before the session is loaded. No UI here.
- `Build(window, ctx)`: create the game's tabs with `window:AddTab`. Do not create Home or Settings.
Features live in `games/<game>/features/<group>.lua`. Each file returns `function(ctx) ... end`
and is required from `init.lua`.

## The ctx API (what modules may use)
- Settings: `ctx.addSetting(key, default, hook?)`, `ctx.set(key, value)`, `ctx.cfg[key]`, `ctx.hook(key, fn)`
- Hotkeys: `ctx.addHotkey(key, label, run)` (Settings tab builds the keybind)
- Loops: `ctx.startLoop(name, interval, fn)`, `ctx.stopLoop(name)` (self-stops after 30 errors)
- Events: `ctx.bind(name, signal, fn)`, `ctx.unbind(name)`
- Character: `ctx.state.character | humanoid | root`, `ctx.onCharacter(fn)` (runs after respawn)
- Cleanup: `ctx.onUnload(fn)` (runs when the script unloads). Every feature must clean up here.
- UI: `ctx.ui.section | paragraph | toggle | slider | number | color | button | keybind`
- Feedback: `ctx.notify(text, kind, duration)`, `ctx.status(text)`, `ctx.warn(text)`, `ctx.copy(text)`
- Session: `ctx.saveSession()`, `ctx.loadSession()`, `ctx.reset()`, `ctx.applyAll()`

Hooks run when a setting changes, and once at startup for every setting that has a hook.
A boolean hook must handle `false` (turn the feature off and restore what it changed).

## Rules
1. All code, comments, identifiers and UI text are in English.
2. Do not use localStorage, sessionStorage or browser storage APIs.
3. Do not add fallback URLs. Do not add a game-ID check that blocks startup.
4. Do not create Home or Settings tabs in game modules. Use `shared/ui_common.lua`.
5. Do not call Vind directly from a feature. Use `ctx.ui`, so controls stay consistent.
6. Every feature must have an off path that restores the game state it changed.
7. Every loop, bind and instance a feature creates must be cleaned up through `ctx.onUnload`
   or its own hook when disabled.
8. Keep files under about 400 lines. Split feature groups into separate files.
9. Do not change `core/` contracts without asking. Adding a new `ctx` function is allowed
   if it is documented here.
10. Use `pcall` around anything that touches game objects that may not exist yet.
11. You cannot run Roblox. State clearly which parts you verified only by reading.

## Porting from reference/
- `reference/pressure_monolith.lua`: finished Pressure features (ESP, Anti, movement, doors). It was
  written as one file with its own UI. Port logic, not its UI code. Replace `CreateToggle` and
  similar calls with `ctx.ui` helpers, and replace its global state with `ctx` settings.
- `reference/pressure_main.lua`: the original Pressure script (source of the pressure features).
- `reference/forsaken_dominant.lua`: the original Forsaken Dominant script (about 10k lines).
  Port features group by group. Do not copy the Vind boilerplate or the key system.

## Task queue for the next contributor
1. Pressure: port ESP (items, currency, keycards, monsters, players, doors, generators) to
   `games/pressure/features/esp.lua`. Use `ctx.startLoop`, and `ctx.onUnload` to clear highlights.
2. Pressure: port the Anti removals to `features/anti.lua`. Use one generic sweep helper.
3. Pressure: port movement (speed boost, noclip, fly, ghost players, teleports, anchor) to
   `features/movement.lua`.
4. Pressure: port automation (loot aura, instant prompts, open sesame, door tools) to `features/automation.lua`.
5. Pressure: port world (fullbright, no fog, FOV, third person) to `features/world.lua`.
6. Forsaken: port the Dominant features group by group, starting with movement and ESP.
