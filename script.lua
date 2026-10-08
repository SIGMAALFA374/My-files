--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================
local bankRunEnabled = false
local flying = false

local heheEnabled = false
local ctrlHeld = false
local menuOpen = false

local speed = 45

-- AIM ASSIST
local AIM_DISTANCE = 100
local AIM_STRENGTH = 1
local aimRadius = 150

-- ANTI-CHEAT BYPASS
local bypassEnabled = true
local TELEPORT_COOLDOWN = 0.12
local velocityLock = false

-- FARM
local autoRob = false
local autoCollect = false
local autoArrest = false
local autoEscape = false
local farmRadius = 2500
local escapePoint = nil

local point1 = nil
local point2 = nil
local marker1 = nil
local marker2 = nil

--==================================================
-- GUI
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "TaseHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(680, 380)
main.Position = UDim2.new(0.5, -340, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
main.BackgroundTransparency = 0.35
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(90, 90, 110)
mainStroke.Transparency = 0.55
mainStroke.Thickness = 1
mainStroke.Parent = main

local scale = Instance.new("UIScale")
scale.Scale = 0
scale.Parent = main

--==================================================
-- HEADER
--==================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 55)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "Tase Hub"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextSize = 16
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.fromOffset(0, 55)
line.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
line.BackgroundTransparency = 0.5
line.BorderSizePixel = 0
line.Parent = main

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
closeBtn.BackgroundTransparency = 0.3
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.Gotham
closeBtn.AutoButtonColor = false
closeBtn.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- WATERMARK
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.fromOffset(220, 16)
watermark.Position = UDim2.new(1, -235, 1, -20)
watermark.BackgroundTransparency = 1
watermark.Text = "@by lifenos"
watermark.TextColor3 = Color3.fromRGB(200, 200, 215)
watermark.TextTransparency = 0.55
watermark.TextSize = 11
watermark.Font = Enum.Font.Gotham
watermark.TextXAlignment = Enum.TextXAlignment.Right
watermark.Parent = main

--==================================================
-- TABS
--==================================================
local tabs = { "Combat", "Movement", "Farm", "Visuals" }
local tabButtons = {}

for i, name in ipairs(tabs) do

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(110, 32)
	button.Position = UDim2.fromOffset(18 + (i - 1) * 118, 64)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	button.BackgroundTransparency = 0.15
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Color3.fromRGB(210, 210, 210)
	button.TextSize = 13
	button.Font = Enum.Font.Gotham
	button.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = button

	tabButtons[name] = button
end

--==================================================
-- PAGES
--==================================================
local function newPage()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, -36, 1, -145)
	p.Position = UDim2.fromOffset(18, 118)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = main
	return p
end

local movementPage = newPage()
local combatPage = newPage()
local farmPage = newPage()
local visualsPage = newPage()

--==================================================
-- GRID / HELPERS
--==================================================
local COL_W = 305
local COL1 = 0
local COL2 = 320
local ROW_H = 48
local ROW_GAP = 8

local function rowY(i)
	return i * (ROW_H + ROW_GAP)
end

local function createRow(parent, x, y, w, text)

	local row = Instance.new("Frame")
	row.Size = UDim2.fromOffset(w, ROW_H)
	row.Position = UDim2.fromOffset(x, y)
	row.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -100, 1, 0)
	label.Position = UDim2.fromOffset(15, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	return row
end

local function createToggle(parent, x, y, w, text, onChange)

	local row = createRow(parent, x, y, w, text)

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(44, 26)
	toggle.Position = UDim2.new(1, -54, 0.5, -13)
	toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = row

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(20, 20)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	knob.BorderSizePixel = 0
	knob.Parent = toggle

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local state = false

	toggle.MouseButton1Click:Connect(function()
		state = not state

		if state then
			toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
			knob.BackgroundColor3 = Color3.fromRGB(20, 150, 220)
			TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(21, 3)}):Play()
		else
			toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
			knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
			TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(3, 3)}):Play()
		end

		if onChange then
			onChange(state)
		end
	end)

	return toggle
end

