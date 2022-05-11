--# type=mod
--[[

                                                                                                                        
                                                                                                                        
          ((((((((((       (((((                                     (((((((((   *((((((((( (     ((((     (((((((((    
      (((((((((((( ((     ((((  ((   ((       ((            ((   ((((((((((( *((((((((((( ((*     ((((   (((((((((      
     ((((        ((((   ((((( (((( ((((     ((((          (((( (((((        ((((         (((*     (((( ((((             
     ((((((((    (((( (((((   (((( ((((     ((((          (((( ((((((((,    ((((((((     (((*     (((( ((((((((((       
      ,((((((((  ((((((((     (((( ((((     ((((          ((((   (((((((((    (((((((((  (((*     (((( ((((((((((       
            (((( (((((((/     (((( ((((     ((((          ((((         (((/        ((((  (((/     (((( ((((             
    (((((((((((  (((( ((((    (((( (((((((( (((((((       (((( (((((((((((  ((((((((((   ((((((((((((  ((((((((((       
    (//////      (///  (////  (/// (/////// (//////       (/// (/////*      (/////,          *///      (/////////       
                                                                                                                        

	Skill Issue
An automated skill rating system for clans

 - F_ortitude, RafSun#9046

---------------------------------------------------
---------------------- Basic Setup

1. Move the SkillIssue folder under ServerScriptService

2. Change the settings in the SkillIssue.Config ModuleScript
	- Set TOKEN to the token sent to your DMs
	- Set TEAM_1 to the Team object of the base's defending team
	- Set TEAM_2 to the Team object of the base's raiding team
	- Change GetKillsAndDeathsFromPlayer function to return the kills and deaths stats from a given player. Use 
	  leaderstats if your base uses the default roblox leaderboard logic to store stats, or change this if you use a
	  custom way to manage stats.
	- Change GetGroupIdOfTeam function to return the group id of the players who belong to a given team. This is managed
	  by the SkillIssue.Group ModuleScript already, but change this if your base has a different way to get the group id
	  of a team
	  
3. Edit your game's objective/terminal scripts to call the SkillIssue.Index.OnRaidFinish() function when the raid ends.

Example:                                                                                                              ]]

local SkillIssueModule = require(game.ServerScriptService.SkillIssue.Index)

local team1Score = 100
local team2Score = 100
local duration = 500

local function endRaid(winningTeam)
	
	SkillIssueModule.OnRaidFinish(
		team1Score, -- This is the score of TEAM_1. If the defenders don't have a score, then set this to 0
		team2Score, -- This is the score of TEAM_2. If the raiders don't have a score, then set this to 0
		winningTeam, -- This determins the winner of the raid. 1 for TEAM_1, 2 for TEAM_2
		duration -- This is how long the raid lasted in seconds
	)
	
end

--[[

DM RafSun#9046 on discord if you have any questions

DO NOT EDIT the SkillIssue.Index ModuleScript


]]
