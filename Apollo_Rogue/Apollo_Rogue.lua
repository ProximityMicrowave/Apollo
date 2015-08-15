local RogueFrame = CreateFrame("FRAME");
RogueFrame:RegisterEvent("ADDON_LOADED");
RogueFrame:RegisterEvent("UNIT_POWER_FREQUENT");
RogueFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
RogueFrame:RegisterEvent("SPELL_UPDATE_USABLE")
RogueFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
RogueFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- This function is triggered once every frame.
function ApolloRogue_OnUpdate(self, elapsed)

	-- resets abilities before check
--	for i = 1,40 do
--		if Apollo_Ability.Cast[i] == nil then break; end;
--		Apollo_Ability.Cast[i] = false
--	end

end

-- This function is triggered once every .2 seconds.
function ApolloRogue_Periodic()

--	print("ApolloRogue_Periodic() is running.")

	-- THIS SECTION RUNS CHECKS THAT ARE REQUIRED FOR MULTIPLE SKILLS IN ORDER TO AVOID REDUNDANCY.
	local _,_,_,_,_,_,_,_,a = UnitCastingInfo("target")	
	local _,_,_,_,_,_,_,b = UnitChannelInfo("target")	
	if a == false or b == false then ApolloRogue_TargetInterruptable = true else ApolloRogue_TargetInterruptable = false; end;	-- DETERMINES IF THE TARGETS SPELL CAN BE INTERUPTED
	
		-- HEALTH CALCULATIONS --
		ApolloRogue_PlayerHealthMax = UnitHealthMax("player")
		ApolloRogue_PlayerHealth = UnitHealth("player")
		ApolloRogue_PlayerHealthPct = ApolloRogue_PlayerHealth / ApolloRogue_PlayerHealthMax	-- DETERMINES THE PLAYERS PERCENTAGE HEALTH
		
		ApolloRogue_TargetHealth = UnitHealth("target")								-- DETERMINES THE ACTUAL HEALTH OF THE PLAYERS TARGET.
	
	ApolloRogue_CanAttack = UnitCanAttack("player", "target")					-- DETERMINES IF THE PLAYERS CURRENT TARGET CAN BE ATTACKED
	ApolloRogue_Energy = UnitPower("player");									-- DETERMINES HOW MUCH ENERGY THE PLAYER CURRENT HAS FOR ABILITIES
	ApolloRogue_ComboPoints = UnitPower("player",4)								-- DETERMINES HOW MANY COMBO POINTS THE PLAYER CURRENTLY HAS
	ApolloRogue_InCombat = InCombatLockdown()									-- DETERMINES IF THE PLAYER IS IN COMBAT
	_,_,ApolloRogue_TargetClass = UnitClass("target")							-- DETERMINES THE TARGETS CLASS
	ApolloRogue_TargetIsPlayerControlled = UnitPlayerControlled("target")		-- RETURNS TRUE IF THE TARGET IS CONTROLLED BY ANOTHER PLAYER
	ApolloRogue_IsMounted = IsMounted()											-- RETURNS TRUE IF THE PLAYER IS MOUNTED
	
	if IsSpellInRange("Sinister Strike", "target") == 1 then						--
		ApolloRogue_InMeleeRange = true else ApolloRogue_InMeleeRange = false		-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS IN MELEE RANGE.
	end																				--
	
	-- COOLDOWN CHECKS --
	_,ApolloRogue_EvasionCooldown,_ = GetSpellCooldown("Evasion")
	_,ApolloRogue_KickCooldown,_ = GetSpellCooldown("Kick")
	_,ApolloRogue_VanishCooldown,_ = GetSpellCooldown("Vanish")
	_,ApolloRogue_AdrenalineRushCooldown,_ = GetSpellCooldown("Adrenaline Rush")
	_,ApolloRogue_KidneyShotCooldown,_ = GetSpellCooldown("Kidney Shot")
	_,ApolloRogue_CloakOfShadowsCooldown,_ = GetSpellCooldown("Cloak of Shadows")
	_,ApolloRogue_CombatReadinessCooldown,_ = GetSpellCooldown("Combat Readiness")
	_,ApolloRogue_ShivCooldown,_ = GetSpellCooldown("Shiv")
	_,ApolloRogue_KillingSpreeCooldown,_ = GetSpellCooldown("Killing Spree")
	_,ApolloRogue_PotionCooldown,_ = GetItemCooldown(109223)
	
	-- THIS SCAN PERFORMS BUFF CHECKS ON THE PLAYER TO DETERMINE IF ANY BUFFS NEEDED FOR ABILITY TRIGGERS ARE ACTIVE
	ApolloRogue_Stealth = false				-- ASSIGNS DEFAULT VALUE
	ApolloRogue_SliceAndDiceBuff = false	-- ASSIGNS DEFAULT VALUE
	ApolloRogue_Subterfuge = false			-- ASSIGNS DEFAULT VALUE
	ApolloRogue_RecuperateBuff = false		-- ASSIGNS DEFAULT VALUE
	ApolloRogue_VanishBuff = false
	ApolloRogue_RevealingStrikeDebuff = false
	ApolloRogue_CheapShotDebuff = false
	ApolloRogue_GarroteDebuff = false
	ApolloRogue_SurvivalBuff = false
	ApolloRogue_LeechingPoisonBuff = false
	ApolloRogue_BladeFlurryBuff = false
	ApolloRogue_HoldBack = false
	
	for i = 1,40 do														-- SCANS EACH PLAYER BUFF ONE AT A TIME
		local name = UnitBuff("player",i);								-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Stealth" then ApolloRogue_Stealth = true; end;					-- CHECKS IF THE PLAYER IS STEALTHED
		if name == "Slice and Dice" then ApolloRogue_SliceAndDiceBuff = true; end;	-- CHECKS IF THE PLAYER HAS SLICE AND DICE
		if name == "Subterfuge" then ApolloRogue_Subterfuge = true; end;			-- CHECKS IF THE PLAYER HAS SUBTERFUGE
		if name == "Recuperate" then ApolloRogue_RecuperateBuff = true; end;		-- CHECKS IF THE PLAYER HAS RECUPERATE
		if name == "Vanish" then ApolloRogue_VanishBuff = true; end;				-- CHECKS IF THE PLAYER HAS VANISH
		if name == "Evasion" then ApolloRogue_SurvivalBuff = true; end;
		if name == "Cloak of Shadows" then ApolloRogue_SurvivalBuff = true; end;
		if name == "Combat Readiness" then ApolloRogue_SurvivalBuff = true; end;
		if name == "Leeching Poison" then ApolloRogue_LeechingPoisonBuff = true; end;
		if name == "Blade Flurry" then ApolloRogue_BladeFlurryBuff = true; end;
	end
	
	for i = 1,40 do														-- SCANS EACH TARGET BUFF ONE AT A TIME
		local name = UnitDebuff("target",i);							-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Revealing Strike" then ApolloRogue_RevealingStrikeDebuff = true; end;					-- CHECKS IF THE TARGET HAS REVEALING STRIKE
		if name == "Cheap Shot" then ApolloRogue_CheapShotDebuff = true; end;								-- CHECKS IF THE TARGET HAS CHEAP SHOT
		if name == "Garrote" then ApolloRogue_CheapShotDebuff = true; end;									-- CHECKS IF THE TARGET HAS Garrote
	end
	
	for i = 1,40 do
		local name = UnitBuff("target",i);
		if name == nil then break; end;
		
		if name == "Protection Shield" then ApolloRogue_HoldBack = true; end;
	
	end
	
	-- ABILITY FUNCTIONS ARE TRIGGERED HERE AND THE RESPONSES SENT TO APOLLO_CORE.LUA
	
	ApolloRogue_SkillList = {
		"ApolloRogue_AutoAttack",
		"ApolloRogue_SinisterStrike",
		"ApolloRogue_Eviscerate",
	--	"ApolloRogue_CrimsonTempest",
	--	"ApolloRogue_KidneyShot",
		"ApolloRogue_SliceAndDice",
	--	"ApolloRogue_RevealingStrike",
	--	"ApolloRogue_Recuperate",
	--	"ApolloRogue_Ambush",
	--	"ApolloRogue_CheapShot",
	--	"ApolloRogue_Garrote",
	--	"ApolloRogue_KillingSpree",
	--	"ApolloRogue_AdrenalineRush",
	--	"ApolloRogue_Shiv",
	--	"ApolloRogue_Kick",
	--	"ApolloRogue_CombatReadiness",
	--	"ApolloRogue_Evasion",
	--	"ApolloRogue_CloakOfShadows",
	--	"ApolloRogue_Vanish",
	--	"ApolloRogue_Preparation",
	--	"ApolloRogue_HealingTonic",
		}
	
	if ApolloRogue_IsMounted == true then return; end;
	if ApolloRogue_VanishBuff == true then return; end;
	for i = 1,40 do
	
		local x = ApolloRogue_SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = _G[x]()
		
	end