local function createButton(parent, x, y, w, text, onClick)

	local row = createRow(parent, x, y, w, text)

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(100, 30)
	button.Position = UDim2.new(1, -112, 0.5, -15)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(220, 220, 220)
	button.TextSize = 12
	button.Font = Enum.Font.Gotham
	button.Parent = row

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = button

	if onClick then
		button.MouseButton1Click:Connect(onClick)
	end

	return button
end

local function createInput(parent, x, y, w, text, onDone)

	local row = createRow(parent, x, y, w, text)

	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(70, 30)
	box.Position = UDim2.new(1, -82, 0.5, -15)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	box.BorderSizePixel = 0
	box.Text = text
	box.TextColor3 = Color3.fromRGB(230, 230, 230)
	box.TextSize = 13
	box.Font = Enum.Font.Gotham
	box.ClearTextOnFocus = false
	box.Parent = row

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = box

	box.FocusLost:Connect(function()
		if onDone then
			onDone(box.Text)
		end
	end)

	return box
end

--==================================================
-- MOVEMENT
--==================================================
createToggle(movementPage, COL1, rowY(0), COL_W, "Bank Run", function(v)
	bankRunEnabled = v
	if v then
		task.spawn(startBankRun)
	else
		flying = false
	end
end)

local speedBox = createInput(movementPage, COL2, rowY(0), COL_W, tostring(speed), function(t)
	local v = tonumber(t)
	if v then
		speed = math.clamp(v, 5, 300)
	end
	speedBox.Text = tostring(speed)
end)

createButton(movementPage, COL1, rowY(1), COL_W, "Set Point 1", function()
	local root = getRoot()
	if not root then return end
	point1 = root.Position
	removeMarker(marker1)
	marker1 = createMarker(point1, "BankRunPoint1", 1)
end)

createButton(movementPage, COL2, rowY(1), COL_W, "Set Point 2", function()
	local root = getRoot()
	if not root then return end
	point2 = root.Position
	removeMarker(marker2)
	marker2 = createMarker(point2, "BankRunPoint2", 2)
end)

createButton(movementPage, COL1, rowY(2), COL_W, "Clear Points", function()
	point1 = nil
	point2 = nil
	removeMarker(marker1)
	removeMarker(marker2)
	marker1 = nil
	marker2 = nil
end)

createToggle(movementPage, COL2, rowY(2), COL_W, "GHOST", function(v)
	ghostEnabled = v
end)

--==================================================
-- COMBAT
--==================================================
createToggle(combatPage, COL1, rowY(0), COL_W, "HEHEHE (Ctrl = aim)", function(v)
	heheEnabled = v
end)

local aimBox = createInput(combatPage, COL2, rowY(0), COL_W, tostring(aimRadius), function(t)
	local v = tonumber(t)
	if v then
		aimRadius = math.clamp(v, 20, 600)
	end
	aimBox.Text = tostring(aimRadius)
end)

local aimDistBox = createInput(combatPage, COL1, rowY(1), COL_W, tostring(AIM_DISTANCE), function(t)
	local v = tonumber(t)
	if v then
		AIM_DISTANCE = math.clamp(v, 10, 1000)
	end
	aimDistBox.Text = tostring(AIM_DISTANCE)
end)

--==================================================
-- FARM
--==================================================
local farmStatusRow = createRow(farmPage, COL2, rowY(3), COL_W, "Status")

local farmStatus = Instance.new("TextLabel")
farmStatus.Size = UDim2.new(1, -20, 1, 0)
farmStatus.BackgroundTransparency = 1
farmStatus.Text = "Idle"
farmStatus.TextColor3 = Color3.fromRGB(120, 200, 255)
farmStatus.TextSize = 12
farmStatus.Font = Enum.Font.Gotham
farmStatus.TextXAlignment = Enum.TextXAlignment.Right
farmStatus.Parent = farmStatusRow

local function setStatus(text)
	farmStatus.Text = text
end

createToggle(farmPage, COL1, rowY(0), COL_W, "Auto Rob (все ограбления)", function(v)
	autoRob = v
	if v then setStatus("Auto Rob: ON") else setStatus("Idle") end
end)

createToggle(farmPage, COL2, rowY(0), COL_W, "Auto Collect Cash", function(v)
	autoCollect = v
end)

createToggle(farmPage, COL1, rowY(1), COL_W, "Auto Arrest (коп)", function(v)
	autoArrest = v
end)

