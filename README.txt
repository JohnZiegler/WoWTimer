Follow me @Sadrunslive
Add the WoW_Speedrun_Timer folder to your Addons folder.
To join in further, join us at the WoW Speedrun Discord: https://discord.gg/KMkpFVt
Version: 0.1

Currently a leveling timer has been implemented. More information will be added here as it is devolped.

Currently no translations are available. They will be introduced moving forward.

The available slash commands:

/timerGoal (goal level)
Will display the current goal level, if you wish to change the level goal, you can set that by adding the desired level (Ex: "/timeGoal 20" would set my goal level to 20).

/timerReady
Will begin loading the timer, this MUST be done before runs if they wish to be recognized.

/timerStop
Will stop the timer.

/timerCurrentTime
Displays the current "split", and where you are at in the run.

Known issues:
Entering instances will destory the timer. Possible fix is to move time collection to global variables that persist through load.
You are able to change the goal level mid run. Simple fix, just not implemented in this pull.