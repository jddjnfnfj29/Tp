if getgenv then 
    getgenv().LoadTime = "5" -- задержка загрузки скрипта
    getgenv().GeneratorTime = "3.5" -- можете копировать скрипт и ставить свои значения чтобы не кикало ставте минимально 2.5
end

--!nocheck
if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat
		task.wait()
	until game:IsLoaded()
end

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local SprintingModule: any

if _G.CancelPathEvent then
	_G.CancelPathEvent:Fire()
end

_G.CancelPathEvent = Instance.new("BindableEvent")

pcall(function()
	local Controller = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	Controller:Disable()
end)

local function TpRandom()
	local Counter = 0
	local MaxRetry = 10
	local RetryingDelays = 10

	if request then
		local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"

		while Counter < MaxRetry do
			local success, response = pcall(function()
				return request({
					Url = url,
					Method = "GET",
					Headers = { ["Content-Type"] = "application/json" },
				})
			end)

			if success and response and response.Body then
				local data = HttpService:JSONDecode(response.Body)
				if data and data.data and #data.data > 0 then
					local server = data.data[math.random(1, #data.data)]
					if server.id then
						task.wait(0.25)
						TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
						return
					end
				end
			end

			Counter = Counter + 1
			task.wait(RetryingDelays)
		end
	end
end

task.delay(2.5, function()
	pcall(function()
		local timer = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local minutes, seconds = timer:match("(%d+):(%d+)")
		local totalSeconds = tonumber(minutes) * 60 + tonumber(seconds)
		print(totalSeconds .. " Left till round end.")
		if totalSeconds > 50 then
			TpRandom()
		end
	end)
end)

local function FindGen()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				local playersNearby = false
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= Players.LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
						playersNearby = true
					end
				end
				if not playersNearby then
					table.insert(generators, g)
				end
			end
		end
	end

	table.sort(generators, function(a, b)
		local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
		if not killersFolder then
			return false
		end

		local killers = killersFolder:GetChildren()
		if #killers == 0 then
			return false
		end

		local killer = killers[1]
		if not killer or not killer:FindFirstChild("HumanoidRootPart") then
			return false
		end

		local killerPosition = killer.HumanoidRootPart.Position
		local aPosition = a:IsA("Model") and a:GetPivot().Position or a.Position
		local bPosition = b:IsA("Model") and b:GetPivot().Position or b.Position
		return (aPosition - killerPosition).Magnitude > (bPosition - killerPosition).Magnitude
	end)

	return generators
end

local function VisualizePivot(model)
	local pivot = model:GetPivot()

	for i, dir in ipairs({
		{ pivot.LookVector, Color3.fromRGB(0, 255, 0), "Front" },
		{ -pivot.LookVector, Color3.fromRGB(255, 0, 0), "Back" },
		{ pivot.RightVector, Color3.fromRGB(255, 255, 0), "Right" },
		{ -pivot.RightVector, Color3.fromRGB(0, 0, 255), "Left" },
	}) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Color = dir[2]
		part.Name = dir[3]
		part.Position = pivot.Position + dir[1] * 5
		part.Parent = workspace
	end
end

local function InGenerator()
	for i, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		print(v.Name)
		if string.sub(v.Name, 1, 3) == "Gen" then
			print("not in generator")
			return false
		end
	end
	print("didnt find frame")
	return true
end

local function PathFinding(generator)
	pcall(function()
		SprintingModule = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
		SprintingModule.StaminaLossDisabled = true
	end)

	local activeNodes = {}

	local function createNode(position)
		local part = Instance.new("Part")
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(248, 255, 150)
		part.Transparency = 0.5
		part.Anchored = true
		part.CanCollide = false
		part.Position = position + Vector3.new(0, 1.5, 0)
		part.Parent = workspace
		table.insert(activeNodes, part)
		game:GetService("Debris"):AddItem(part, 15)
	end

	local acidContainer = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("Ingame")
		and workspace.Map.Ingame:FindFirstChild("Map")
		and workspace.Map.Ingame.Map:FindFirstChild("AcidContainer")
		and workspace.Map.Ingame.Map.AcidContainer:FindFirstChild("AcidDirt")
	if acidContainer then
		for _, part in ipairs(acidContainer:GetChildren()) do
			if part.Name == "Dirt" and part.Size.Y < 12 then
				part.Size = Vector3.new(part.Size.X, 13, part.Size.Z)
			end
		end
	end

	if not generator or not generator.Parent then
		return false
	end
	if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = Players.LocalPlayer.Character.HumanoidRootPart
	if not humanoid then
		return false
	end

	local targetPosition = generator:GetPivot().Position + generator:GetPivot().LookVector * 3
	if not targetPosition then
		return false
	end

	VisualizePivot(generator)

	local path = game:GetService("PathfindingService"):CreatePath({
		AgentRadius = 2.5,
		AgentHeight = 1,
		AgentCanJump = false,
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(rootPart.Position, targetPosition)
	end)

	if not success or path.Status ~= Enum.PathStatus.Success then
		print("Path computation failed:", errorMessage)
		return false
	end

	local waypoints = path:GetWaypoints()

	if #waypoints <= 1 then
		return false
	end

	for i, waypoint in ipairs(waypoints) do
		createNode(waypoint.Position)
		humanoid:MoveTo(waypoint.Position)
		SprintingModule.IsSprinting = true
		LocalPlayer.Character.SpeedMultipliers.Sprinting.Value = 2.15

		local reachedWaypoint = false
		local startTime = tick()
		while not reachedWaypoint and tick() - startTime < 5 do
			local distance = (rootPart.Position - waypoint.Position).Magnitude
			if distance < 5 then
				reachedWaypoint = true
				break
			end
			RunService.Heartbeat:Wait()
		end

		if not reachedWaypoint then
			return false
		end
	end

	for _, node in ipairs(activeNodes) do
		node:Destroy()
	end

	return true
end

local function DoAllGenerators()
	for _, g in ipairs(FindGen()) do
		local pathStarted = false
		for attempt = 1, 3 do
			if (Players.LocalPlayer.Character:GetPivot().Position - g:GetPivot().Position).Magnitude > 500 then
				break
			end

			pathStarted = PathFinding(g)
			if pathStarted then
				break
			else
				task.wait(1)
			end
		end
		if pathStarted then
			task.wait(0.5)
			local prompt = g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
			if prompt then
				fireproximityprompt(prompt)
				task.wait(0.5)
				if not InGenerator() then
					local positions = {
						g:GetPivot().Position - g:GetPivot().RightVector * 3,
						g:GetPivot().Position + g:GetPivot().RightVector * 3,
					}
					for i, pos in ipairs(positions) do
						print("Trying position", i)
						Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
						task.wait(0.25)
						fireproximityprompt(prompt)
						if InGenerator() then
							break
						end
					end
				end
			end
			for i = 1, 6 do
				if g.Progress.Value < 100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
					g.Remotes.RE:FireServer()
				end
				if i < 6 and g.Progress.Value < 100 then
					task.wait(GenTime)
				end
			end
		else
			return
		end
	end
	
	print("Finished all generators")
	task.wait(1)
	TpRandom()
end

local function AmIInGameYet()
	if LocalPlayer.Character.Parent == workspace.Players.Survivors then
		DoAllGenerators()
	end

	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child == game:GetService("Players").LocalPlayer.Character then
			task.wait(4)
			DoAllGenerators()
		end
	end)
end

local function DidiDie()
	while task.wait(0.5) do
		if Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			if Players.LocalPlayer.Character.Humanoid.Health == 0 then
				print("Player died, teleporting to another server")
				task.wait(0.5)
				TpRandom()
				break
			end
		end
	end
end

pcall(task.spawn(DidiDie))
AmIInGameYet()
