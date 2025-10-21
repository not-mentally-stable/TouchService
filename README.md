# TouchService

A **secure**, **memory-safe**, and **customizable** replacement for Roblox’s built-in `.Touched` event.  
This module uses [`GoodSignal`](https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063) (by [@stravant](https://github.com/stravant/)) for performance and safety.

---

## ✨ Features

- 🧠 Server-first design — protects against exploiters and spoofed touches  
- 🧼 Memory-leak safe — automatic cleanup of disconnected parts  
- 🧩 Easy API — consistent function signatures for touch and leave events  
- ⚙️ Supports both Players and (optional) NPCs  
- ⚡ Backed using `GoodSignal` for fast, lightweight events

---

## 📦 Installation

1. Copy **`TouchService.luau`** into your project (recommended: `ServerScriptService.Modules.TouchService`).
2. Copy **`GoodSignal.luau`** from [@stravant’s Gist](https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/f6a8900676185457211ec25d22d681c20ee792cb/GoodSignal.lua) into `ReplicatedStorage.Modules`.
3. Update the path at the top of `TouchService.luau`:
```luau
   local GoodSignal = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules").GoodSignal)
```
---

# 🚀 Quick Start

```Luau
local TouchService = require(game.ServerScriptService.Modules.TouchService)

-- Register a callback when a player touches this part
TouchService.OnTouch(workspace.Button, function(player, limb)
	print(player.Name .. " touched the button with " .. limb.Name)
end)

-- Register when a player stops touching the part
TouchService.OnLeft(workspace.Button, function(player)
	print(player.Name .. " left the button")
end)
```
---
# 🧩 API Reference
---
```luau
TouchService.OnTouch(part: BasePart, callback: (player: Player, limb: BasePart) -> ()) → Connection?
```
Connects a listener that fires whenever a player starts touching the given part.

**Parameters**

part -> the BasePart to track.
callback(player, limb) -> fired when a touch begins.

Notes:
Fires only once per initial contact (debounced).
Works server-side or client-side (server recommended).

---

```Luau
TouchService.OnTouchOnce(part: BasePart, callback: (player: Player, limb: BasePart) -> ()) → Connection?
```
Same as OnTouch, but automatically disconnects after the first call.

---
```Luau
TouchService.OnLeft(part: BasePart, callback: (player: Player) -> ()) → Connection?
```
Connects a listener that fires whenever a player stops touching the part.

**Parameters:**

part -> the BasePart being tracked.
callback(player) -> fired when a touch ends.

---
```Luau
TouchService.OnLeftOnce(part: BasePart, callback: (player: Player) -> ()) → Connection?
```
Same as OnLeft, but automatically disconnects after the first call.

---
```Luau
TouchService.Disconnect(part: BasePart, which: "OnTouch" | "OnLeft" | "All") → nil
```
Disconnects listeners from a specific part.

"OnTouch" -> removes all OnTouch connections.

"OnLeft" -> removes all OnLeft connections.

"All" -> removes all listeners and stops tracking the part entirely.

Example:
```Luau
TouchService.Disconnect(workspace.Button, "All")
```

---
```Luau
TouchService:Shutdown()
```
Shuts down the entire TouchService.
Disconnects all signals for all tracked parts.
Clears internal tables.
Stops any touch tracking immediately.
(idk why i made this)

---
```Luau
TouchService:CurrentParts() → {[BasePart]: { OnTouch: GoodSignal, OnLeft: GoodSignal, Touching: {[Instance]: BasePart} }}
```

Returns the current internal table of active parts.
Used mainly for debugging or visualization tools.

---

# ⚙️ Settings

You can configure internal settings at the top of the module:

Property | Type | Default | Description

TouchService.Warnings	boolean	true	Whether to display TouchService warnings in output
TouchService.NpcsSupported	boolean	false	Enables NPC touch detection (via Humanoid models)

---

# Overall TouchService Structure

```Luau
TouchService = {
	OnTouch = function(part: BasePart, callback: (player: Player, limb: BasePart) -> ()) end,
	OnTouchOnce = function(part: BasePart, callback: (player: Player, limb: BasePart) -> ()) end,
	OnLeft = function(part: BasePart, callback: (player: Player) -> ()) end,
	OnLeftOnce = function(part: BasePart, callback: (player: Player) -> ()) end,

	Disconnect = function(part: BasePart, which: string) end,
	Shutdown = function(self) end,
	CurrentParts = function(self): {[BasePart]: table} end,
}
```

TouchService also uses a Heartbeat loop to:

Iterate over all registered parts.
Check each player’s character (and optionally NPCs) using workspace:GetPartsInPart(part).
Compare current and previous touch states.
Fire OnTouch / OnLeft signals accordingly.

It tracks each part like so:

```Luau
activeParts[part] = {
	OnTouch = GoodSignal.new(),
	OnLeft = GoodSignal.new(),
	Touching = { [PlayerOrNpc] = LimbPart }
}
```
> [!note]
> Destroyed parts are automatically cleaned up.

---

# 🧱 Example Usage

Basic Touch Detection
```Luau
local TouchService = require(game.ServerScriptService.Modules.TouchService)

TouchService.OnTouch(workspace.Pad, function(player, limb)
	print(player.Name .. " stepped on the pad with " .. limb.Name)
end)

TouchService.OnLeft(workspace.Pad, function(player)
	print(player.Name .. " left the pad")
end)
```

---

One-Time Touch (Like a Button Press)
```Luau
TouchService.OnTouchOnce(workspace.Button, function(player, limb)
	print(player.Name .. " pressed the button!")
end)
```

---

Cleanup Example
```Luau
-- Disconnect all events for a part
TouchService.Disconnect(workspace.Pad, "All")

-- Or shutdown the service entirely
TouchService:Shutdown()
```

---

You can enable or disable the settings in other scripts
but it isnt recommended to change settings midgame
but you can if you want

```Luau
local TouchService = require(game.ServerScriptService.Modules.TouchService)
TouchService.NpcsSupported = true
```

---

# 🔒 Security & Notes

>[!note]
> Client usage is possible but insecure! Exploiters can Tamper with LocalScripts, so dont attach something like a Remote-Event/Function especially when you dont know how to secure one.
> Always run TouchService logic server-side for important mechanics.
> (but still more secure then Roblox .Touch because it can be tampered with even if its server-sided because .Touch is basically a RemoteEvent because its registered client-side and send to the server, Roblox .Touch can be spammed - or the exploiter disable there client from sending .Touch)

>[!note]
>MeshParts and Unions:
>Supported, but collision shapes may differ from their visible meshes.

---

# Misc...
[![License: ](https://img.shields.io/badge/License%3A-MIT-green?style=plastic)](https://github.com/not-mentally-stable/TouchService/blob/main/LICENSE)

[![Scripting Language: LUAU](https://img.shields.io/badge/Scripting%20Language%3A-LUAU-blue?style=plastic)](https://github.com/luau-lang/luau)