createToggle(farmPage, COL2, rowY(1), COL_W, "Auto Escape (тюрьма)", function(v)
	autoEscape = v
end)

local robAllButton = createButton(farmPage, COL1, rowY(2), COL_W, "Rob All", function()
	task.spawn(function()
		local was = autoRob
		autoRob = true
		setStatus("Rob All...")
		task.wait(8)
		if not was then autoRob = false end
		setStatus("Done")
	end)
end)

createButton(farmPage, COL2, rowY(2), COL_W, "Set Escape Point", function()
	local root = getRoot()
	if not root then return end
	escapePoint = root.Position
	setStatus("Escape point set")
end)

createToggle(farmPage, COL1, rowY(3), COL_W, "Anti-Cheat Bypass", function(v)
	bypassEnabled = v
end)

--==================================================
-- VISUALS
--==================================================
local espEnabled = false

createToggle(visualsPage, COL1, rowY(0), COL_W, "Player ESP", function(v)
	espEnabled = v
end)

local camFovBox = createInput(visualsPage, COL2, rowY(0), COL_W, tostring(math.floor(Camera.FieldOfView)), function(t)
	local v = tonumber(t)
	if v then
		Camera.FieldOfView = math.clamp(v, 20, 120)
	end
	camFovBox.Text = tostring(math.floor(Camera.FieldOfView))
end)

local fullbright = false
local savedLighting = nil

createToggle(visualsPage, COL1, rowY(1), COL_W, "Fullbright", function(v)
	fullbright = v

	if v then
		savedLighting = {
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
		}
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
	elseif savedLighting then
		Lighting.Ambient = savedLighting.Ambient
		Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
		Lighting.Brightness = savedLighting.Brightness
		Lighting.ClockTime = savedLighting.ClockTime
	end
end)

--==================================================
-- TABS FUNCTION
--==================================================
local function showTab(tabName)

	movementPage.Visible = tabName == "Movement"
	combatPage.Visible = tabName == "Combat"
	farmPage.Visible = tabName == "Farm"
	visualsPage.Visible = tabName == "Visuals"

	for name, button in pairs(tabButtons) do
		if name == tabName then
			button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			button.TextColor3 = Color3.fromRGB(35, 35, 35)
		else
			button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			button.TextColor3 = Color3.fromRGB(210, 210, 210)
		end
	end
end

for name, button in pairs(tabButtons) do
	button.MouseButton1Click:Connect(function()
		showTab(name)
	end)
end

showTab("Movement")

--==================================================
-- MARKERS
--==================================================
function createMarker(position, name, number)

	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(2.5, 2.5, 2.5)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = number == 1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 255, 120)
	part.Transparency = 0.25
	part.Parent = workspace

	return part
end

function removeMarker(marker)
	if marker then
		marker:Destroy()
	end
end

--==================================================
-- CHARACTER / TEAM
--==================================================
function getRoot()
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

local function isPrisoner()
	local team = player.Team
	if not team then return false end
	return team.Name:lower():find("prison") ~= nil
end

--==================================================
-- ANTI-CHEAT BYPASS
--==================================================
RunService.Stepped:Connect(function()
	if not velocityLock then return end

	local root = getRoot()
	if not root then return end

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end)

local lastTeleport = 0

function teleportTo(position, faceAt)

	if type(position) ~= "Vector3" then return false end
	if not bypassEnabled then
		local root = getRoot()
		if not root then return false end
		root.CFrame = CFrame.new(position)
		return true
	end

	local root = getRoot()
	if not root then return false end

	local now = tick()
	local delta = now - lastTeleport
	if delta < TELEPORT_COOLDOWN then
		task.wait(TELEPORT_COOLDOWN - delta)
	end
	lastTeleport = tick()

	velocityLock = true

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local cf = CFrame.new(position)
	if faceAt then
		cf = CFrame.lookAt(position, faceAt)
	end

	root.CFrame = cf

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	task.wait(0.04)
	velocityLock = false

	return true
end

