--!strict

--// dont remove [--!strict]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Change this!
--// scroll down for settings btw
local GoodSignal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GoodSignal"))

--// Type Definitions
type PlayerOrNpc = Player | Model
type Limb = BasePart

export type TouchData = {
	OnTouch: GoodSignal.Signal<(PlayerOrNpc, Limb) -> ()>,
	OnLeft: GoodSignal.Signal<(PlayerOrNpc) -> ()>,
	Touching: { [PlayerOrNpc]: Limb? },
}

export type TouchService = {
	Warnings: boolean,
	NpcsSupported: boolean,

	OnTouch: (part: BasePart, callback: (PlayerOrNpc, Limb) -> ()) -> RBXScriptConnection,
	OnTouchOnce: (part: BasePart, callback: (PlayerOrNpc, Limb) -> ()) -> RBXScriptConnection,
	OnLeft: (part: BasePart, callback: (PlayerOrNpc) -> ()) -> RBXScriptConnection,
	OnLeftOnce: (part: BasePart, callback: (PlayerOrNpc) -> ()) -> RBXScriptConnection,
	Disconnect: (part: BasePart, which: "All" | "OnTouch" | "OnLeft") -> (),
	Shutdown: (self: TouchService) -> (),
	CurrentParts: (self: TouchService) -> { [BasePart]: TouchData },
}

--// Module
local TouchService: TouchService = {} :: any
TouchService.__index = TouchService

--// Settings
TouchService.Warnings = true
TouchService.NpcsSupported = false

--// Internals
local activeParts: { [BasePart]: TouchData } = {}
local heartbeatConn: RBXScriptConnection? = nil

--// Utilities
local function isServer(): boolean
	return RunService:IsServer()
end

local function warnMsg(msg: string)
	if TouchService.Warnings then
		warn("[TouchService Warning] " .. msg)
	end
end

local function getCharacterLimbTouching(part: BasePart, character: Model?): Limb?
	if not character or not character.Parent then return nil end
	local touching = workspace:GetPartsInPart(part)
	for _, limb in ipairs(character:GetDescendants()) do
		if limb:IsA("BasePart") then
			for _, tPart in ipairs(touching) do
				if tPart == limb then
					return limb
				end
			end
		end
	end
	return nil
end

local function isNpcModel(model: Instance): boolean
	if not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	return model:FindFirstChildWhichIsA("Humanoid") ~= nil
end

--// Core loop
local function updateTouches()
	for part, data in pairs(activeParts) do
		if not part or not part.Parent then
			activeParts[part] = nil
			continue
		end

		--// Players
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local limb = getCharacterLimbTouching(part, char)
			local wasTouching = data.Touching[player]

			if limb and not wasTouching then
				data.Touching[player] = limb
				data.OnTouch:Fire(player, limb)
			elseif not limb and wasTouching then
				data.Touching[player] = nil
				data.OnLeft:Fire(player)
			end
		end

		--// NPCs
		if TouchService.NpcsSupported then
			for _, model in ipairs(workspace:GetChildren()) do
				if isNpcModel(model) then
					local limb = getCharacterLimbTouching(part, model)
					local wasTouching = data.Touching[model]

					if limb and not wasTouching then
						data.Touching[model] = limb
						data.OnTouch:Fire(model, limb)
					elseif not limb and wasTouching then
						data.Touching[model] = nil
						data.OnLeft:Fire(model)
					end
				end
			end
		end
	end
end

--// Public API
function TouchService.OnTouch(part: BasePart, callback: (PlayerOrNpc, Limb) -> ()): RBXScriptConnection
	if not activeParts[part] then
		activeParts[part] = {
			OnTouch = GoodSignal.new(),
			OnLeft = GoodSignal.new(),
			Touching = {},
		}
	end

	if not isServer() then
		warnMsg("Detected TouchService being used ClientSided. It works, but not recommended for security reasons, don't make it important / attached to a Remote that isn't secured.")
	end

	if part:IsA("MeshPart") then
		warnMsg("Detected MeshPart usage with TouchService. The mesh may not match the touch box.")
	elseif part:IsA("UnionOperation") then
		warnMsg("Detected Union usage with TouchService. The shape may not match the touch box.")
	end

	return activeParts[part].OnTouch:Connect(callback)
end

function TouchService.OnTouchOnce(part: BasePart, callback: (PlayerOrNpc, Limb) -> ()): RBXScriptConnection
	if not activeParts[part] then
		activeParts[part] = {
			OnTouch = GoodSignal.new(),
			OnLeft = GoodSignal.new(),
			Touching = {},
		}
	end
	return activeParts[part].OnTouch:Once(callback)
end

function TouchService.OnLeft(part: BasePart, callback: (PlayerOrNpc) -> ()): RBXScriptConnection
	if not activeParts[part] then
		activeParts[part] = {
			OnTouch = GoodSignal.new(),
			OnLeft = GoodSignal.new(),
			Touching = {},
		}
	end
	return activeParts[part].OnLeft:Connect(callback)
end

function TouchService.OnLeftOnce(part: BasePart, callback: (PlayerOrNpc) -> ()): RBXScriptConnection
	if not activeParts[part] then
		activeParts[part] = {
			OnTouch = GoodSignal.new(),
			OnLeft = GoodSignal.new(),
			Touching = {},
		}
	end
	return activeParts[part].OnLeft:Once(callback)
end

function TouchService.Disconnect(part: BasePart, which: "All" | "OnTouch" | "OnLeft")
	if not activeParts[part] then return end

	if which == "All" or which == "OnTouch" then
		activeParts[part].OnTouch:DisconnectAll()
	end
	if which == "All" or which == "OnLeft" then
		activeParts[part].OnLeft:DisconnectAll()
	end
	if which == "All" then
		activeParts[part] = nil
	end
end

function TouchService:Shutdown()
	for _, data in pairs(activeParts) do
		data.OnTouch:DisconnectAll()
		data.OnLeft:DisconnectAll()
	end
	table.clear(activeParts)

	if self.Warnings then
		warn("TouchService has been shutdown and cleared.")
	end
end

function TouchService:CurrentParts(): { [BasePart]: TouchData }
	return activeParts
end

--// Start heartbeat if not started
if not heartbeatConn then
	heartbeatConn = RunService.Heartbeat:Connect(updateTouches)
end

return TouchService
