local startTimeIGT = GetSessionTime(); --Initializes the In Game Timer (IGT) start to the current session timer (Might change to 0)
local startTimeRT = GetSessionTime(); --Initializes the Real Time (RT) start time to the current session timer (Might change to 0)
local endTime = 0; --Initializes the end time variable to 0

local accumTimeIGT = 0; --Initializes the accumulating time variable that is used when the player enters a loading screen. Should not include reloads and moving into instances.
--local accumTimeRT = 0; --Initializes a back up variable in case a real time one is needed, see above variable

local timerRunning = false; --Initializes the boolean variable to determine if the timmer is currently running or not
local playerLoaded = false; --Stores if the character has loaded into the game for the first time

local goalLevel = 10; --Initializes the variable that will hold the goal level. (Should be made into carryover var?)

local eventFrame, events = CreateFrame("FRAME"), {}; --Creates the frame in which all of the addon will be taking place

local WOW_LOWEST_LEVEL = 1; --Initializes the lowest level attainable by the player, may change in future updates
local WOW_HIGHEST_LEVEL = 110; --Initializes the highest level attainable by the player, will change as expansions release.	
	
	----------------------------
	-- Events and World Stuff --
	----------------------------
	--EVENT THAT WILL DETERMINE ENDING TIME--
	function events:UNIT_LEVEL(playerLevel, ...) --event will fire when the player unit levels (args: "player")
		if playerLevel == "player" then
			if UnitLevel("player") == tonumber(goalLevel) then --The number here decides at which level the run will stop. Must be a number between 2-110 inclusive
				endTime = GetSessionTime(); --Gets the current time the level is acieved and stores it in the end time IGT variable.
			
			
				print("Congratulations! Your time:")
			
				calculateRealTime(endTime, startTimeRT, ...);
				calculateInGameTime(endTime, startTimeIGT, ...);
			
				timerRunning = false;
				startTimeIGT = GetSessionTime();
				startTimeRT = GetSessionTime();
			
			else
				print("Current split for level", UnitLevel("player"), "of", goalLevel)
				SlashCmdList.TIMERCURRENTTIME()
			end
		end
	end
		
	-- when a player goes to enter an instance
		-- trigger the loading screen event
			-- when this event triggers, grab the current split time in seconds, store to a holder variable
		
		-- trigger the loading screen ending event
			-- when this event trigger, restart the current sessiontimer, but add the accum split time to checks.
	
	
	
	function events:LOADING_SCREEN_ENABLED(...) --should fire when the loading screen is enabled
		--accumTimeIGT = difftime(endTime, startTimeIGT) + accumTimeIGT
	end
	
	function events:LOADING_SCREEN_DISABLED(...) --should fire when the loading screen is enabled
		--startTimeIGT = GetSessionTime();
	end

	--EVENTS THAT WILL START THE TIMER --
	function events:ACTIONBAR_SHOWGRID(...) --This event fires any time an actionbar slot has been changed. This will not change is spell x is placed in the same slot as a spell x, but will change if spell x is removed
		startTimer("ACTIONBAR_SHOWGRID")

	end

	function events:ADDON_LOADED(addon) --Event fires when the "Collections" tab is opened, meaning a player would begin the process of getting their heirlooms from this event
		if addon == "Blizzard_Collections" then --Specifies only the Blizzard_Collections addon
			startTimer("COLLECTION_LOADED")
		end
	end
	
	function events:PLAYER_STARTED_MOVING(...) --The event will trigger when the player character moves
		startTimer("STARTED_MOVING")		
	end
	
	function events:UNIT_SPELLCAST_START(isPlayer, ...) --Event will trigger when the player begins casting a spell with a channel time.
		if isPlayer == "player" then --If the first argument (who casts the spell) is the player
			startTimer("UNIT_COMBAT") --send a start timer check with the argument "UNIT_COMBAT"
		end
	end
	
	function events:UNIT_SPELLCAST_SENT(isPlayer, ...) --Event will trigger when a spellcast request has been sent
		if isPlayer == "player" then	--if the caster is the player
			startTimer("UNIT_SPELL_CAST") --send a start timer check with the argument "UNIT_SPELL_CAST"
		end
	end
	
	function events:QUEST_ACCEPTED(...) --event will trigger when a quest is accepted
		startTimer("QUEST_ACCEPTED")
	end
	
	
	----------------------
	-- Actual Functions --
	----------------------
	function calculateRealTime(endTime, startTimeRT, ...) --Function used to calculate real time how long the run took
		local timeTaken = difftime(endTime, startTimeRT) --creates a variable to hold the current time taken in seconds. Uses the difftime() funtion to subtract the 2nd (startTime) from the 1st(endTime) argument
		print("Your Real Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.") --inline print function that will calculate hours, minutes, and seconds. Might be upgraded to milliseconds.
	end

	function calculateInGameTime(endTime, startTimeIGT, ...) --Function used to calculate in game time from when the player enters the world how long the run took

		local timeTaken = difftime(endTime, startTimeIGT) + accumTimeIGT  --Function used to calculate real time how long the run took
		print("Your In Game Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.") --inline print function that will calculate hours, minutes, and seconds. Might be upgraded to milliseconds.
	
	end
	
	function startTimer(argStartingCondition) --function that will handle deciding if the player can begin a run or not.
		if playerLoaded == true then --if the player has acknowledged loading in to the game, and is ready...
			if timerRunning == false then --and as long as the timer isn't already running
				print("Timer has begun. Cause:", argStartingCondition) --let the user know the run is starting, and why the timer was started.
				timerRunning = true; --set the timer running to true
				startTimeRT = GetSessionTime(); --sets the RTstart to the currentSessionTime
				startTimeIGT = GetSessionTime(); --sets the IGTstart to the currentSessionTime
			end
		else --if the player has not indecated that they are ready
			print("Please reset the run. Reason for false start:", argStartingCondition) --any condition that would normally start the timer will fire, letting the user know they need to reset the run
		end
	end

	
	--------------------
	-- Slash Commands --
	--------------------
	
