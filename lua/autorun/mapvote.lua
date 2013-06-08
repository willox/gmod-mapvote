MapVote = {}
MapVote.Config = {}

-- CONFIG
    MapVote.Config.Default = {
        MapLimit = 24,
        TimeLimit = 28,
        AllowCurrentMap = false,
        EnableCooldown = true,
        MapsBeforeRevote = 3,
        MapPrefixes = {"ttt_"},
    }
-- CONFIG

hook.Add( "Initialize", "MapVoteConfig", function()
    if not file.Exists( "mapvote", "DATA") then
        file.CreateDir( "mapvote" )
    end
    if file.Exists( "mapvote/config.txt", "DATA" ) then
        MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
    else
        file.Write("mapvote/config.txt", util.TableToJSON(MapVote.Config.Default))
    end
end )

function MapVote.HasExtraVotePower(ply)
	-- Example that gives admins more voting power
	--[[
    if ply:IsAdmin() then
		return true
	end 
    ]]

	return false
end


MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("mapvote/cl_mapvote.lua")

    include("mapvote/sv_mapvote.lua")
    include("mapvote/rtv.lua")
else
    include("mapvote/cl_mapvote.lua")
end
