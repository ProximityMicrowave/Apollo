FallingDuration = 0
Apollo = {}
Apollo.Diagnostic = {}


--== GLOBAL DECLARATIONS ==--
Apollo_Ability = {}								-- ARRAY CONTAINING ALL RELEVANT ABILITY DATA
Apollo_Ability.SpellName = {}
Apollo_Ability.Cast = {}						-- ARRAY CONTAINING WHICH ABILITIES SHOULD BE CAST
Apollo_Ability.Type = {}
Apollo_Group = {}
Apollo_DelayTime = 0							-- DO NOT CHANGE! (STORES THE TIME SINCE LAST PERIODIC UPDATE)
Apollo_UpdateSeconds = 0.1; 					-- DETERMINES HOW OFTEN PERIODIC EVENTS WILL RUN

ApolloHealer_Below100 = 0
ApolloHealer_Below75 = 0
ApolloHealer_Below50 = 0
ApolloHealer_Below25 = 0

local frame = CreateFrame("FRAME");				-- CREATES A FRAME FOR REGISTERING INGAME EVENTS
frame:RegisterEvent("ADDON_LOADED");			-- ALLOWS FILTERING FOR THE ADDON_LOADED EVENT
frame:RegisterEvent("UNIT_HEALTH");				-- ALLOWS FILTERING FOR THE UNIT_HEALTH EVENT
frame:RegisterEvent("UNIT_POWER");				-- ALLOWS FILTERING FOR THE UNIT_POWER EVENT
frame:RegisterEvent("PLAYER_TARGET_CHANGED");	-- ALLOWS FILTERING FOR THE PLAYER_TARGET_CHANGED EVENT
frame:RegisterEvent("PLAYER_ENTERING_WORLD");	-- ALLOWS FILTERING FOR THE PLAYER_ENTERING_WORLD EVENT
frame:RegisterEvent("GROUP_ROSTER_UPDATE");		-- ALLOWS FILTERING FOR WHEN THE PLAYERS PARTY CHANGES
frame:RegisterEvent("PLAYER_REGEN_ENABLED");


-- THIS FUNCTION TRIGGERS IN RESPONSE TO ANY INGAME EVENT
function frame:OnEvent(event, arg1)		-- EVENT REFERS TO THE TRIGGERING EVENT, ARG1 IS THE FIRST ASSOCIATED ARGUEMENT. (THIS CAN BE USED TO FILTER EVENTS)

	if event == "ADDON_LOADED" and arg1 == "Apollo" then	-- ADDON_LOADED EVENT FILTER, SCRIPT ONLY RUNS IF THE ADDON_LOADED EVENT OCCURES.
		
		_,_,Apollo_classIndex = UnitClass("player");		-- DETERMINES THE PLAYERS CLASS
		if Apollo_classIndex == 1 then loaded,reason = LoadAddOn("Apollo_Warrior"); end;	-- IF THE PLAYER IS A WARRIOR; THE WARRIOR MODULE WILL BE LOADED.
		if Apollo_classIndex == 2 then loaded,reason = LoadAddOn("Apollo_Paladin"); end;	-- IF THE PLAYER IS A PALADIN; THE PALADIN MODULE WILL BE LOADED.
		if Apollo_classIndex == 4 then loaded,reason = LoadAddOn("Apollo_Rogue"); end;		-- IF THE PLAYER IS A ROGUE; THE ROGUE MODULE WILL BE LOADED.
		if Apollo_classIndex == 8 then loaded,reason = LoadAddOn("Apollo_Mage"); end;		-- IF THE PLAYER IS A ROGUE; THE ROGUE MODULE WILL BE LOADED.
		
	end
	
	if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED" then 
	
		ApolloHealer_Keybinding()	--CREATES KEYBINDINGS FOR FOCUS TARGETS
		Apollo.RebindKeys = true;
		
	end
	
	

end

