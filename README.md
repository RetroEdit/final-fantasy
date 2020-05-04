# final-fantasy
Final Fantasy-related scripts. I hope to do a tool-assisted speedrun of some Final Fantasy games in the future.

## Final Fantasy I GBA
To use the scripts, donwload [BizHawk](https://github.com/TASVideos/BizHawk) and play using the mGBA core. Only BizHawk version 2.4.1 or later is supported. Older versions of BizHawk do not necessarily support the same functions and may have bugs (e.g. the mGBA core distributed with BizHawk 2.4 has a bug where the game crashes if the in-game menu is opened).

Done:
- [15-puzzle minigame overlay](https://github.com/RetroEdit/final-fantasy/blob/master/ff1_15_puzzle.lua): puzzle tile coords and prize prediction

Plans:
- Battle overlay: initiative in the current round, possibly action result prediction/recommendations
- Map overlay: tile regions (?)/entrance annotations, spiked tiles, chest contents, NPC movement behavior, encounter avoidance

The Lua scripts are a starting place to ensure game mechanics are correctly understood. Anything more sophisticated/long term will not be calculated on the spot with Lua scripts, but instead fed into a more efficient analyzer.