end

-- This function runs in response to ingame events.
function RogueFrame:OnEvent(event, arg1)

	-- Fired when the addon "Apollo" is loaded.
	if event == "ADDON_LOADED" and arg1 == "Apollo" then
		
	end
	
	-- Fires when the player loads the game world.
	if event == "PLAYER_ENTERING_WORLD" then
		print("Apollo: Rogue module is loaded.")
		
		-- Assigns Spell Keybindings
		ApolloRogue_Periodic()
		for i = 1,40 do
			if Apollo_Ability.SpellName[i] == nil then break; end;
			if Apollo_Ability.Type[i] == "Spell" then SetBindingSpell(Apollo_Ability.KeyBinding[i],Apollo_Ability.SpellName[i]); end;
			if Apollo_Ability.Type[i] == "Item" then SetBindingItem(Apollo_Ability.KeyBinding[i],Apollo_Ability.SpellName[i]); end;
		end
		
--[[
		SetBindingSpell(Apollo_Ability.KeyBinding[1],Apollo_Ability.SpellName[1])
		SetBindingSpell("NUMPAD2",Apollo_Ability.SpellName[2])
		SetBindingSpell("NUMPAD3",Apollo_Ability.SpellName[3])
		SetBindingSpell("NUMPAD4",Apollo_Ability.SpellName[4])
		SetBindingSpell("NUMPAD5",Apollo_Ability.SpellName[5])
		SetBindingSpell("NUMPAD6",Apollo_Ability.SpellName[6])
		SetBindingSpell("NUMPAD7",Apollo_Ability.SpellName[7])
		SetBindingSpell("NUMPAD8",Apollo_Ability.SpellName[8])
		SetBindingSpell("NUMPAD9",Apollo_Ability.SpellName[9])
]]--
	end
	
