local DruidFrame = CreateFrame("FRAME");
DruidFrame:RegisterEvent("PLAYER_LOGIN");
DruidFrame:RegisterEvent("UNIT_POWER_FREQUENT");
DruidFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
DruidFrame:RegisterEvent("SPELL_UPDATE_USABLE")
DruidFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
DruidFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
DruidFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
DruidFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
DruidFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ApolloDruid_WildMushroomTick = 0

-- This function is triggered once every frame.
function ApolloDruid_OnUpdate(self, elapsed)

	-- resets abilities before check
--	for i = 1,40 do
--		if Apollo_Ability.Cast[i] == nil then break; end;
--		Apollo_Ability.Cast[i] = false
--	end

end

-- This function is triggered once every .2 seconds.
function ApolloDruid_Periodic()

--	print("ApolloDruid_Periodic() is running.")
--	if ApolloHealer_TANK == nil then ApolloHealer_TANK = "player"; end;

	-- THIS SECTION RUNS CHECKS THAT ARE REQUIRED FOR MULTIPLE SKILLS IN ORDER TO AVOID REDUNDANCY.
	ApolloDruid_CanAttack = UnitCanAttack("player", "target")					-- DETERMINES IF THE PLAYERS CURRENT TARGET CAN BE ATTACKED
	ApolloDruid_Energy = UnitPower("player");									-- DETERMINES HOW MUCH ENERGY THE PLAYER CURRENT HAS FOR ABILITIES
	ApolloDruid_ComboPoints = UnitPower("player",4)								-- DETERMINES HOW MANY COMBO POINTS THE PLAYER CURRENTLY HAS
	ApolloDruid_PlayerHealth = UnitHealth("player") / UnitHealthMax("player")	-- DETERMINES THE PLAYERS PERCENTAGE HEALTH
	ApolloDruid_FocusHealth = UnitHealth("focus") / UnitHealthMax("focus")		-- DETERMINES THE TARGETS PERCENTAGE HEALTH
	ApolloDruid_InCombat = InCombatLockdown()									-- DETERMINES IF THE PLAYER IS IN COMBAT
	_,_,_,_,_,_,_,_,ApolloDruid_TargetInterruptable = UnitCastingInfo("target")	-- RETRIEVES TARGET CASTING INFO
	_,_,ApolloDruid_TargetClass = UnitClass("target")							-- DETERMINES THE TARGETS CLASS
	ApolloDruid_TargetIsPlayerControlled = UnitPlayerControlled("target")		-- RETURNS TRUE IF THE TARGET IS CONTROLLED BY ANOTHER PLAYER
	ApolloDruid_TargetIsFriend = UnitIsFriend("player","target")				-- RETURNS TRUE IF THE PLAYERS TARGET IS FRIENDLY
	ApolloDruid_TargetIsDead = UnitIsDead("target")
	ApolloDruid_IsMounted = IsMounted()											-- RETURNS TRUE IF THE PLAYER IS MOUNTED
	ApolloDruid_IsInInstance = IsInInstance()									-- RETURNS NONE, PVP, ARENA, PARTY, RAID, OR NIL
	ApolloDruid_TargetClassification = UnitClassification("target")
	
	if IsSpellInRange("Shred", "target") == 1 then										--
		ApolloDruid_InMeleeRange = true else ApolloDruid_InMeleeRange = false		-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS IN MELEE RANGE.
	end																				--
	
	if IsSpellInRange("Wrath", "target") == 1 then									--
		ApolloDruid_In40yrdRange = true else ApolloDruid_In40yrdRange = false		-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS WITHIN 40 YARDS.
	end																				--
	
	if IsSpellInRange("Rejuvenation", "target") == 1 then							--
		ApolloDruid_InHealingRange = true else ApolloDruid_InHealingRange = false	-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS WITHIN HEALING RANGE.
	end																				--
	
	-- COOLDOWN CHECKS --
