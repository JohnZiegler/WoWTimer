TestTimer = LibStub("AceAddon-3.0"):NewAddon("TestTimer", "AceConsole-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
-- --
local startTimeIGT = 0.0  --Initializes the In Game Timer (IGT) start time to 0
local startTimeRT = 0.0  --Initializes the Real Time (RT) start time to 0
local endTime = 0.0  --Initializes the end time variable to 0
local accumTimeIGT = 0.0  --Initializes the accumulating time variable that is used when the player enters a loading screen. Should not include reloads and moving into instances.
local accumTimeRT = 0.0  --Initializes a back up variable in case a real time one is needed, see above variable
local eventFrame, events = CreateFrame("FRAME"), {}  --Creates the frame in which all of the addon will be taking place
-- --



local defaults = {
    profile = {
        message = "Welcome Home!",
        showInChat = true,
        showOnScreen = true,
    },
}

local options = {
    name = "TestTimer",
    handler = TestTimer,
    type = "group",
    args = {
        msg = {
            type = "input",
            name = "Message",
            desc = "The message text to be displayed",
            usage = "<Your message here>",
            get = "GetMessage",
            set = "SetMessage",
        },
        showInChat = {
            type = "toggle",
            name = "Show in Chat",
            desc = "Toggles the display of the message in the chat window.",
            get = "IsShowInChat",
            set = "ToggleShowInChat",
        },
        showOnScreen = {
            type = "toggle",
            name = "Show on Screen",
            desc = "Toggles the display of the message on the screen.",
			get = "IsShowOnScreen",
            set = "ToggleShowOnScreen"
        },
    },
}

function TestTimer:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("TestTimerDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("TestTimer", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TestTimer", "TestTimer")
    self:RegisterChatCommand("tt", "ChatCommand")
    self:RegisterChatCommand("testtimer", "ChatCommand")
	debugprofilestart()
	self:Print("Addon loaded successfully!")
end

function TestTimer:OnEnable()
    -- Called when the addon is enabled	
    self:RegisterEvent("ZONE_CHANGED")
	--self:RegisterEvent("PLAYER_LEVEL_UP")
	--self:RegisterEvent("LOADING_SCREEN_DISABLED") 
	--self:RegisterEvent("PLAYER_LOGIN")
	--self:RegisterEvent("LOADING_SCREEN_ENABLED")	
end

function TestTimer:OnDisable()
    -- Called when the addon is disabled
end

function TestTimer:ZONE_CHANGED()
    if GetBindLocation() == GetSubZoneText() then
        if self.db.profile.showInChat then
            self:Print(self.db.profile.message) 
        end

        if self.db.profile.showOnScreen then
            UIErrorsFrame:AddMessage(self.db.profile.message, 1.0, 1.0, 1.0, 5.0)
        end
    end
end

-- --
----------------------------
	-- Events and World Stuff --
	----------------------------
	
	-- Dummy method to test timer functionality
	function events:ACTIONBAR_PAGE_CHANGED(...)
	--print("Bar page changed!")
	print("Player levelled up to level " .. UnitLevel("player") .. "!") 
		--if playerLevel == 5 then --The number here decides at which level the run will stop. Must be a number between 2-110 inclusive
			endTime = debugprofilestop()  --Gets the current time the level is acieved and stores it in the end time IGT variable.
			--print("Debug for end time: " .. endTime)
			
			calculateRealTime(endTime, startTimeRT, ...) 
			calculateInGameTime(endTime, startTimeIGT, ...) 
			
			--print(difftime(endTime, startTime))  -- Legacy Code? --Testing to see how to get rid of double printing, moved the calculate time function in line with the unit level check
		--end
	end
	
	function events:PLAYER_LEVEL_UP(playerLevel, ...)
		print("Player levelled up to level " .. playerLevel .. "!") 
		if playerLevel == 10 then --The number here decides at which level the run will stop. Must be a number between 2-110 inclusive
			endTime = debugprofilestop()  --Gets the current time the level is acieved and stores it in the end time IGT variable.
			--print("Debug for end time: " .. endTime)
			
			calculateRealTime(endTime, startTimeRT, ...) 
			calculateInGameTime(endTime, startTimeIGT, ...) 
			
			--print(difftime(endTime, startTime))  -- Legacy Code? --Testing to see how to get rid of double printing, moved the calculate time function in line with the unit level check
		end
	end
	
	function events:LOADING_SCREEN_DISABLED(...) --The event that fires when the player enters the world. For a new character, this is when the cutscene plays as the player is loaded in.
		
		startTimeIGT = debugprofilestop()  --Starts the in game timer with the current millisecond time
		--print("Debug for IGT: " .. startTimeIGT)
		
	end

	function events:PLAYER_LOGIN(...) --The event that fires when the player logs in to the game. This fires during the first loading screen, before the PLAYER_ENTERING_WORLD event
		if startTimeRT == 0 then
			startTimeRT = debugprofilestop()  --Starts the real time timer with the current millisecond time
			--print("Debug for RT: " .. startTimeRT)
		end
	end
	
	function events:LOADING_SCREEN_ENABLED(...)
		if (endTime - startTimeIGT) > 0 then
			accumTimeIGT = accumTimeIGT + (endTime - startTimeIGT)
		end
			
	end
	
	----------------------
	-- Actual Functions --
	----------------------
	function calculateRealTime(endTime, startTimeRT, ...) --Function used to calculate real time how long the run took
		--print("Calc RT fire")
		local timeTaken = (endTime - startTimeRT)
		local ftimeTaken = floor(timeTaken)
		--print("Floor timeTaken: " .. )
		--print("Test")		
		--print("timeTaken value = " .. timeTaken .. ", showinchat = " .. self.db.profile.showInChat .. ", showonscreen = " .. self.db.profile.showOnScreen)
		--if self.db.profile.showInChat then
		--	print("Calc RT show in chat fire")
            print("Your Real Time: " .. floor((timeTaken/1000)/3600) .. " hours, " .. floor((timeTaken/1000)/60) .. " minutes, " .. floor((timeTaken/1000)%60) .. " seconds, " .. (ftimeTaken%1000.0) .. " milliseconds.") 
			
		--end
        --if self.db.profile.showOnScreen then
        --    print("Calc RT show on screen fire")
			UIErrorsFrame:AddMessage("Your Real Time: " .. floor((timeTaken/1000)/3600) .. " hours, " .. floor((timeTaken/1000)/60) .. " minutes, " .. floor((timeTaken/1000)%60) .. " seconds, " .. (ftimeTaken%1000.0) .. " milliseconds.", 1.0, 1.0, 1.0, 5.0)
        --end
		--print("Did we get this far?")
		
	end

	function calculateInGameTime(endTime, startTimeIGT, ...) --Function used to calculate in game time from when the player enters the world how long the run took
		--print("Calc IGT fire")
		local timeTaken = (endTime - startTimeIGT) + accumTimeIGT
		local ftimeTaken = floor(timeTaken)
		--print("timeTaken value = " .. timeTaken .. ", showinchat = " .. self.db.profile.showInChat .. ", showonscreen = " .. self.db.profile.showOnScreen)
		--if self.db.profile.showInChat then
			--print("Calc IGT show in chat fire")
            print("Your In Game Time: " .. floor((timeTaken/1000)/3600) .. " hours, " .. floor((timeTaken/1000)/60) .. " minutes, " .. floor((timeTaken/1000)%60) .. " seconds, " .. (ftimeTaken%1000.0) .. " milliseconds.") 
			--print("Your In Game Time: " .. floor(timeTaken/3600) .. " hours, " .. floor(timeTaken/60) .. " minutes, " .. timeTaken%60 .. " seconds.") 
        --end
        --if self.db.profile.showOnScreen then
			--print("Calc IGT show on screen fire")
            UIErrorsFrame:AddMessage("Your In Game Time: " .. floor((timeTaken/1000)/3600) .. " hours, " .. floor((timeTaken/1000)/60) .. " minutes, " .. floor((timeTaken/1000)%60) .. " seconds, " .. (ftimeTaken%1000.0) .. " milliseconds.", 1.0, 1.0, 1.0, 5.0)
        --end
	end
	
	--------------------
	-- Event Register --
	--------------------
	eventFrame:SetScript("OnEvent", function(self, event, ...) --Sets the scripts of all the event functions and how they will be handled
	events[event](self, ...) 
	end) 
	for k, v in pairs(events) do
		eventFrame:RegisterEvent(k) --Registers each event as they are definied		
	end
-- --


--[[local textStore

local frame = AceGUI:Create("Frame")
frame:SetTitle("Example Frame")
frame:SetStatusText("AceGUI-3.0 Example Container Frame")
frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
frame:SetLayout("Flow")

local editbox = AceGUI:Create("EditBox")
editbox:SetLabel("Insert text:")
editbox:SetWidth(200)
editbox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
frame:AddChild(editbox)

local button = AceGUI:Create("Button")
button:SetText("Click Me!")
button:SetWidth(200)
button:SetCallback("OnClick", function() print(textStore) end)
frame:AddChild(button)
end]]--

function TestTimer:GetMessage(info)
    return self.db.profile.message
end

function TestTimer:SetMessage(info, newValue)
    self.db.profile.message = newValue
end

function TestTimer:IsShowInChat(info)
    return self.db.profile.showInChat
end

function TestTimer:ToggleShowInChat(info, value)
    self.db.profile.showInChat = value
end

function TestTimer:IsShowOnScreen(info)
    return self.db.profile.showOnScreen
end

function TestTimer:ToggleShowOnScreen(info, value)
    self.db.profile.showOnScreen = value
end

function TestTimer:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("tt", "testtimer", input)
    end
end

-- --