SLASH_TIMERGOAL1 = '/timerGoal'; -- SLASH_PRINTTIME1 sets the PRINTTIME1 trigger word to '/printTime', variables must match SLASH_(NAME)(X) where NAME is the message grouping, and X is an incremental counter starting at 1
	function SlashCmdList.TIMERGOAL(msg) -- sets the /timerGoal function, taking a message as the argument.
		if tonumber(msg) then --if the slash command contains a message...
			if tonumber(msg) > WOW_LOWEST_LEVEL and tonumber(msg) < WOW_HIGHEST_LEVEL then --if the message is a value within the acceptable values (stated at the start of this program)
				goalLevel = msg --set the goal level to the msg sent
				print("The current goal level is", goalLevel) --inform the user that the goal has changed
			else --if there is a message that is NOT an integer between the accepted values
				print("Please input a valid integer between 2 and 110 (Ex: 20). Current goal:", goalLevel) --let the user know the error, and show the current goal
			end
		end
		
		if not tonumber(msg) then --if no message is attached to the slash command...
			if msg == "" then --if the message is empty...
				print("The current goal level is", goalLevel) --just display the current goal level
			else --if the user submits a message that can't be set to a number
				print("Please input a valid integer between 2 and 110 (Ex: 20). Current goal:", goalLevel) --let the user know, and show the current goal level
			end
		end
	end
	
SLASH_TIMERREADY1 = '/timerReady'; -- SLASH_READY1 sets the READY1 trigger word to '/timerReady', must match input text exactly
	function SlashCmdList.TIMERREADY(msg, editbox)
		playerLoaded = true; --shows that the player is loaded and ready to goal
		print("Timer is ready. Timer will begin on first input.")
	end
	
SLASH_TIMERCURRENTTIME1 = '/timerCurrentTime'; --SLASH_CURRENTIME1 sets the CURRENTTIME1 trigger to '/timerCurrentTime', and will display the current time, or split, of the run
	function SlashCmdList.TIMERCURRENTTIME() 
		if timerRunning == true then --if the timer is currently running
			local timeTaken = difftime(GetSessionTime(), startTimeIGT) + accumTimeIGT --set the current time taken to the difference between the current and start times, adding the accumulated times (For real time)
			print("Your Real Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.")
			print("Your In Game Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.")
		--doesn't call the respective calculate functions because this isn't based on the final times, this is calculated as it is requested
		else
			print("The timer is not currently running. Please begin a run.") --placeholder line to show that the timer is not running
		end
	end
	
SLASH_TIMERSTOP1 = '/timerStop';
	function SlashCmdList.TIMERSTOP(msg, editbox)
		print("Timer has been stopped.")
				timerRunning = false; --set the timer running to false, since the timer is being stopped
				playerLoaded = false; --sets the playerLoaded to false, allowing the user to restart should requirements be met
				startTimeRT = GetSessionTime(); --sets the current RT timer to the currentSessionTime
				startTimeIGT = GetSessionTime(); --sets the current IGT timer to the currentSessionTime
	end
	

	--------------------
	-- Event Register --
	--------------------
	eventFrame:SetScript("OnEvent", function(self, event, ...) --Sets the scripts of all the event functions and how they will be handled
	events[event](self, ...);
	end);
	for k, v in pairs(events) do
		eventFrame:RegisterEvent(k) --Registers each event as they are definied
			
end