--	_,ApolloDruid_MoonfireCooldown,_ = GetSpellCooldown("Moonfire")
	_,ApolloDruid_GlobalCooldown,_ = GetSpellCooldown("Wrath")
	_,ApolloDruid_SwiftMendCooldown,_ = GetSpellCooldown("Swiftmend")
	_,ApolloDruid_ForceOfNatureCooldown,_ = GetSpellCooldown("Force of Nature")
	_,ApolloDruid_RebirthCooldown,_ = GetSpellCooldown("Rebirth")
	_,ApolloDruid_IronbarkCooldown,_ = GetSpellCooldown("Ironbark")
	_,ApolloDruid_NaturesCureCooldown,_ = GetSpellCooldown("Nature's Cure")
	_,ApolloDruid_NautresSwiftnessCooldown,_ = GetSpellCooldown("Nature's Swiftness")
	_,ApolloDruid_TranquilityCooldown,_ = GetSpellCooldown("Tranquility")
	_,ApolloDruid_WildGrowthCooldown,_ = GetSpellCooldown("Wild Growth")
	_,ApolloDruid_TigersFuryCooldown,_ = GetSpellCooldown("Tiger's Fury")
	_,ApolloDruid_SkullBashCooldown,_ = GetSpellCooldown("Skull Bash")
	_,ApolloDruid_MightyBashCooldown,_ = GetSpellCooldown("Mighty Bash")
	_,ApolloDruid_IncarnationCooldown,_ = GetSpellCooldown("Incarnation: King of the Jungle")
	
	-- THIS SCAN PERFORMS BUFF CHECKS ON THE PLAYER TO DETERMINE IF ANY BUFFS NEEDED FOR ABILITY TRIGGERS ARE ACTIVE
	ApolloDruid_RejuvenationPlayerBuff = false			-- ASSIGNS DEFAULT VALUE
	ApolloDruid_RejuvenationFocusBuff = false
	ApolloDruid_NaturesSwiftnessBuff = false
	ApolloDruid_MarkOfTheWildFocusBuff = false
	ApolloDruid_LifebloomBuff = false
	ApolloDruid_MoonfireDebuff = false				-- ASSIGNS DEFAULT VALUE
	ApolloDruid_CatFormBuff = false					-- ASSIGNS DEFAULT VALUE
	ApolloDruid_PredatorySwiftness = false
	ApolloDruid_DPSBuff = false

	for i = 1,40 do														-- SCANS EACH PLAYER BUFF ONE AT A TIME
		local name = UnitBuff("player",i);								-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Rejuvenation" then ApolloDruid_RejuvenationPlayerBuff = true; end;					-- CHECKS IF THE PLAYER HAS REJUVENATION
		if name == "Nature's Swiftness" then ApolloDruid_NaturesSwiftnessBuff = true; end;				-- CHECKS IF THE PLAYER HAS NATURE'S SWIFTNESS
		if name == "Cat Form" then ApolloDruid_CatFormBuff = true; end;									-- CHECKS IF THE PLAYER IS IN CAT FORM
		if name == "Predatory Swiftness" then ApolloDruid_PredatorySwiftness = true; end;
		if name == "Berserk" then ApolloDruid_DPSBuff = true; end;
		if name == "Incarnation: King of the Jungle" then ApolloDruid_DPSBuff = true; end;

	end
	
	for i = 1,40 do
		if ApolloHealer_TANK == nil then ApolloHealer_TANK = "player"; end;
		local name = UnitBuff(ApolloHealer_TANK,i);
		if name == nil then break; end;
		
		if name == "Lifebloom" then ApolloDruid_LifebloomBuff = true; end;

	end
	
	for i = 1,40 do														-- SCANS EACH TARGET BUFF ONE AT A TIME
		local name = UnitDebuff("target",i);							-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Moonfire" then ApolloDruid_MoonfireDebuff = true; end;					-- CHECKS IF THE TARGET HAS REVEALING STRIKE

	end
	
		for i = 1,40 do														-- SCANS EACH FOCUS BUFF ONE AT A TIME
		local name = UnitBuff("focus",i);							-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Rejuvenation" then ApolloDruid_RejuvenationFocusBuff = true; end;					-- CHECKS IF THE FOCUS HAS REJUVENATION
		if name == "Mark of the Wild" then ApolloDruid_MarkOfTheWildFocusBuff = true; end;				-- CHECKS IF THE FOCUS HAS MARK OF THE WILD