-- This function triggers every frame.
function Apollo_OnUpdate(self, elapsed)

	if ApolloTest2 ~= ApolloTest1 then print(ApolloTest2.." => "..ApolloTest1); end;

	Apollo_InCombat = InCombatLockdown()
	
	local Apollo_CurrentTime = GetTime()

	FallingThen = FallingNow
	FallingNow = IsFalling()
	
	if FallingNow == true and FallingThen == false then
		FallingStart = Apollo_CurrentTime
	end
	
	if FallingNow == false then
		FallingDuration = 0;
	end
	
	if FallingNow == true and FallingThen == true then
			FallingDuration = Apollo_CurrentTime - FallingStart;
	end
	
	-- These Scripts run every 0.2 Seconds.
	if (Apollo_CurrentTime >= Apollo_DelayTime) then Apollo_DelayTime = (Apollo_CurrentTime + Apollo_UpdateSeconds)
	
		-- STORES PARTY MEMBER DESIGNATIONS AND IDENTIFIES GROUP TANK.
--		for i = 0,4 do
--			if i == 0 then Apollo_Group[i] = "player" else Apollo_Group[i] = "party"..i; end;
--			if UnitGroupRolesAssigned(Apollo_Group[i]) == "TANK" then ApolloHealer_TANK = Apollo_Group[i]; end;
--		end
	
		Apollo_GCSpell = "Auto Attack"
		if IsAddOnLoaded("Apollo_Warrior") then ApolloWarrior_Periodic(); end;
		if IsAddOnLoaded("Apollo_Paladin") then ApolloPaladin_Periodic(); Apollo_GCSpell = 35395; end;
		if IsAddOnLoaded("Apollo_Rogue") then ApolloRogue_Periodic(); end;
		if IsAddOnLoaded("Apollo_Mage") then ApolloMage_Periodic(); end;
		if Apollo_classIndex == 11 then Apollo.Druid.Periodic(); end;
		if Apollo_classIndex == 7 then Apollo.Shaman.Periodic(); Apollo_GCSpell = 403; end;
			
	end

	if IsAddOnLoaded("Apollo_Warrior") then ApolloWarrior_OnUpdate(); end;
	if IsAddOnLoaded("Apollo_Paladin") then ApolloPaladin_OnUpdate(); end;
	if IsAddOnLoaded("Apollo_Rogue") then ApolloRogue_OnUpdate(); end;
	if IsAddOnLoaded("Apollo_Mage") then ApolloMage_OnUpdate(); end;
	
	local r = 0
	local g = 0
	local b = 0
	
	if 
		ChatFrame1EditBox:IsVisible() == true or
		UnitCastingInfo("player") ~= nil or
		UnitChannelInfo("player") ~= nil or
		GetSpellCooldown(Apollo_GCSpell) ~= 0
	then
		ColorDot:SetTexture(r,g,b,1);
		return; 
	end;
		
	for i = 1,80 do
--		if Apollo_Ability.Cast[i] == nil then break; end;
		
		if Apollo_Ability.Cast[i] == true then
			r = i/255
			g = i/255
			b = i/255
		end	
	end
	
	local LowestName, LowestHealth = ApolloHealer_LowestHealth()
	local DecurseName, DebuffType = ApolloHealer_Decurse()
	if Apollo_classIndex == 11 then
		BuffName = ApolloHealer_BuffScan("Rejuvenation","HoT")
	end

--	local IdealTarget = DecurseName or LowestName

	if DecurseName then IdealTarget = DecurseName;
	elseif (ApolloHealer_Below75 == 0 and BuffName) then IdealTarget = BuffName;
	else IdealTarget = LowestName; end;

	
	if UnitIsUnit("focus",IdealTarget) == false then
		for i = 1,Apollo_Group.GroupNum do
			local Offset = 0
			if Apollo_GroupType == "party" then Offset = -1; end;
			PartyMember = Apollo_GroupType..i+Offset
			if PartyMember == "party0" then PartyMember = "player"; end;
			
			if UnitIsUnit(PartyMember,IdealTarget) == true then
				r = (i)/255
				g = 0
				b = 0
			end
		end
	end
	
	ColorDot:SetTexture(r,g,b,1);
	
end

function Apollo_AOEToggle()

	if Apollo_AOEMode == false then
		Apollo_AOEMode = true
		print("AOE Mode is ON.")
	else
		Apollo_AOEMode = false
		print("AOE Mode is OFF.")
	end
	

end

function ApolloTest()

	for i = 1, #Apollo_Group do
	
		print(Apollo_Group[i])
	
	end

end

frame:SetScript("OnEvent", frame.OnEvent);
