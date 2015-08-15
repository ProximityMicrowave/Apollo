local PaladinFrame = CreateFrame("FRAME");
PaladinFrame:RegisterEvent("PLAYER_LOGIN");
PaladinFrame:RegisterEvent("UNIT_POWER_FREQUENT");
PaladinFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
PaladinFrame:RegisterEvent("SPELL_UPDATE_USABLE")
PaladinFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
PaladinFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
PaladinFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

-- This function is triggered once every frame.
function ApolloPaladin_OnUpdate(self, elapsed)

end

-- This function is triggered once every .2 seconds.
function ApolloPaladin_Periodic()

	local IncomingHeal = UnitGetIncomingHeals("focus") or 0;

	-- <MISC CHECKS>: CHECKS FOR VARIOUS STATUSES
	ApolloPaladin_CanAttack = UnitCanAttack("player", "target")					-- DETERMINES IF THE PLAYERS CURRENT TARGET CAN BE ATTACKED
	ApolloPaladin_TargetIsDead = UnitIsDead("target")							-- DETERMINES IF THE PLAYERS CURRENT TARGET IS DEAD
	ApolloPaladin_HolyPower = UnitPower("player",9)								-- DETERMINES THE PLAYERS HOLY POWER
	ApolloPaladin_FocusHealth = ( UnitHealth("focus") + IncomingHeal ) / UnitHealthMax("focus")	-- DETERMINES THE PLAYERS FOCUS CURRENT HEALTH WITH INCOMING HEALS
	----	----	----	----	----

	-- <BUFF CHECKS>: THIS SECTION RUNS VARIOUS BUFF CHECKS
	ApolloPaladin_InfusionOfLightBuff = false
	for i = 1,40 do														-- SCANS EACH PLAYER BUFF ONE AT A TIME
		
		local name = UnitBuff("player",i);								-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Infusion of Light" then ApolloPaladin_InfusionOfLightBuff = true; end;					-- CHECKS IF THE PLAYER HAS REJUVENATION

	end
	----	----	----	----	----
	
	-- <RANGE CHECKS>: THIS SECTION RUNS RANGE CHECKS FOR ABILITIES AGAINST VARIOUS TARGETS --
	if IsSpellInRange("Crusader Strike", "target") == 1 then
		ApolloPaladin_TargetInMeleeRange = true else ApolloPaladin_TargetInMeleeRange = false		-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS IN MELEE RANGE.
	end
	----	----	----	----	----
	
	-- <COOLDOWN CHECKS>: THIS SECTION CHECKS COOLDOWNS FOR VARIOUS ABILITIES. --
	_,ApolloPaladin_GlobalCooldown,_ = GetSpellCooldown("Crusader Strike")
	_,ApolloPaladin_HolyShockCooldown,_ = GetSpellCooldown("Holy Shock")
	_,ApolloPaladin_ExecutionSentenceCooldown,_ = GetSpellCooldown("Execution Sentence")
	_,ApolloPaladin_AvengingWrathCooldown,_ = GetSpellCooldown("Avenging Wrath")
	_,ApolloPaladin_LayOnHandsCooldown,_ = GetSpellCooldown("Lay on Hands")
	_,ApolloPaladin_CleanseCooldown,_ = GetSpellCooldown("Cleanse")
	----	----	----	----	----
	
	-- ABILITY FUNCTIONS ARE TRIGGERED HERE AND THE RESPONSES SENT TO APOLLO_CORE.LUA
	-- ABILITIES ARE SORTED IN DESCENDING ORDER, THE LAST ONE ON THE LIST TO RETURN TRUE WILL BE THE ABILITY TRIGGERED.
	if ApolloPaladin_IsMounted == true then return; end;	--STOPS TRIGGERING IF PLAYER IS MOUNTED
	ApolloPaladin_SkillList = {
		"ApolloPaladin_AutoAttack",
		"ApolloPaladin_HolyLight",
		"ApolloPaladin_FlashOfLight",
		"ApolloPaladin_WordOfGlory",
		"ApolloPaladin_LightOfDawn",
		"ApolloPaladin_HolyShock",
		"ApolloPaladin_LayOnHands",
		"ApolloPaladin_AvengingWrath",
		"ApolloPaladin_StayOfExecution",
		"ApolloDruid_Cleanse",
		}
	
	-- SETS VARIABLES TO BE READ BY APOLLO_CORE.LUA
	for i = 1,40 do
	
		local x = ApolloPaladin_SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = _G[x]()
		
	end

end

-- This function runs in response to ingame events.
function PaladinFrame:OnEvent(event, arg1)

	-- Fired when the addon "Apollo" is loaded.
	if event == "PLAYER_LOGIN" then
		print("Apollo: Paladin module is loaded.")
	
	end
	
	-- Fires when the player loads the game world.
	if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then

		-- Assigns Spell Keybinding
		ApolloPaladin_Periodic()
		for i = 1,40 do
			if Apollo_Ability.SpellName[i] == nil then break; end;
			SetBindingClick(Apollo_Ability.KeyBinding[i], Apollo_Ability.SpellName[i])
		end
		
	end
	
end