--==================================================
-- BANK FLY
--==================================================
local function flyTo(position)

	local root = getRoot()
	if not root then return false end

	velocityLock = true

	local distance = (root.Position - position).Magnitude
	local duration = math.max(distance / speed, 0.1)

	local tween = TweenService:Create(
		root,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{CFrame = CFrame.new(position)}
	)

	tween:Play()

	while flying do
		if tween.PlaybackState ~= Enum.PlaybackState.Playing then break end
		task.wait()
	end

	velocityLock = false

	if not flying then
		tween:Cancel()
		return false
	end

	return true
end

function startBankRun()

	if flying then return end

	if not point1 or not point2 then
		warn("Сначала установи Point 1 и Point 2")
		bankRunEnabled = false
		return
	end

	flying = true

	if not flyTo(point1) or not flying then
		flying = false
		return
	end

	task.wait(0.2)

	if not flyTo(point2) or not flying then
		flying = false
		return
	end

	flying = false
	bankRunEnabled = false
end

--==================================================
-- AIM ASSIST
--==================================================
local function getClosestPlayer()

	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	local myRoot = getRoot()
	if not myRoot then return nil end

	local closest = nil
	local shortest = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then

			local character = targetPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local head = character and character:FindFirstChild("Head")

			if humanoid and humanoid.Health > 0 and root and head then

				if (myRoot.Position - root.Position).Magnitude <= AIM_DISTANCE then

					local position, visible = Camera:WorldToViewportPoint(head.Position)

					if visible and position.Z > 0 then
						local screenPos = Vector2.new(position.X, position.Y)
						local distFromCenter = (screenPos - center).Magnitude

						if distFromCenter <= aimRadius and distFromCenter < shortest then
							shortest = distFromCenter
							closest = head
						end
					end
				end
			end
		end
	end

	return closest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		ctrlHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		ctrlHeld = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not heheEnabled or not ctrlHeld then return end

	local target = getClosestPlayer()
	if target then
		local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
		Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AIM_STRENGTH)
	end
end)

--==================================================
-- FARM LOGIC
--==================================================

local function firePrompt(prompt)
	if not prompt or not prompt.Parent then return end

	if typeof(fireproximityprompt) == "function" then
		pcall(fireproximityprompt, prompt)
		return
	end

	pcall(function()
		prompt:InputHoldBegin()
		task.wait(prompt.HoldDuration > 0 and prompt.HoldDuration or 0.05)
		prompt:InputHoldEnd()
	end)
end

local ROBBERY_KEYWORDS = {
	"bank", "jewel", "museum", "cargo", "train", "plane",
	"casino", "power", "store", "tomb", "mansion", "gas",
	"donut", "safe", "rob", "vault", "register"
}

local function nameMatches(name)
	name = name:lower()
	for _, kw in ipairs(ROBBERY_KEYWORDS) do
		if name:find(kw) then return true end
	end
	return false
end

-- ищем ограбления: по ActionText/ObjectText промпта, а также по имени модели-родителя
local function findRobberyPrompts()

	local list = {}

	for _, obj in ipairs(workspace:GetDescendants()) do

		if obj:IsA("ProximityPrompt") and obj.Enabled then

			local action = (obj.ActionText or ""):lower()
			local object = (obj.ObjectText or ""):lower()

			local matched = action:find("rob") or object:find("rob")

			if not matched then
				local node = obj
				for _ = 1, 6 do
					node = node.Parent
					if not node or node == workspace then break end
					if nameMatches(node.Name) then matched = true break end
				end
			end

			if matched then
				table.insert(list, obj)
			end
		end
	end

	return list
end

local function findRobberyClicks()

	local list = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ClickDetector") then
			local node = obj
			local matched = false
			for _ = 1, 6 do
				node = node.Parent
				if not node or node == workspace then break end
				if nameMatches(node.Name) then matched = true break end
			end
			if matched then table.insert(list, obj) end
		end
	end

	return list
end

local function findCash()
	local list = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = obj.Name:lower()
			if n:find("cash") or n:find("money") then
				table.insert(list, obj)
			end
		end
	end
	return list
end

local function findArrestTarget()

	local myRoot = getRoot()
	if not myRoot then return nil end

	local best, bestDist = nil, math.huge

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local root = other.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (myRoot.Position - root.Position).Magnitude
				if dist <= farmRadius and dist < bestDist then
					for _, d in ipairs(other.Character:GetDescendants()) do
						if d:IsA("ProximityPrompt") and d.Enabled and d.Name:lower():find("arrest") then
							bestDist = dist
							best = { position = root.Position, prompt = d }
							break
						end
					end
				end
			end
		end
	end

	return best
