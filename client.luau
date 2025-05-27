local AdminGui = script.Parent
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
-- Gui Stuff
local ToggleAdminPanelButton = AdminGui:WaitForChild("Button")
local MainFrame = AdminGui:WaitForChild("MainFrame")
local Box = MainFrame:WaitForChild("Box")
local PlayerNameTextBox = Box:WaitForChild("Player")
local AttributeTextBox = Box:WaitForChild("Attribute")
local BanButton = Box:WaitForChild("Ban")
local KickButton = Box:WaitForChild("Kick")
local JumpButton = Box:WaitForChild("Jump")
local SpeedButton = Box:WaitForChild("Speed")
local TeleportButton = Box:WaitForChild("Teleport")
-- Remotes
local BanPlayerEvent = ReplicatedStorage:WaitForChild("BanPlayerEvent")
local KickPlayerEvent = ReplicatedStorage:WaitForChild("KickPlayerEvent")
local AdminActionTeleportEvent = ReplicatedStorage:WaitForChild("AdminActionTeleportEvent")
local AdminActionSetSpeedEvent = ReplicatedStorage:WaitForChild("AdminActionSetSpeedEvent")
local AdminActionSetJumpEvent = ReplicatedStorage:WaitForChild("AdminActionSetJumpEvent")


local frameOpened = false
MainFrame.Visible = false 
ToggleAdminPanelButton.Text = "Open Panel"
ToggleAdminPanelButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleAdminPanelButton.MouseButton1Click:Connect(function()
	frameOpened = not frameOpened
	MainFrame.Visible = frameOpened
	if frameOpened then
		ToggleAdminPanelButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		ToggleAdminPanelButton.Text = "Close Panel"
	else
		ToggleAdminPanelButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		ToggleAdminPanelButton.Text = "Open Panel"
	end
end)


BanButton.MouseButton1Click:Connect(function()
	local targetPlayerName = PlayerNameTextBox.Text
	local attributeText = AttributeTextBox.Text
	local banDurationSeconds = tonumber(attributeText)
	local reason = "Banned by admin."
	if not banDurationSeconds then
		warn("Client: Invalid ban duration input: '" .. attributeText .. "'. Using default 1 day (86400s).")
        banDurationSeconds = 86400 
	end
	if targetPlayerName and targetPlayerName ~= "" then
		BanPlayerEvent:FireServer(targetPlayerName, reason, banDurationSeconds)
		PlayerNameTextBox.Text = "" -- Clear after use
		AttributeTextBox.Text = "" -- Clear after use
	else
		warn("Client: Player name for ban is empty.")
	end
end)


KickButton.MouseButton1Click:Connect(function()
	local targetPlayerName = PlayerNameTextBox.Text
	local reason = AttributeTextBox.Text -- Allow reason from attribute box, or default
	if reason == "" then reason = "Kicked by admin." end
	
	if targetPlayerName and targetPlayerName ~= "" then
		KickPlayerEvent:FireServer(targetPlayerName, reason)
		PlayerNameTextBox.Text = "" 
		AttributeTextBox.Text = ""
	else
		warn("Client: Player name for kick is empty.")
	end
end)


TeleportButton.MouseButton1Click:Connect(function()
	local targetPlayerName = PlayerNameTextBox.Text
	local attributeText = AttributeTextBox.Text -- Expected format: "x,y,z"
	if targetPlayerName and targetPlayerName ~= "" and attributeText and attributeText ~= "" then
		AdminActionTeleportEvent:FireServer(targetPlayerName, attributeText)
		-- PlayerNameTextBox.Text = "" -- Keep player name for multiple actions
		AttributeTextBox.Text = ""
	else
		warn("Client: Player name or coordinates for teleport are empty.")
	end
end)


SpeedButton.MouseButton1Click:Connect(function()
	local targetPlayerName = PlayerNameTextBox.Text
	local attributeValue = tonumber(AttributeTextBox.Text)
	if targetPlayerName and targetPlayerName ~= "" and attributeValue then
		AdminActionSetSpeedEvent:FireServer(targetPlayerName, attributeValue)
		-- PlayerNameTextBox.Text = ""
		AttributeTextBox.Text = ""
	elseif not attributeValue then
        warn("Client: Invalid speed value. Not a number: '" .. AttributeTextBox.Text .. "'")
    else
		warn("Client: Player name for speed change is empty.")
	end
end)


JumpButton.MouseButton1Click:Connect(function()
	local targetPlayerName = PlayerNameTextBox.Text
	local attributeValue = tonumber(AttributeTextBox.Text)
	if targetPlayerName and targetPlayerName ~= "" and attributeValue then
		AdminActionSetJumpEvent:FireServer(targetPlayerName, attributeValue)
		-- PlayerNameTextBox.Text = ""
		AttributeTextBox.Text = ""
	elseif not attributeValue then
        warn("Client: Invalid jump value. Not a number: '" .. AttributeTextBox.Text .. "'")
    else
		warn("Client: Player name for jump change is empty.")
	end
end)
print("AdminClientScript initialized for " .. LocalPlayer.Name .. ". GUI Name: " .. AdminGui.Name)

