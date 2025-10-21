# TouchService API Documentation📕
A secure & memory-safe replacement for BasePart.Touched. 
Tracks player characters touching specific parts and provides events.
    
---
# 💡 Event APIs:

`TouchService.OnTouch(part, callback)`
  → Fires whenever a Player's limb starts touching the part.
  → Callback signature: (player: Player, limb: BasePart)

`TouchService.OnTouchOnce(part, callback)`
  → Same as OnTouch, but fires only once.

`TouchService.OnLeft(part, callback)`
  → Fires whenever a Player stops touching the part.
  → Callback signature: (player: Player)

`TouchService.OnLeftOnce(part, callback)`
  → Same as OnLeft, but fires only once.
  
---
# ⚙️ Management APIs:

`TouchService.Disconnect(part, which)`
  → Disconnects event listeners from a part.
  → which can be:
"OnTouch" – disconnects all OnTouch listeners.
"OnLeft"  – disconnects all OnLeft listeners.
"All"     – disconnects both signals and removes the part from tracking.

`TouchService:Shutdown()`
  → Disconnects every active part, clears the internal table,

`TouchService:CurrentParts()`
  → Returns the internal table of currently tracked parts, if you want it for some reason..
  
  
>[!Note]
>Designed for ServerScripts. LocalScript use is possible but not recommended for sercuiry & performance reasons.
>MeshParts & Unions are supported, but collision shape may not match the mesh geometry.
>Will automatically clean up destroyed parts.

---
# ⚙️ Settings
You can configure internal settings at the top of the module:

Property | Type | Default | Description

TouchService.Warnings | boolean | true | Whether to display TouchService warnings in output

TouchService.NpcsSupported | boolean | false | Enables NPC touch detection (via Humanoid models)

>( you *can* change settings mid game but not recommended but still will work)

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
One-Time Touch (Like a Button Press)
```Luau
TouchService.OnTouchOnce(workspace.Button, function(player, limb)
	print(player.Name .. " pressed the button!")
end)
```
Cleanup Example
```Luau
-- Disconnect all events for a part
TouchService.Disconnect(workspace.Pad, "All")

-- Or shutdown the service entirely
TouchService:Shutdown()
```

---
# Misc...
[![License: ](https://img.shields.io/badge/License%3A-MIT-green?style=plastic)](https://github.com/not-mentally-stable/TouchService/blob/main/LICENSE)

[![Scripting Language: LUAU](https://img.shields.io/badge/Scripting%20Language%3A-LUAU-blue?style=plastic)](https://github.com/luau-lang/luau)
