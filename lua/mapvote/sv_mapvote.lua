util.AddNetworkString("RAM_MapVoteStart")
util.AddNetworkString("RAM_MapVoteUpdate")
util.AddNetworkString("RAM_MapVoteCancel")
util.AddNetworkString("RTV_Delay")

MapVote.Continued = false

net.Receive("RAM_MapVoteUpdate", function(len, ply)
    if(MapVote.Allow) then
        if(IsValid(ply)) then
            local update_type = net.ReadUInt(3)
            
            if(update_type == MapVote.UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)
                
                if(MapVote.CurrentMaps[map_id]) then
                    MapVote.Votes[ply:SteamID()] = map_id
                    
                    net.Start("RAM_MapVoteUpdate")
                        net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()
                end
            end
        end
    end
end)

if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
    recentmaps = util.JSONToTable(file.Read("mapvote/recentmaps.txt", "DATA"))
else
    recentmaps = {}
end

if file.Exists( "mapvote/config.txt", "DATA" ) then
    MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
else
    MapVote.Config = {}
end

function CoolDownDoStuff()
    cooldownnum = MapVote.Config.MapsBeforeRevote or 3

    if table.getn(recentmaps) == cooldownnum then 
        table.remove(recentmaps)
    end

    local curmap = game.GetMap():lower()..".bsp"

    if not table.HasValue(recentmaps, curmap) then
        table.insert(recentmaps, 1, curmap)
    end

    file.Write("mapvote/recentmaps.txt", util.TableToJSON(recentmaps))
end

function MapVote.Start(length, current, limit, prefix, callback)
    current = current or MapVote.Config.AllowCurrentMap or false
    length = length or MapVote.Config.TimeLimit or 28
    limit = limit or MapVote.Config.MapLimit or 24
    cooldown = MapVote.Config.EnableCooldown or MapVote.Config.EnableCooldown == nil and true
    prefix = prefix or MapVote.Config.MapPrefixes
    autoGamemode = autoGamemode or MapVote.Config.AutoGamemode or MapVote.Config.AutoGamemode == nil and true

    local is_expression = false

    if not prefix then
        local info = file.Read(GAMEMODE.Folder.."/"..GAMEMODE.FolderName..".txt", "GAME")

        if(info) then
            local info = util.KeyValuesToTable(info)
            prefix = info.maps
        else
            error("MapVote Prefix can not be loaded from gamemode")
        end

        is_expression = true
    else
        if prefix and type(prefix) ~= "table" then
            prefix = {prefix}
        end
    end
    
    local maps = file.Find("maps/*.bsp", "GAME")
    
    local vote_maps = {}
    
    local amt = 0

    for k, map in RandomPairs(maps) do
        local mapstr = map:sub(1, -5):lower()
        if(not current and game.GetMap():lower()..".bsp" == map) then continue end
        if(cooldown and table.HasValue(recentmaps, map)) then continue end

        if is_expression then
            if(string.find(map, prefix)) then -- This might work (from gamemode.txt)
                vote_maps[#vote_maps + 1] = map:sub(1, -5)
                amt = amt + 1
            end
        else
            for k, v in pairs(prefix) do
                if string.find(map, "^"..v) then
                    vote_maps[#vote_maps + 1] = map:sub(1, -5)
                    amt = amt + 1
                    break
                end
            end
        end
        
        if(limit and amt >= limit) then break end
    end
    
    net.Start("RAM_MapVoteStart")
        net.WriteUInt(#vote_maps, 32)
        
        for i = 1, #vote_maps do
            net.WriteString(vote_maps[i])
        end
        
        net.WriteUInt(length, 32)
    net.Broadcast()
    
    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}
    
    timer.Create("RAM_MapVote", length, 1, function()
        MapVote.Allow = false
        local map_results = {}
        
        for k, v in pairs(MapVote.Votes) do
            if(not map_results[v]) then
                map_results[v] = 0
            end
            
            for k2, v2 in pairs(player.GetAll()) do
                if(v2:SteamID() == k) then
                    if(MapVote.HasExtraVotePower(v2)) then
                        map_results[v] = map_results[v] + 2
                    else
                        map_results[v] = map_results[v] + 1
                    end
                end
            end
            
        end
        
        CoolDownDoStuff()

        local winner = table.GetWinningKey(map_results) or 1
        
        net.Start("RAM_MapVoteUpdate")
            net.WriteUInt(MapVote.UPDATE_WIN, 3)
            
            net.WriteUInt(winner, 32)
        net.Broadcast()
        
        local map = MapVote.CurrentMaps[winner]

        local gamemode = nil

        if (autoGamemode) then
            -- check if map matches a gamemode's map pattern
            for k, gm in pairs(engine.GetGamemodes()) do
                -- ignore empty patterns
                if (gm.maps and gm.maps ~= "") then
                    -- patterns are separated by "|"
                    for k2, pattern in pairs(string.Split(gm.maps, "|")) do
                        if (string.match(map, pattern)) then
                            gamemode = gm.name
                            break
                        end
                    end
                end
            end
        else
            print("not enabled")
        end
        
        timer.Simple(4, function()
            if (hook.Run("MapVoteChange", map) ~= false) then
                if (callback) then
                    callback(map)
                else
                    -- if map requires another gamemode then switch to it
                    if (gamemode and gamemode ~= engine.ActiveGamemode()) then
                        RunConsoleCommand("gamemode", gamemode)
                    end
                    RunConsoleCommand("changelevel", map)
                end
            end
        end)
    end)
end

hook.Add( "Shutdown", "RemoveRecentMaps", function()
        if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
            file.Delete( "mapvote/recentmaps.txt" )
        end
end )

function MapVote.Cancel()
    if MapVote.Allow then
        MapVote.Allow = false

        net.Start("RAM_MapVoteCancel")
        net.Broadcast()

        timer.Destroy("RAM_MapVote")
    end
end