-- Checks to see if Auto Attack should be used.
function ApolloPaladin_AutoAttack()

	local spellCast = false
	local spellName = "Auto Attack"
	local spellType = "target"

	local isCurrent = IsCurrentSpell(spellName)		-- Determines if Auto Attack is already activated.
	
	if not Apollo_InCombat then
		if AutoAttackBtn == nil then AutoAttackBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		AutoAttackBtn:SetAttribute("type", "macro");
		AutoAttackBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloPaladin_TargetInMeleeRange == true and ApolloPaladin_CanAttack == true and ApolloPaladin_TargetIsDead == false and isCurrent == false then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_FlashOfLight()

	local spellCast = false
	local spellName = "Flash of Light"
	local spellType = "focus"
	
	if not Apollo_InCombat then
		if FlashOfLightBtn == nil then FlashOfLightBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		FlashOfLightBtn:SetAttribute("type", "macro");
		FlashOfLightBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloPaladin_FocusHealth < .6 and ApolloPaladin_InfusionOfLightBuff == false then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_HolyLight()

	local spellCast = false
	local spellName = "Holy Light"
	local spellType = "focus"
	
	if not Apollo_InCombat then
		if HolyLightBtn == nil then HolyLightBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		HolyLightBtn:SetAttribute("type", "macro");
		HolyLightBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloPaladin_FocusHealth < .9 then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_HolyShock()

	local spellCast = false
	local spellName = "Holy Shock"
	local spellType = "focus"
	
	if not Apollo_InCombat then
		if HolyShockBtn == nil then HolyShockBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		HolyShockBtn:SetAttribute("type", "macro");
		HolyShockBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloPaladin_FocusHealth < 1 and ApolloPaladin_HolyShockCooldown == 0 then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_WordOfGlory()

	local spellCast = false
	local spellName = "Word of Glory"
	local spellType = "focus"
	
	if not Apollo_InCombat then
		if WordOfGloryBtn == nil then WordOfGloryBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		WordOfGloryBtn:SetAttribute("type", "macro");
		WordOfGloryBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloPaladin_FocusHealth < .9 and ApolloPaladin_HolyPower == 5 then
		spellCast = true
	end
	
	if ApolloPaladin_FocusHealth < .6 and ApolloPaladin_HolyPower >= 3 then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_LightOfDawn()

	local spellCast = false
	local spellName = "Light of Dawn"
	local spellType = "player"
	
	if not Apollo_InCombat then
		if LightOfDawnBtn == nil then LightOfDawnBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		LightOfDawnBtn:SetAttribute("type", "macro");
		LightOfDawnBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloHealer_Below75 >= 3 and ApolloPaladin_HolyPower >= 3 then
		spellCast = true
	end
	
	return spellCast, spellName, spellType

end

function ApolloPaladin_StayOfExecution()

	local spellCast = false
	local spellName = "Execution Sentence"
	local spellType = "focus"
	
	if not Apollo_InCombat then
		if StayOfExecutionBtn == nil then StayOfExecutionBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		StayOfExecutionBtn:SetAttribute("type", "macro");
		StayOfExecutionBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloPaladin_FocusHealth < .6 and 
		ApolloPaladin_ExecutionSentenceCooldown == 0
	then
		spellCast = true; end;
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_AvengingWrath()

	local spellCast = false
	local spellName = "Avenging Wrath"
	local spellType = "player"
	
	if not Apollo_InCombat then
		if AvengingWrathBtn == nil then AvengingWrathBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		AvengingWrathBtn:SetAttribute("type", "macro");
		AvengingWrathBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloPaladin_FocusHealth < .6 and 
		ApolloPaladin_AvengingWrathCooldown == 0 and 
		ApolloPaladin_GlobalCooldown == 0 
	then
		spellCast = true; end;
	
	return spellCast, spellName, spellType
	
end

function ApolloPaladin_LayOnHands()

	local spellCast = false
	local spellName = "Lay on Hands"
	local spellType = "player"
	
	if not Apollo_InCombat then
		if LayOnHandsBtn == nil then LayOnHandsBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		LayOnHandsBtn:SetAttribute("type", "macro");
		LayOnHandsBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloPaladin_FocusHealth < .3 and 
		ApolloPaladin_LayOnHandsCooldown == 0 and 
		ApolloPaladin_GlobalCooldown == 0 
	then
		spellCast = true; end;
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Cleanse()

	local spellName = "Cleanse"
	local spellType = "focus"
	local debuffFound = false
	local spellCast = false
	
	if not Apollo_InCombat then
		if CleanseBtn == nil then CleanseBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		CleanseBtn:SetAttribute("type", "macro");
		CleanseBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	for i = 1,40 do
	
		_,_,_,_,debuffType,_,_,_,_,_,_,_,_,_,_,_ = UnitDebuff(spellType,i)
		if debuffType == nil then break; end;
		if debuffType == "Magic" then debuffFound = true; end;
		if debuffType == "Disease" then debuffFound = true; end;
		if debuffType == "Poison" then debuffFound = true; end;
		
	end
	
	if 
		ApolloPaladin_CleanseCooldown == 0 and
		debuffFound == true
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

PaladinFrame:SetScript("OnEvent", PaladinFrame.OnEvent);