end

-- Checks to see if Auto Attack should be used.
function ApolloRogue_AutoAttack()

	local isCurrent = IsCurrentSpell("Auto Attack")		-- Determines if Auto Attack is already activated.
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_CanAttack == true and isCurrent == false then
		return true, "Auto Attack", "Spell"
	end
	
	return false, "Auto Attack", "Spell"
	
end

function ApolloRogue_SinisterStrike()
	
	if ApolloRogue_InMeleeRange == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_Energy > 60 then
			return true, "Sinister Strike", "Spell"
		end
	end
	
	return false, "Sinister Strike", "Spell"
	
end

function ApolloRogue_Eviscerate()

	if ApolloRogue_HoldBack == true then return false, "Eviscerate"; end;
	
	if ApolloRogue_InMeleeRange == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_ComboPoints >= 5 and ApolloRogue_Energy > 35 then
			return true, "Eviscerate", "Spell"
		end
	end
	
	return false, "Eviscerate", "Spell"
	
end

function ApolloRogue_CrimsonTempest()
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_BladeFlurryBuff == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_ComboPoints >= 5 and ApolloRogue_Energy > 35 then
			return true, "Crimson Tempest", "Spell"
		end
	end
	
	return false, "Crimson Tempest", "Spell"
	
end

function ApolloRogue_KidneyShot()
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_TargetIsPlayerControlled == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_ComboPoints >= 5 and ApolloRogue_Energy > 25 and ApolloRogue_KidneyShotCooldown == 0 then
			return true, "Kidney Shot", "Spell"
		end
	end
	
	return false, "Kidney Shot", "Spell"
	
end

function ApolloRogue_SliceAndDice()

	if IsUsableSpell("Slice and Dice") == false then
		return false, "Slice and Dice", "Spell"
	end
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_ComboPoints >= 1 and ApolloRogue_SliceAndDiceBuff == false and ApolloRogue_Energy > 25 and ApolloRogue_InCombat == true then
		return true, "Slice and Dice", "Spell"
	end
	
	return false, "Slice and Dice", "Spell"
	
end
	

function ApolloRogue_Ambush()
	
	if ApolloRogue_InMeleeRange == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_Energy > 60 and (ApolloRogue_Stealth == true or ApolloRogue_Subterfuge == true) then
			return true, "Ambush", "Spell"
		end
	end
	
	return false, "Ambush", "Spell"
	
end

function ApolloRogue_CheapShot()
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_TargetIsPlayerControlled == true then
		if ApolloRogue_CanAttack == true and ApolloRogue_Energy > 60 and ApolloRogue_CheapShotDebuff == false and (ApolloRogue_Stealth == true or ApolloRogue_Subterfuge == true) then
			return true, "Cheap Shot", "Spell"
		end
	end
	
	return false, "Cheap Shot", "Spell"
	
end

function ApolloRogue_Garrote()

	local TC = ApolloRogue_TargetClass
	if ApolloRogue_InMeleeRange == true and ApolloRogue_TargetIsPlayerControlled == true and (TC == 2 or TC == 5 or TC == 7 or TC == 8 or TC == 9 or TC == 11) then
	if ApolloRogue_CanAttack == true and ApolloRogue_Energy > 60 and ApolloRogue_GarroteDebuff == false and (ApolloRogue_Stealth == true or ApolloRogue_Subterfuge == true) then
			return true, "Garrote", "Spell"
		end
	end
	
	return false, "Garrote", "Spell"