--		if name == "Lifebloom" then ApolloDruid_LifebloomBuff = true; end;
		
	end
	
	-- ABILITY FUNCTIONS ARE TRIGGERED HERE AND THE RESPONSES SENT TO APOLLO_CORE.LUA
	
	if GetSpecialization() == 4 then
		ApolloDruid_SkillList = {
			"ApolloDruid_AutoAttack",
			"ApolloDruid_Wrath",
			"ApolloDruid_Moonfire",
			"ApolloDruid_WildMushroom",
			"ApolloDruid_Rejuvenation",
			"ApolloDruid_Lifebloom",
			"ApolloDruid_Regrowth",
			"ApolloDruid_ForceOfNature",
			"ApolloDruid_Swiftmend",
			"ApolloDruid_IronBark",
			"ApolloDruid_Rebirth",
			"ApolloDruid_NaturesSwiftness",
			"ApolloDruid_WildGrowth",
			"ApolloDruid_Tranquility",
			"ApolloDruid_MarkOfTheWild",
			"ApolloDruid_NaturesCure",
			"ApolloDruid_FallPrevention",
			}
	end
	
	if GetSpecialization() == 2 then
		ApolloDruid_SkillList = {
			"ApolloDruid_FallPrevention",
			"ApolloDruid_AutoAttack",
			"ApolloDruid_CatForm",
			"ApolloDruid_MightyBash",
			"ApolloDruid_Shred",
			"ApolloDruid_FerociousBite",
			"ApolloDruid_Swipe",
			"ApolloDruid_Incarnation",
			"ApolloDruid_TigersFury",
			"ApolloDruid_HealthPotion",
			"ApolloDruid_HealingTouch",
			"ApolloDruid_SkullBash",
			}
	end
	
	if ApolloDruid_IsMounted == true then return; end;
	for i = 1,40 do
	
		local x = ApolloDruid_SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = _G[x]()
		
	end

end

-- This function runs in response to ingame events.
function DruidFrame:OnEvent(event, ...)
	
	-- Fired when the addon "Apollo" is loaded.
	if event == "PLAYER_LOGIN" then
		print("Apollo: Druid module is loaded.")
		if Apollo_AOEMode == nil then Apollo_AOEMode = false; end;
	
	end
	
	-- Fires when the player loads the game world.
	if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then

		-- Assigns Spell Keybinding
		ApolloDruid_Periodic()
		for i = 1,40 do
--			if not ApolloDruid_InCombat then break; end;
			if Apollo_Ability.SpellName[i] == nil then break; end;
--			print(Apollo_Ability.KeyBinding[i])
			SetBinding(Apollo_Ability.KeyBinding[i])
			SetBindingClick(Apollo_Ability.KeyBinding[i], string.gsub(Apollo_Ability.SpellName[i],":",""))
--			print(Apollo_Ability.KeyBinding[i].." - "..Apollo_Ability.SpellName[i])
		end
		
	end
	
	local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if type == "SPELL_HEAL" then
			
			local spellId, spellName, spellSchool, amount,
			overheal, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)
			if spellId == 81269 then
			
				ApolloDruid_WildMushroomTick = timestamp
			
			end;
	
		end
		
		if type == "SPELL_AURA_APPLIED" then
			local spellId, spellName, spellSchool, amount, overheal, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)
			if spellId == 81262 then
				ApolloDruid_WildMushroomTick = timestamp
			end
		end
	end
	
end

-- Checks to see if Auto Attack should be used.
function ApolloDruid_AutoAttack()

	local spellCast = false
	local spellName = "Auto Attack"
	local spellType = "target"

	local isCurrent = IsCurrentSpell(spellName)		-- Determines if Auto Attack is already activated.
	
	if not ApolloDruid_InCombat then
		if AutoAttackBtn == nil then AutoAttackBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		AutoAttackBtn:SetAttribute("type", "macro");
		AutoAttackBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if ApolloDruid_InMeleeRange == true and ApolloDruid_CanAttack == true and ApolloDruid_TargetIsDead == false and isCurrent == false then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_CatForm()

	local spellCast = false
	local spellName = "Cat Form"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if CatFormBtn == nil then CatFormBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		CatFormBtn:SetAttribute("type", "macro");
		CatFormBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InMeleeRange == true and 
		ApolloDruid_CanAttack == true and 
		ApolloDruid_TargetIsDead == false and
		ApolloDruid_CatFormBuff == false
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Wrath()

	local spellCast = false
	local spellName = "Wrath"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if WrathBtn == nil then WrathBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		WrathBtn:SetAttribute("type", "macro");
		WrathBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_CanAttack == true and 
		ApolloHealer_Below75 == 0 and
		ApolloDruid_TargetIsDead == false 
	then spellCast = true; end;
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Moonfire()

	local spellCast = false
	local spellName = "Moonfire"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if MoonfireBtn == nil then MoonfireBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		MoonfireBtn:SetAttribute("type", "macro");
		MoonfireBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_TargetIsDead == false and
		ApolloDruid_In40yrdRange == true and
		ApolloDruid_IsInInstance == false and
		ApolloDruid_CanAttack == true and
		ApolloDruid_MoonfireDebuff == false
	then spellCast = true; end;

	return spellCast, spellName, spellType
	
