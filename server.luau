local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerDataStore = DataStoreService:GetDataStore("AdminSystemBanData")

-- Remotes
local BanPlayerEvent = ReplicatedStorage:WaitForChild("BanPlayerEvent")
local KickPlayerEvent = ReplicatedStorage:WaitForChild("KickPlayerEvent")
local AdminActionTeleportEvent = ReplicatedStorage:WaitForChild("AdminActionTeleportEvent")
local AdminActionSetSpeedEvent = ReplicatedStorage:WaitForChild("AdminActionSetSpeedEvent")
local AdminActionSetJumpEvent = ReplicatedStorage:WaitForChild("AdminActionSetJumpEvent")

local adminList = {
	"0ASLAN_dev0",
}

local function isPlayerAdmin(player)
	if not player then return false end
	for _, adminName in adminList do
		if player.Name == adminName then
			return true
		end
	end
	return false
end


BanPlayerEvent.OnServerEvent:Connect(function(requestingPlayer, targetPlayerName, reason, durationInSeconds)
	if not isPlayerAdmin(requestingPlayer) then
		warn(requestingPlayer.Name .. " (not an admin) attempted to ban " .. targetPlayerName)
		return
	end
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if targetPlayer then
		if targetPlayer == requestingPlayer then
			print(requestingPlayer.Name .. " attempted to ban themselves.")
			return
		end
		local userId = targetPlayer.UserId
		local banDataKey = "Ban_" .. userId
		local banEndTime = os.time() + (tonumber(durationInSeconds) or 86400) -- Default to 1 day if no duration provided
		local banData = {
			Banned = true,
			BanEndTime = banEndTime,
			Reason = reason or "No reason provided.",
			BannedBy = requestingPlayer.Name
		}		
		local success, err = pcall(function()
			playerDataStore:SetAsync(banDataKey, banData)
		end)
		if success then
			local kickMessage = string.format("You have been banned. Reason: %s. Unbanned on: %s (server time).", 
			                                  banData.Reason, os.date("!*t", banData.BanEndTime))
			targetPlayer:Kick(kickMessage)
			print(targetPlayer.Name .. " banned by " .. requestingPlayer.Name .. " for " .. (durationInSeconds or "default") .. " seconds. Reason: " .. banData.Reason)
		else
			warn("Failed to set ban data for player " .. targetPlayer.Name .. ": " .. err)
		end
	else
		warn("Admin " .. requestingPlayer.Name .. " tried to ban non-existent or invalid player: " .. targetPlayerName)
	end
end)


KickPlayerEvent.OnServerEvent:Connect(function(requestingPlayer, targetPlayerName, reason)
	if not isPlayerAdmin(requestingPlayer) then
		warn(requestingPlayer.Name .. " (not an admin) attempted to kick " .. targetPlayerName)
		return
	end
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if targetPlayer then
		if targetPlayer == requestingPlayer then
			print(requestingPlayer.Name .. " attempted to kick themselves.")
			return
		end
		targetPlayer:Kick(reason or "You have been kicked from the game by an admin.")
		print(targetPlayer.Name .. " kicked by " .. requestingPlayer.Name .. ". Reason: " .. (reason or "N/A"))
	else
		warn("Admin " .. requestingPlayer.Name .. " tried to kick non-existent or invalid player: " .. targetPlayerName)
	end
end)


AdminActionTeleportEvent.OnServerEvent:Connect(function(requestingPlayer, targetPlayerName, attributeText)
	if not isPlayerAdmin(requestingPlayer) then
		warn(requestingPlayer.Name .. " (not an admin) attempted to teleport " .. targetPlayerName)
		return
	end
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if targetPlayer and targetPlayer.Character then
		local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			local coords = {}
			local successParse = true
			for v_str in string.gmatch(attributeText, "([^,]+)") do
				local num = tonumber(v_str)
				if num then
					table.insert(coords, num)
				else
					successParse = false
					break
				end
			end
			if successParse and #coords == 3 then
				humanoidRootPart.CFrame = CFrame.new(coords[1], coords[2], coords[3])
				print(requestingPlayer.Name .. " teleported " .. targetPlayerName .. " to " .. attributeText)
			else
				warn("Invalid coordinate format for teleport by " .. requestingPlayer.Name .. ". Expected x,y,z. Got: "..attributeText)
			end
		else
			warn("Admin " .. requestingPlayer.Name .. " tried to teleport player " .. targetPlayerName .. " but HumanoidRootPart not found.")
		end
	else
		warn("Admin " .. requestingPlayer.Name .. " tried to teleport non-existent player or player without character: " .. targetPlayerName)
	end
end)