end

-- JAIL DETECTION (для автопобега)
local cachedJail = nil

local function findJail()
	if cachedJail and cachedJail.Parent then return cachedJail end

	for _, obj in ipairs(workspace:GetChildren()) do
		local n = obj.Name:lower()
		if n:find("jail") or n:find("prison") or n:find("cell") then
			cachedJail = obj
			return obj
		end
	end

	return nil
end

local function getEscapePosition()

	if escapePoint then return escapePoint end

	local jail = findJail()
	if jail then
		local ok, cf, size = pcall(function()
			return jail:GetBoundingBox()
		end)
		if ok and cf then
			return cf.Position + Vector3.new(size.X / 2 + 50, 60, size.Z / 2 + 50)
		end
	end

	return nil
end

-- AUTO ESCAPE
task.spawn(function()
	while true do
		if autoEscape and isPrisoner() then
			local pos = getEscapePosition()
			local root = getRoot()

			if pos and root and (root.Position - pos).Magnitude > 30 then
				setStatus("Escape...")
				teleportTo(pos)
			end
		end
		task.wait(0.5)
	end
end)

-- AUTO ROB
task.spawn(function()
	while true do
		if autoRob then

			local prompts = findRobberyPrompts()

			for _, prompt in ipairs(prompts) do
				if not autoRob then break end

				local part = prompt.Parent
				if part and part:IsA("BasePart") then
					setStatus("Rob: " .. part.Name)
					teleportTo(part.Position + Vector3.new(0, 3, 0))
					task.wait(0.15)
					firePrompt(prompt)
					task.wait(0.35)
				end
			end

			-- если промптов нет — пробуем клики
			if #prompts == 0 then
				for _, cd in ipairs(findRobberyClicks()) do
					if not autoRob then break end
					local part = cd.Parent
					if part and part:IsA("BasePart") then
						teleportTo(part.Position + Vector3.new(0, 3, 0))
						task.wait(0.15)
						if typeof(fireclickdetector) == "function" then
							pcall(fireclickdetector, cd)
						end
						task.wait(0.3)
					end
				end
			end
		end
		task.wait(0.4)
	end
end)

-- AUTO COLLECT
task.spawn(function()
	while true do
		if autoCollect then
			for _, c in ipairs(findCash()) do
				if not autoCollect then break end
				teleportTo(c.Position + Vector3.new(0, 2, 0))
				task.wait(0.08)
			end
		end
		task.wait(0.3)
	end
end)

-- AUTO ARREST
task.spawn(function()
	while true do
		if autoArrest then
			local target = findArrestTarget()
			if target then
				teleportTo(target.position + Vector3.new(0, 1, 0))
				task.wait(0.1)
				firePrompt(target.prompt)
			end
		end
		task.wait(0.25)
	end
end)

--==================================================
-- ESP
--==================================================
local espObjects = {}

task.spawn(function()
	while true do

		for plr, obj in pairs(espObjects) do
			if not espEnabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
				obj:Destroy()
				espObjects[plr] = nil
			end
		end

		if espEnabled then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					if not espObjects[plr] then
						local h = Instance.new("Highlight")
						h.Name = "TaseESP"
						h.FillColor = Color3.fromRGB(0, 170, 255)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.FillTransparency = 0.6
						h.Adornee = plr.Character
						h.Parent = plr.Character
						espObjects[plr] = h
					end
				end
			end
		end

		task.wait(0.5)
	end
end)

--==================================================
-- DRAG MENU
--==================================================
local dragging = false
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--==================================================
-- MENU ANIMATION
--==================================================
local function openMenu()
	menuOpen = true
	main.Visible = true
	scale.Scale = 0

	TweenService:Create(
		scale,
		TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = 1}
	):Play()
end

local function closeMenu()
	menuOpen = false

	local tween = TweenService:Create(
		scale,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Scale = 0}
	)

	tween:Play()

	tween.Completed:Connect(function()
		if not menuOpen then
			main.Visible = false
		end
	end)
end

closeBtn.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Insert then
		if menuOpen then closeMenu() else openMenu() end
	end
end)