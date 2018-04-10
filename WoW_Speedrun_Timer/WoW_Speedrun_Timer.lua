local startTimeIGT = 0; --Initializes the In Game Timer (IGT) start time to 0
local startTimeRT = 0; --Initializes the Real Time (RT) start time to 0
local endTime = 0; --Initializes the end time variable to 0
local accumTimeIGT = 0; --Initializes the accumulating time variable that is used when the player enters a loading screen. Should not include reloads and moving into instances.
local accumTimeRT = 0; --Initializes a back up variable in case a real time one is needed, see above variable

local eventFrame, events = CreateFrame("FRAME"), {}; --Creates the frame in which all of the addon will be taking place
	
	
	----------------------------
	-- Events and World Stuff --
	----------------------------
	
	function events:PLAYER_LEVEL_UP(playerLevel, ...)
		if playerLevel == 10 then --The number here decides at which level the run will stop. Must be a number between 2-110 inclusive
			endTime = GetTime(); --Gets the current time the level is acieved and stores it in the end time IGT variable.
			
			calculateRealTime(endTime, startTimeRT, ...);
			calculateInGameTime(endTime, startTimeIGT, ...);
			
			--print(difftime(endTime, startTime)); -- Legacy Code? --Testing to see how to get rid of double printing, moved the calculate time function in line with the unit level check
		end
	end
	
	function events:LOADING_SCREEN_DISABLED(...) --The event that fires when the player enters the world. For a new character, this is when the cutscene plays as the player is loaded in.
		
		startTimeIGT = GetTime(); --Starts the in game timer with the current millisecond time
		
	end

	function events:PLAYER_LOGIN(...) --The event that fires when the player logs in to the game. This fires during the first loading screen, before the PLAYER_ENTERING_WORLD event
		if startTimeRT == 0 then
			startTimeRT = GetTime(); --Starts the real time timer with the current millisecond time
		end
	end
	
	function events:LOADING_SCREEN_ENABLED(...)
		if difftime(endTime, startTimeIGT) > 0 then
			accumTimeIGT = accumTimeIGT + difftime(endTime, startTimeIGT)
		end
			
	end
	
	
	
	
	----------------------
	-- Actual Functions --
	----------------------
	function calculateRealTime(endTime, startTimeRT, ...) --Function used to calculate real time how long the run took

		local timeTaken = difftime(endTime, startTimeRT)
		print("Your Real Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.")
		
	end

	function calculateInGameTime(endTime, startTimeIGT, ...) --Function used to calculate in game time from when the player enters the world how long the run took

		local timeTaken = difftime(endTime, startTimeIGT) + accumTimeIGT
		print("Your In Game Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.")
	
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




