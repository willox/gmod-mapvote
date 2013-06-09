MapVote
=======================

MapVote is a wonderful little GMOD13 addon originally made by [Willox](http://steamcommunity.com/id/Willox303) that allows you to easily invoke a map vote from within any gamemode of your choosing.

It recieved many suggestions and additions in it's [original facepunch thread](http://facepunch.com/showthread.php?t=1268353).

This is my version which takes many of the additions and suggestions, and impliements them in one, simple, configurable addon.

[You can also get this addon through steam workshop!](http://steamcommunity.com/sharedfiles/filedetails/?id=151583504)

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

TTT and Deathrun Setup
=======================

You no longer have to edit any files for MapVote to work with Trouble in Terrorist Town or Deathrun anymore!  It now overrides the default functions for map switching.

*Note: On Deathrun, it still uses the build in RTV, so changing the minimum player count doesn't work*

You can edit the config.txt located in garrysmod/data/mapvote/ to change several settings.  It should look like this by default (if it's empty, just copy this into it):
```JSON
{"RTVPlayerCount":3,"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapPrefixes":{"1":"ttt_"},"MapsBeforeRevote":3,"EnableCooldown":true}
```
* "RTVPlayerCount" is the minimum number of players that need to be online (on TTT) for RTV to work.
* "MapLimit" is the number of maps shown on the vote screen.
* "TimeLimit" is how long the vote is shown for.
* "AllowCurrentMap" true/false to allow a the current map in the map vote list.
* "MapPrefixes" are the prefixes of the maps that should be used in the vote.
* "MapsBeforeRevote" is the number of maps that must be played before a map is in the vote menu again (if EnableCooldown is true)
* "EnableCooldown" is a true/false variable on whether to remove a map from voting for a while after it's played.
* "MapsBeforeRevote" is how many maps before the map is taken off the cooldown list after it's played.

To add more Map Prefixes, do this: 
```JSON
{"RTVPlayerCount":3,"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapPrefixes":{"1":"ttt_","2":"zm_","3":"de_"},"MapsBeforeRevote":3,"EnableCooldown":true}
```

Modifications
=======================
Featuress added made by others:
* RTV Implimentation by [Eccid](http://facepunch.com/member.php?u=536187)
* ULX integration by [Ambro](http://facepunch.com/member.php?u=555824)
* RTV vote delay to end of TTT and Deathrun rounds (Thanks Again, Willox!)

My Feature Additions:
* CoolDown System
* JSON config that auto-generates at garrysmod/data/mapvote/config.txt
* Automatically working with TTT and Deathun

Planned Feature Additions:
* Enable/Disable on RTV delay to round end on TTT and Deathrun
* Config to give extra voting power
