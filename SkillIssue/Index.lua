--!strict
--# type=mod

--// SkillIssue.Index
--// Written by F_ortitude 2022
--// Module used to interact with SkillIssue™ Skill Rating servers 

-- Contact RafSun#9046 if you have any questions

local VERSION = 3 -- version number for this module

-- !!! DO NOT EDIT ANYTHING UNDER SkillIssue FOLDER, EXCEPT FOR SkillIssue.Config
-- !!! DO NOT EDIT THIS FILE
-- !!! DO NOT EDIT THIS FILE

local HttpService = game:GetService("HttpService")
local ChatService = require(game:GetService("ServerScriptService"):WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

local speaker = ChatService:AddSpeaker("<< SKILLISSUE >>")
speaker:SetExtraData("NameColor", Color3.new(1, 0.333333, 0))

local SkillIssue = script.Parent

local config = require(SkillIssue.Config)
local TOKEN: string = config.TOKEN
local TEAM_1: Team | {Team} = config.TEAM_1
local TEAM_2: Team | {Team} = config.TEAM_2
local getKillsAndDeathsFromPlayer: (Player) -> (number, number) = config.GetKillsAndDeathsFromPlayer
local getGroupIdOfTeam: (Team) -> (number) = config.GetGroupIdOfTeam

local URL = "https://mmr-system.herokuapp.com/api/"
local PLACE_ID = game.PlaceId

local RECENT_DISCONNECT_WINDOW = 3 * 60

type PlayerData = {
	userId: number,
	kills: number,
	deaths: number
}

type RaidResults = {
	teamOneScore: number,
	teamTwoScore: number,
	winningTeam: number,
	duration: number,
	teamOneGroupId: number,
	teamTwoGroupId: number,
	teamOnePlayers: {PlayerData},
	teamTwoPlayers: {PlayerData}
}

local function sendSystemMessage(msg: string, col: Color3?): ()
	if not col then
		col = Color3.new(1,1,1)
	end
	
	if not speaker:IsInChannel("All") then
		speaker:JoinChannel("All")
	end
	
	speaker:SetExtraData("ChatColor", col)
	speaker:SayMessage(msg, "All")
end

local function submitRaid(results: RaidResults): ()
	
	local json = HttpService:JSONEncode({
		token = TOKEN,
		placeId = PLACE_ID,
		teamOneScore = results.teamOneScore,
		teamTwoScore = results.teamTwoScore,
		winningTeam = results.winningTeam,
		duration = results.duration,
		teamOneGroupId = results.teamOneGroupId,
		teamTwoGroupId = results.teamTwoGroupId,
		teamOnePlayers = results.teamOnePlayers,
		teamTwoPlayers = results.teamTwoPlayers
	})
	
	sendSystemMessage("Sending raid results to SI servers...", Color3.new(0, 0.666667, 1))
	
	local response = HttpService:RequestAsync({
		Url = URL .. "raid/submit/",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = json
	})
	
	if response.Success then
		
		sendSystemMessage("Successfully submitted raid results!", Color3.new(0, 1, 0.498039))
		
	else
		
		print(json)
		
		if response.StatusCode >= 500 and response.StatusCode <= 599 then
			
			sendSystemMessage("Failed to connect to SI servers.", Color3.new(1, 0, 0))
			
		else
			
			sendSystemMessage("An error occured while submitting raid results.", Color3.new(1, 0, 0))
			
			error(string.format("Failed to submit raid to SkillIssue servers: HTTP%s: %s", response.StatusCode, 
				response.StatusMessage))
			
		end
		
	end
	
end

local function isPlayerOnTeam(player: Player, team: Team | {Team}): boolean
	if type(team) == "table" then
		if table.find(team, player.Team :: Team) then
			return true
		end
	elseif typeof(team) == "Instance" then
		if player.Team == team then
			return true
		end
	end
	
	return false
end

local function getPlayersFromTeam(team: Team | {Team}): {Player}
	local playerList: {Player} = {}
	for _,player in ipairs(game.Players:GetPlayers()) do
		if isPlayerOnTeam(player, team) then
			table.insert(playerList, player)
		end
	end
	
	return playerList
end

local teamOneRecentlyLeft: {[number]: number} = {}
local teamTwoRecentlyLeft: {[number]: number} = {}
-- [userId] = timestamp

local function onPlayerAdded(player)
	teamOneRecentlyLeft[player.UserId] = nil
	teamTwoRecentlyLeft[player.UserId] = nil
end

for _,player in ipairs(game.Players:GetPlayers()) do task.spawn(onPlayerAdded,player) end
game.Players.PlayerAdded:Connect(onPlayerAdded)

game.Players.PlayerRemoving:Connect(function(player)
	
	if isPlayerOnTeam(player, TEAM_1) then
		teamOneRecentlyLeft[player.UserId] = os.clock()
	elseif isPlayerOnTeam(player, TEAM_2) then
		teamTwoRecentlyLeft[player.UserId] = os.clock()
	end
end)

--------------------------------------------------------------------------
-------------- PUBLIC METHODS

local module = {}

function module.OnRaidFinish(t1Score: number, t2Score: number, winningTeam: number, duration: number)
	if not (winningTeam == 1 or winningTeam == 2) then error("winningTeam must be 1 or 2") end
	
	local groupId1: number
	
	if type(TEAM_1) == "table" then
		groupId1 = getGroupIdOfTeam(TEAM_1[1])
	elseif typeof(TEAM_1) == "Instance" then
		groupId1 = getGroupIdOfTeam(TEAM_1)
	end
	
	local groupId2: number
	
	if type(TEAM_2) == "table" then
		groupId2 = getGroupIdOfTeam(TEAM_2[1])
	elseif typeof(TEAM_2) == "Instance" then
		groupId2 = getGroupIdOfTeam(TEAM_2)
	end
	
	local teamOnePlayers: {PlayerData} = {}
	for _,player in ipairs(getPlayersFromTeam(TEAM_1)) do
		local kills, deaths = getKillsAndDeathsFromPlayer(player)
		table.insert(teamOnePlayers, {
			userId = player.UserId,
			kills = kills,
			deaths = deaths
		})
	end
	for userId,leftTimestamp in pairs(teamOneRecentlyLeft) do
		if os.clock() - leftTimestamp < RECENT_DISCONNECT_WINDOW then
			table.insert(teamOnePlayers, {
				userId = userId,
				kills = 0,
				deaths = 0
			})
		end
	end
	
	local teamTwoPlayers: {PlayerData} = {}
	for _,player in ipairs(getPlayersFromTeam(TEAM_2)) do
		local kills, deaths = getKillsAndDeathsFromPlayer(player)
		table.insert(teamTwoPlayers, {
			userId = player.UserId,
			kills = kills,
			deaths = deaths
		})
	end
	for userId,leftTimestamp in pairs(teamTwoRecentlyLeft) do
		if os.clock() - leftTimestamp < RECENT_DISCONNECT_WINDOW then
			table.insert(teamTwoPlayers, {
				userId = userId,
				kills = 0,
				deaths = 0
			})
		end
	end
	
	local results: RaidResults = {
		teamOneScore = t1Score,
		teamTwoScore = t2Score,
		winningTeam = winningTeam,
		duration = duration,
		teamOneGroupId = groupId1,
		teamTwoGroupId = groupId2,
		teamOnePlayers = teamOnePlayers,
		teamTwoPlayers = teamTwoPlayers
	}
	
	task.spawn(submitRaid, results)
end

return module
