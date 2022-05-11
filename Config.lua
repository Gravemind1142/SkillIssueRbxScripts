--# type=mod

--// SkillIssue.Config
--// Configuration file for submitting raids via the Index module

-- !!! DO NOT EDIT ANYTHING UNDER SkillIssue FOLDER, EXCEPT FOR THIS FILE
-- !!! ONLY EDIT THIS FILE
-- !!! ONLY EDIT THIS FILE

local GroupModule = require(script.Parent.Group)

local module = {
	-- !!! Change these settings here
	
	TOKEN = "YOUR_TOKEN_GOES_HERE", -- Your group's SkillIssue token
	TEAM_1 = game.Teams.Defenders, -- Defending team or who ever owns the base
	TEAM_2 = game.Teams.Hostiles, -- Raiding team or who ever is visiting the base
	
	-- Parameters: player
	-- Returns: kills, deaths
	GetKillsAndDeathsFromPlayer = function(player)
		-- Replace logic here if not using leaderstats
		
		local ls = player:FindFirstChild("leaderstats")
		
		local kills = 0
		local deaths = 0
		
		if ls then
			local killsVal = ls:FindFirstChild("Kills") -- change this if the kills stat is called something else
			if killsVal then
				kills = killsVal.Value
			end
			local deathsVal = ls:FindFirstChild("Deaths") -- change this if the kills stat is called something else
			if deathsVal then
				deaths = deathsVal.Value
			end
		end
		
		return kills, deaths
	end,
	
	-- Parameters: team
	-- Returns: group id representing team
	GetGroupIdOfTeam = function(team)
		-- Replace logic here if you have your own way to determine which group is raiding/defending
		
		local players = team:GetPlayers()
		return GroupModule.GetMostCommonGroupIdFromPlayerList(players)
	end,
}

return module