end

function ApolloDruid_Rejuvenation()

	local spellName = "Rejuvenation"
	local spellType = "focus"
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if RejuvenationBtn == nil then RejuvenationBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		RejuvenationBtn:SetAttribute("type", "macro");
		RejuvenationBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_RejuvenationFocusBuff == false and
		ApolloDruid_FocusHealth < 1
	then spellCast = true; end;
			
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Swiftmend()

	local spellName = "Swiftmend"
	local spellType = "focus"
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if SwiftmendBtn == nil then SwiftmendBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		SwiftmendBtn:SetAttribute("type", "macro");
		SwiftmendBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if
		ApolloDruid_SwiftMendCooldown == 0 and
		ApolloDruid_RejuvenationFocusBuff == true and
		ApolloDruid_FocusHealth < .75
	then spellCast = true; end;
		
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Regrowth()

	local spellName = "Regrowth"
	local spellType = "focus"
	local spellCast = false
	local castHealth

	if not ApolloDruid_InCombat then
		if RegrowthBtn == nil then RegrowthBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		RegrowthBtn:SetAttribute("type", "macro");
		RegrowthBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_FocusHealth < .75 and
		ApolloDruid_GlobalCooldown == 0
	then spellCast = true; end;
		
	return spellCast, spellName, spellType
	
end

function ApolloDruid_NaturesSwiftness()

	local spellName = "Nature's Swiftness"
	local spellType = "self"
	local spellCast = false

	if not ApolloDruid_InCombat then
		if NaturesSwiftnessBtn == nil then NaturesSwiftnessBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		NaturesSwiftnessBtn:SetAttribute("type", "macro");
		NaturesSwiftnessBtn:SetAttribute("macrotext", "/cast "..spellName)
	end
	
	if 
		IsUsableSpell(spellName) and
		ApolloDruid_NautresSwiftnessCooldown == 0
	then spellCast = true; end;
		
	return spellCast, spellName

end

function ApolloDruid_Lifebloom()
	local __func__ = "ApolloDruid_Lifebloom"

	local spellName = "Lifebloom"
	local spellType = ApolloHealer_TANK
	local spellCast = false
--[[
	if not ApolloDruid_InCombat then
		if LifebloomBtn == nil then LifebloomBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		LifebloomBtn:SetAttribute("type", "macro");
		LifebloomBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
]]	
	ApolloDruid_CreateButtons(__func__, spellName, spellType)
	
	if 
		ApolloDruid_InCombat == true and
		ApolloDruid_LifebloomBuff == false and
		IsSpellInRange("Lifebloom",ApolloHealer_TANK) == 1
	then spellCast = true; end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Rebirth()

	local spellName = "Rebirth"
	local spellType = ApolloHealer_TANK
	local spellCast = false

	if not ApolloDruid_InCombat then
		if RebirthBtn == nil then RebirthBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		RebirthBtn:SetAttribute("type", "macro");
		RebirthBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == true and
		UnitIsDeadOrGhost(ApolloHealer_TANK) == true and
		IsSpellInRange("Rebirth",ApolloHealer_TANK) == 1 and
		ApolloDruid_RebirthCooldown == 0
	then spellCast = true; end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_ForceOfNature()

	local spellName = "Force of Nature"
	local spellType = "focus"
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if ForceOfNatureBtn == nil then ForceOfNatureBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		ForceOfNatureBtn:SetAttribute("type", "macro");
		ForceOfNatureBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == true and
		ApolloDruid_ForceOfNatureCooldown == 0 and
		ApolloDruid_GlobalCooldown == 0 and