AdminActionSetSpeedEvent.OnServerEvent:Connect(function(requestingPlayer, targetPlayerName, speedValue)
	if not isPlayerAdmin(requestingPlayer) then
		warn(requestingPlayer.Name .. " (not an admin) attempted to set speed for " .. targetPlayerName)
		return
	end
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if targetPlayer and targetPlayer.Character then
		local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local speed = tonumber(speedValue)
			if speed and speed >= 0 then
				humanoid.WalkSpeed = speed
				print(requestingPlayer.Name .. " set " .. targetPlayerName .. "'s speed to " .. speed)
			else
				warn("Invalid speed value (" .. tostring(speedValue) .. ") for " .. targetPlayerName .. " by " .. requestingPlayer.Name)
			end
		else
			warn("Admin " .. requestingPlayer.Name .. " tried to set speed for player " .. targetPlayerName .. " but Humanoid not found.")
		end
	else
		warn("Admin " .. requestingPlayer.Name .. " tried to set speed for non-existent player or player without character: " .. targetPlayerName)
	end
end)


AdminActionSetJumpEvent.OnServerEvent:Connect(function(requestingPlayer, targetPlayerName, jumpValue)
	if not isPlayerAdmin(requestingPlayer) then
		warn(requestingPlayer.Name .. " (not an admin) attempted to set jump power for " .. targetPlayerName)
		return
	end
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if targetPlayer and targetPlayer.Character then
		local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local jump = tonumber(jumpValue)
			if jump and jump >= 0 then
				humanoid.JumpHeight = jump
				print(requestingPlayer.Name .. " set " .. targetPlayerName .. "'s jump power to " .. jump)
			else
				warn("Invalid jump value (" .. tostring(jumpValue) .. ") for " .. targetPlayerName .. " by " .. requestingPlayer.Name)
			end
		else
			warn("Admin " .. requestingPlayer.Name .. " tried to set jump for player " .. targetPlayerName .. " but Humanoid not found.")
		end
	else
		warn("Admin " .. requestingPlayer.Name .. " tried to set jump for non-existent player or player without character: " .. targetPlayerName)
	end
end)



local function setupAdminStatusForPlayer(player)
	if not player or not player:IsA("Player") then return end
	local userId = player.UserId
	local banDataKey = "Ban_" .. userId
	local isBanned = false
	local success, banDataResult = pcall(function()
		return playerDataStore:GetAsync(banDataKey)
	end)
	if success then
		local banData = banDataResult
		if banData and banData.Banned then
			if banData.BanEndTime and os.time() < banData.BanEndTime then
				local kickMessage = string.format("You are currently banned. Reason: %s. Unbanned on: %s (server time).", 
				                                  banData.Reason or "No reason provided.", os.date("!*t", banData.BanEndTime))
				player:Kick(kickMessage)
				isBanned = true
			elseif banData.BanEndTime and os.time() >= banData.BanEndTime then
				local removedSuccess, removeError = pcall(function() playerDataStore:RemoveAsync(banDataKey) end)
				if removedSuccess then 
					print("Expired ban record removed for " .. player.Name)
				else 
					warn("Failed to remove expired ban record for " .. player.Name .. ": " .. removeError) 
				end
			elseif not banData.BanEndTime then 
				player:Kick(string.format("You are currently banned. Reason: %s.", banData.Reason or "No reason provided."))
				isBanned = true
            end
		end
	else
		warn("Failed to check ban status for " .. player.Name .. " on join: " .. tostring(banDataResult)) -- banDataResult is error message here
	end
	if isBanned then
		return -- Don't proceed to GUI setup if player is kicked
	end
	local playerGui = player:WaitForChild("PlayerGui")
	local adminGui = playerGui:WaitForChild("AdminGui", 10) -- Wait up to 10 seconds for AdminGui to fully load
	if not adminGui then
		warn("AdminServerScript: AdminGui not found in PlayerGui for " .. player.Name .. " after waiting.")
		return
	end
	if isPlayerAdmin(player) then
		adminGui.Enabled = true
		adminGui.ResetOnSpawn = false -- Keep GUI for admins on respawn
		print("Admin GUI enabled for admin: " .. player.Name)
	else
		adminGui.Enabled = false
		adminGui.ResetOnSpawn = true
		print("Admin GUI explicitly disabled for non-admin: " .. player.Name)
	end
end


Players.PlayerAdded:Connect(function(player)
	setupAdminStatusForPlayer(player)
end)
for _, player in Players:GetPlayers() do
	if player and player.Parent then 
		task.spawn(function()
			if player.Character and player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("AdminGui") then
				setupAdminStatusForPlayer(player)
			else
				local charConnection
				charConnection = player.CharacterAdded:Connect(function(character)
					task.wait(0.1) 
					setupAdminStatusForPlayer(player)
					if charConnection then 
						charConnection:Disconnect()
					end
				end)
				if player.Character and not (player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("AdminGui")) then
					setupAdminStatusForPlayer(player)
				end
			end
		end)
	end
end


print("AdminServerScript loaded and running.")