end

function ApolloRogue_CombatReadiness()

		if ApolloRogue_PlayerHealthPct < .6 and ApolloRogue_InCombat == true and ApolloRogue_CombatReadinessCooldown == 0 and ApolloRogue_SurvivalBuff == false then
		return true, "Combat Readiness", "Spell"
	end
	
	return false, "Combat Readiness", "Spell"

end

function ApolloRogue_Evasion()

	if ApolloRogue_PlayerHealthPct < .6 and ApolloRogue_InCombat == true and ApolloRogue_EvasionCooldown == 0 and ApolloRogue_SurvivalBuff == false then
		return true, "Evasion", "Spell"
	end
	
	return false, "Evasion", "Spell"
	
end

function ApolloRogue_CloakOfShadows()

	if ApolloRogue_PlayerHealthPct < .6 and ApolloRogue_InCombat == true and ApolloRogue_CloakOfShadowsCooldown == 0 and ApolloRogue_SurvivalBuff == false then
		return true, "Cloak of Shadows", "Spell"
	end
	
	return false, "Cloak of Shadows", "Spell"
	
end

function ApolloRogue_Recuperate()

	if ApolloRogue_PlayerHealthPct < .8 and ApolloRogue_RecuperateBuff == false and ApolloRogue_ComboPoints >= 1 then
		return true, "Recuperate", "Spell"
	end
	
	return false, "Recuperate", "Spell"
	
end

function ApolloRogue_Kick()

	if ApolloRogue_TargetInterruptable == true and ApolloRogue_KickCooldown == 0 then 
		return true, "Kick", "Spell"
	end
	
	return false, "Kick", "Spell"

end

function ApolloRogue_RevealingStrike()

	if ApolloRogue_InMeleeRange == true and ApolloRogue_CanAttack == true and ApolloRogue_Energy > 40 and ApolloRogue_RevealingStrikeDebuff == false then
		return true, "Revealing Strike", "Spell"
	end
	
	return false, "Revealing Strike", "Spell"
	
end

function ApolloRogue_Vanish()

	if ApolloRogue_PlayerHealthPct < .3 and ApolloRogue_VanishCooldown == 0 and ApolloRogue_InCombat == true then
		return true, "Vanish", "Spell"
	end
	
	return false, "Vanish", "Spell"

end

function ApolloRogue_Preparation()

	if ApolloRogue_PlayerHealthPct < .3 and ApolloRogue_VanishCooldown ~= 0 and ApolloRogue_InCombat == true then
		return true, "Preparation", "Spell"
	end
	
	return false, "Preparation", "Spell"

end

function ApolloRogue_AdrenalineRush()

	if ApolloRogue_HoldBack == true then return false, "Adrenaline Rush"; end;

	if ApolloRogue_Energy < 60 and ApolloRogue_CanAttack == true and ApolloRogue_InCombat == true and ApolloRogue_AdrenalineRushCooldown == 0 and ApolloRogue_TargetHealth > ApolloRogue_PlayerHealth * .60 then
		return true, "Adrenaline Rush", "Spell"
	end
	
	return false, "Adrenaline Rush", "Spell"
	
end

function ApolloRogue_Shiv()
	
	if ApolloRogue_InMeleeRange == true and ApolloRogue_ShivCooldown == 0 then
		if ApolloRogue_CanAttack == true and ApolloRogue_Energy > 20 and ApolloRogue_PlayerHealthPct < .8 and ApolloRogue_LeechingPoisonBuff == true then
			return true, "Shiv", "Spell"
		end
	end
	
	return false, "Shiv", "Spell"
	
end

function ApolloRogue_KillingSpree()

	if ApolloRogue_HoldBack == true then return false, "Killing Spree"; end
	if GetUnitName("target") == "Ritual of Bones" then return false, "Killing Spree"; end

	if ApolloRogue_CanAttack == true and ApolloRogue_InCombat == true and ApolloRogue_KillingSpreeCooldown == 0 and ApolloRogue_TargetHealth > ApolloRogue_PlayerHealth * .60 then
		return true, "Killing Spree", "Spell"
	end
	
	return false, "Killing Spree", "Spell"
	
end

function ApolloRogue_HealingTonic()

	local x = "Item"
	local spell = "Healing Tonic"

	if ApolloRogue_PlayerHealthPct > .3 then return false, spell, x; end;
	if ApolloRogue_PotionCooldown > 0 then return false, spell, x; end;
	
	return true, spell, x;
	
end

RogueFrame:SetScript("OnEvent", RogueFrame.OnEvent);