--		ApolloDruid_NaturesSwiftnessBuff == false and
		ApolloDruid_FocusHealth < .75
	then spellCast = true; end
	
	if
		ApolloDruid_InCombat == true and
		ApolloDruid_ForceOfNatureCooldown == 0 and
		GetSpellCharges(spellName) == 3 and
		ApolloDruid_FocusHealth < .1
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_Tranquility()

	local spellName = "Tranquility"
	local spellType = "player"
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if TranquilityBtn == nil then TranquilityBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		TranquilityBtn:SetAttribute("type", "macro");
		TranquilityBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == true and
		ApolloDruid_TranquilityCooldown == 0 and
		ApolloHealer_Below75 >= 3
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_WildGrowth()

	local spellName = "Wild Growth"
	local spellType = "focus"
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if WildGrowthyBtn == nil then WildGrowthyBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		WildGrowthyBtn:SetAttribute("type", "macro");
		WildGrowthyBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == true and
		ApolloDruid_WildGrowthCooldown == 0 and
		ApolloHealer_Below75 >= 3
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_IronBark()

	local spellName = "Ironbark"
	local spellType = ApolloHealer_TANK
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if IronbarkBtn == nil then IronbarkBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		IronbarkBtn:SetAttribute("type", "macro");
		IronbarkBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == true and
		UnitIsDeadOrGhost(ApolloHealer_TANK) == false and
		IsSpellInRange(spellName,spellType) == 1 and
		ApolloDruid_FocusHealth < .5 and
		ApolloDruid_NaturesSwiftnessBuff == false and
		ApolloDruid_GlobalCooldown == 0 and
		ApolloDruid_IronbarkCooldown == 0
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_NaturesCure()

	local spellName = "Nature's Cure"
	local spellType = "focus"
	local debuffFound = false
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if NaturesCureBtn == nil then NaturesCureBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		NaturesCureBtn:SetAttribute("type", "macro");
		NaturesCureBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	for i = 1,40 do
	
		local _,_,_,_,debuffType,_,_,_,_,_,_,_,_,_,_,_ = UnitDebuff(spellType, i)
		if debuffType == "Magic" then debuffFound = true; end;
		if debuffType == "Curse" then debuffFound = true; end;
		if debuffType == "Poison" then debuffFound = true; end;
		
	end
	
	if 
		ApolloDruid_NaturesCureCooldown == 0 and
		debuffFound == true
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_MarkOfTheWild()

	local spellName = "Mark of the Wild"
	local spellType = "player"
	local debuffFound = false
	local spellCast = false
	
	if not ApolloDruid_InCombat then
		if MarkOfTheWildBtn == nil then MarkOfTheWildBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		MarkOfTheWildBtn:SetAttribute("type", "macro");
		MarkOfTheWildBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_MarkOfTheWildFocusBuff == false
	then spellCast = true; end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_FallPrevention()

	local spellName = "Travel Form"
	local spellType = "target"
	local spellCast = false
	
	local isCurrent = GetShapeshiftForm()
	
	if not ApolloDruid_InCombat then
		if FallPreventionBtn == nil then FallPreventionBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		FallPreventionBtn:SetAttribute("type", "macro");
		FallPreventionBtn:SetAttribute("macrotext", "/cast "..spellName)
	end
	
	if 
		ApolloDruid_InCombat == false and
		FallingDuration > 2
	then spellCast = true; end
	
	if
		ApolloDruid_InCombat == false and
		IsSwimming() == true and
		isCurrent ~= 3
	then spellCast = true; end;
		
	return spellCast, spellName, spellType

end

function ApolloDruid_Shred()

	local spellCast = false
	local spellName = "Shred"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if ShredBtn == nil then ShredBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		ShredBtn:SetAttribute("type", "macro");
		ShredBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InMeleeRange == true and
		ApolloDruid_CanAttack == true and 
		ApolloDruid_TargetIsDead == false and
		ApolloDruid_Energy >= 50 and
		ApolloDruid_CatFormBuff == true
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_SkullBash()

	local spellCast = false
	local spellName = "Skull Bash"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if SkullBashBtn == nil then SkullBashBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		SkullBashBtn:SetAttribute("type", "macro");
		SkullBashBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_TargetInterruptable == false and
		ApolloDruid_SkullBashCooldown == 0 and
		ApolloDruid_CatFormBuff == true
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_TigersFury()

	local spellCast = false
	local spellName = "Tiger's Fury"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if TigersFuryBtn == nil then TigersFuryBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		TigersFuryBtn:SetAttribute("type", "macro");
		TigersFuryBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InMeleeRange == true and
		ApolloDruid_CanAttack == true and 
		ApolloDruid_TargetIsDead == false and
		ApolloDruid_Energy < 20 and
		ApolloDruid_TigersFuryCooldown == 0 and
		ApolloDruid_CatFormBuff == true
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_MightyBash()

	local spellCast = false
	local spellName = "Mighty Bash"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if MightyBashBtn == nil then MightyBashBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		MightyBashBtn:SetAttribute("type", "macro");
		MightyBashBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if
		ApolloDruid_InMeleeRange == true and
		ApolloDruid_CanAttack == true and 
		ApolloDruid_MightyBashCooldown == 0 and
		ApolloDruid_CatFormBuff == true
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType

end

function ApolloDruid_FerociousBite()

	local spellCast = false
	local spellName = "Ferocious Bite"
	local spellType = "target"
	
	if not ApolloDruid_InCombat then
		if FerociousBiteBtn == nil then FerociousBiteBtn = CreateFrame("Button", spellName, UIParent, "SecureActionButtonTemplate"); end;
		FerociousBiteBtn:SetAttribute("type", "macro");
		FerociousBiteBtn:SetAttribute("macrotext", "/cast [@"..spellType.."] "..spellName)
	end
	
	if 
		ApolloDruid_InMeleeRange == true and
		ApolloDruid_CanAttack == true and 
		ApolloDruid_TargetIsDead == false and
		ApolloDruid_Energy >= 25 and
		ApolloDruid_CatFormBuff == true and
		ApolloDruid_ComboPoints == 5
	then
		spellCast = true
	end
	
	return spellCast, spellName, spellType
	
end

function ApolloDruid_HealingTouch()
	local __func__ = "ApolloDruid_HealingTouch"
	
	local spellName = "Healing Touch"
	local spellType = "focus"
	local spellCast = false
	local castHealth

	ApolloDruid_CreateButtons(__func__, spellName, spellType)
	
	if 
		ApolloDruid_PredatorySwiftness == true
	then 
		spellCast = true
	end
		
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Incarnation()
	local __func__ = "ApolloDruid_Incarnation"

	local spellName = "Incarnation: King of the Jungle"
	local spellType = "focus"
	local spellCast = false
	local castHealth
	
	ApolloDruid_CreateButtons(__func__, spellName, spellType)

	if 
		ApolloDruid_InMeleeRange == true and
		ApolloDruid_CanAttack == true and 
		ApolloDruid_IncarnationCooldown == 0 and
		UnitHealth("target") > UnitHealth("player") * .6 and
		ApolloDruid_CatFormBuff == true
	then 
		spellCast = true
	end
		
	return spellCast, spellName, spellType

end

function ApolloDruid_HealthPotion()
	local __func__ = "ApolloDruid_HealthPotion"

	local potions = {113585}
	local spellName = ""
	local itemCount
	local spellType = "none"
	local spellCast = false
	
	for i = 1,table.getn(potions) do
		itemCount = GetItemCount(potions[i], false, true)
		if itemCount > 0 then
			spellName = GetItemInfo(potions[i])
			break
		end
	end

	ApolloDruid_CreateButtons(__func__, spellName, spellType)
	
	if 
		itemCount >= 1 and
		ApolloDruid_PlayerHealth < .5
	then 
		spellCast = true
	end
		
	return spellCast, spellName, spellType
	
end

function ApolloDruid_Swipe()

	local __func__ = "ApolloDruid_Swipe"

	local spellName = "Swipe"
	local spellType = "target"
	local spellCast = false

	ApolloDruid_CreateButtons(__func__, spellName, spellType)
	
	if 
		ApolloDruid_TargetClassification == "minus" and
		ApolloDruid_Energy >= 50 and
		ApolloDruid_InMeleeRange == true
	then 
		spellCast = true
	end
		
	return spellCast, spellName, spellType
	
end

function ApolloDruid_WildMushroom()

	local __func__ = "ApolloDruid_WildMushroom"

	local spellName = "Wild Mushroom"
	local spellType = ApolloHealer_TANK
	local spellCast = false

	ApolloDruid_CreateButtons(__func__, spellName, spellType)
	
	if 
		ApolloDruid_InCombat == true and
--		GetTotemInfo(1) == false
		(ApolloDruid_WildMushroomTick < time() - 3 or GetTotemInfo(1) == false)
	then 
		spellCast = true
	end
		
	return spellCast, spellName, spellType

end

function ApolloDruid_CreateButtons(Apollo_btnName, Apollo_spellName, Apollo_target)

	Apollo_btnName = Apollo_btnName.."btn"

	if not ApolloDruid_InCombat then
		if _G[Apollo_btnName] == nil then _G[Apollo_btnName] = CreateFrame("Button", string.gsub(Apollo_spellName,":",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[Apollo_btnName]:SetAttribute("type", "macro");
		_G[Apollo_btnName]:SetAttribute("macrotext", "/use [@"..Apollo_target.."] "..Apollo_spellName)
	end
	
end

function ApolloDruid_TestFunction()

local buffs, i = {}, 1;

print (buffs,i)

end

DruidFrame:SetScript("OnEvent", DruidFrame.OnEvent);