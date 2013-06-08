MapVote
=======================

MapVote is a wonderful little GMOD13 addon origionally made by [Willox](http://steamcommunity.com/id/Willox303) that allows you to easily invoke a map vote from within any gamemode of your choosing.

It recieved many suggestions and additions in it's [origional facepunch thread](http://facepunch.com/showthread.php?t=1268353).

This is my version which takes many of the additions and suggestions, and impliements them in one, simple, configurable addon.

Usage
=======================

Starting a vote from within lua is rather simple.

```Lua
MapVote.Start(voteLength, allowCurrentMap, mapLimit, mapPrefix)
```
All arguments to this function are optional and the map prefix is acquired from the config, or if it isn't set, gamemode.txt file if available. You can also set up defaults within garrysmod/data/mapvote/config.txt which is generated during the first run.

It is also possible to cancel map votes from within lua with:
```Lua
MapVote.Cancel()
```

You can give players extra voting power in lua/autorun/mapvote.lua with the MapVote.HasExtraVotePower function, and a config will be added at some point.

TTT Setup
=======================
Simply put, you can do this by finding the following code in gamemodes/terrortown/gamemode/init.lua (around line 726)
```Lua
   if switchmap then
      timer.Stop("end2prep")
      timer.Simple(15, game.LoadNextMap)
   elseif ShouldMapSwitch() then
      LANG.Msg("limit_left", {num = rounds_left,
                              time = math.ceil(time_left / 60),
                              mapname = nextmap})
   end
```

and replacing it with
```Lua
   if switchmap then
      timer.Stop("end2prep")
      MapVote.Start(nil, nil, nil, nil)
   elseif ShouldMapSwitch() then
      LANG.Msg("limit_left", {num = rounds_left,
                              time = math.ceil(time_left / 60),
                              mapname = "chosen by a vote"})
   end
```

This will cause a map vote at the end of the round, based on the settings defined in your config.txt

If you plan on using more than one map prefix, you can edit the config.txt.  It look like this by default:
```JSON
{"MapPrefixes":{"1":"ttt_"},"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapsBeforeRevote":3,"EnableCooldown":true}
```
"MapsBeforeRevote" is how many maps before the map is taken off the cooldown list after it's played.

To add more Map Prefixes, do this:
```JSON
{"MapPrefixes":{"1":"ttt_","2":"zm_","3":"de_"},"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapsBeforeRevote":3,"EnableCooldown":true}
```

Modifications
=======================
Featuress added made by others:
* RTV Implimentation by [Eccid](http://facepunch.com/member.php?u=536187)
* ULX integration by [Ambro](http://facepunch.com/member.php?u=555824)

My Feature Additions:
* CoolDown System
* JSON config that auto-generates at garrysmod/data/mapvote/config.txt

Planned Feature Additions:
* Automatically working with TTT
* RTV vote delay to end of TTT rounds (With config enable/disable)
* Config to give extra voting power
