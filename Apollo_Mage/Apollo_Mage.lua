local MageFrame = CreateFrame("FRAME");
MageFrame:RegisterEvent("ADDON_LOADED");
MageFrame:RegisterEvent("UNIT_POWER_FREQUENT");
MageFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
MageFrame:RegisterEvent("SPELL_UPDATE_USABLE")
MageFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
MageFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- This function is triggered once every frame.
function ApolloMage_OnUpdate(self, elapsed)

	-- resets abilities before check
--	for i = 1,40 do
--		if Apollo_Ability.Cast[i] == nil then break; end;
--		Apollo_Ability.Cast[i] = false
--	end

end

-- This function is triggered once every .2 seconds.
function ApolloMage_Periodic()

--	print("ApolloMage_Periodic() is running.")

	-- THIS SECTION RUNS CHECKS THAT ARE REQUIRED FOR MULTIPLE SKILLS IN ORDER TO AVOID REDUNDANCY.
	local _,_,_,_,_,_,_,_,a = UnitCastingInfo("target")	
	local _,_,_,_,_,_,_,b = UnitChannelInfo("target")	
	if a == false or b == false then ApolloMage_TargetInterruptable = true else ApolloMage_TargetInterruptable = false; end;	-- DETERMINES IF THE TARGETS SPELL CAN BE INTERUPTED
	
		-- HEALTH CALCULATIONS --
		ApolloMage_PlayerHealthMax = UnitHealthMax("player")
		ApolloMage_PlayerHealth = UnitHealth("player")
		ApolloMage_PlayerHealthPct = ApolloMage_PlayerHealth / ApolloMage_PlayerHealthMax	-- DETERMINES THE PLAYERS PERCENTAGE HEALTH
		
		ApolloMage_TargetHealth = UnitHealth("target")								-- DETERMINES THE ACTUAL HEALTH OF THE PLAYERS TARGET.
	
	ApolloMage_CanAttack = UnitCanAttack("player", "target")					-- DETERMINES IF THE PLAYERS CURRENT TARGET CAN BE ATTACKED
	ApolloMage_AffectingCombat = UnitAffectingCombat("target");					-- RETURNS TRUE IF THE PLAYERS TARGET IS IN COMBAT.
	ApolloMage_ComboPoints = UnitPower("player",4)								-- DETERMINES HOW MANY COMBO POINTS THE PLAYER CURRENTLY HAS
	ApolloMage_InCombat = InCombatLockdown()									-- DETERMINES IF THE PLAYER IS IN COMBAT
	_,_,ApolloMage_TargetClass = UnitClass("target")							-- DETERMINES THE TARGETS CLASS
	ApolloMage_TargetIsPlayerControlled = UnitPlayerControlled("target")		-- RETURNS TRUE IF THE TARGET IS CONTROLLED BY ANOTHER PLAYER
	ApolloMage_IsMounted = IsMounted()											-- RETURNS TRUE IF THE PLAYER IS MOUNTED
	
	if IsSpellInRange("Frostfire Bolt", "target") == 1 then						--
		ApolloMage_In40Range = true else ApolloMage_In40Range = false			-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS IN 40 YARD RANGE.
	end																				--
	
	-- COOLDOWN CHECKS --
	_,ApolloMage_EvasionCooldown,_ = GetSpellCooldown("Evasion")
	_,ApolloMage_KickCooldown,_ = GetSpellCooldown("Kick")
	_,ApolloMage_VanishCooldown,_ = GetSpellCooldown("Vanish")
	_,ApolloMage_AdrenalineRushCooldown,_ = GetSpellCooldown("Adrenaline Rush")
	_,ApolloMage_KidneyShotCooldown,_ = GetSpellCooldown("Kidney Shot")
	_,ApolloMage_CloakOfShadowsCooldown,_ = GetSpellCooldown("Cloak of Shadows")
	_,ApolloMage_CombatReadinessCooldown,_ = GetSpellCooldown("Combat Readiness")
	_,ApolloMage_ShivCooldown,_ = GetSpellCooldown("Shiv")
	_,ApolloMage_KillingSpreeCooldown,_ = GetSpellCooldown("Killing Spree")
	
	-- THIS SCAN PERFORMS BUFF CHECKS ON THE PLAYER TO DETERMINE IF ANY BUFFS NEEDED FOR ABILITY TRIGGERS ARE ACTIVE
	ApolloMage_Stealth = false				-- ASSIGNS DEFAULT VALUE
	ApolloMage_SliceAndDiceBuff = false	-- ASSIGNS DEFAULT VALUE
	ApolloMage_Subterfuge = false			-- ASSIGNS DEFAULT VALUE
	ApolloMage_RecuperateBuff = false		-- ASSIGNS DEFAULT VALUE
	ApolloMage_VanishBuff = false
	ApolloMage_RevealingStrikeDebuff = false
	ApolloMage_CheapShotDebuff = false
	ApolloMage_GarroteDebuff = false
	ApolloMage_SurvivalBuff = false
	ApolloMage_LeechingPoisonBuff = false
	ApolloMage_BladeFlurryBuff = false
	ApolloMage_HoldBack = false
	
	for i = 1,40 do														-- SCANS EACH PLAYER BUFF ONE AT A TIME
		local name = UnitBuff("player",i);								-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Stealth" then ApolloMage_Stealth = true; end;					-- CHECKS IF THE PLAYER IS STEALTHED
		if name == "Slice and Dice" then ApolloMage_SliceAndDiceBuff = true; end;	-- CHECKS IF THE PLAYER HAS SLICE AND DICE
		if name == "Subterfuge" then ApolloMage_Subterfuge = true; end;			-- CHECKS IF THE PLAYER HAS SUBTERFUGE
		if name == "Recuperate" then ApolloMage_RecuperateBuff = true; end;		-- CHECKS IF THE PLAYER HAS RECUPERATE
		if name == "Vanish" then ApolloMage_VanishBuff = true; end;				-- CHECKS IF THE PLAYER HAS VANISH
		if name == "Evasion" then ApolloMage_SurvivalBuff = true; end;
		if name == "Cloak of Shadows" then ApolloMage_SurvivalBuff = true; end;
		if name == "Combat Readiness" then ApolloMage_SurvivalBuff = true; end;
		if name == "Leeching Poison" then ApolloMage_LeechingPoisonBuff = true; end;
		if name == "Blade Flurry" then ApolloMage_BladeFlurryBuff = true; end;
	end
	
	for i = 1,40 do														-- SCANS EACH TARGET BUFF ONE AT A TIME
		local name = UnitDebuff("target",i);							-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
		if name == "Revealing Strike" then ApolloMage_RevealingStrikeDebuff = true; end;					-- CHECKS IF THE TARGET HAS REVEALING STRIKE
		if name == "Cheap Shot" then ApolloMage_CheapShotDebuff = true; end;								-- CHECKS IF THE TARGET HAS CHEAP SHOT
		if name == "Garrote" then ApolloMage_CheapShotDebuff = true; end;									-- CHECKS IF THE TARGET HAS Garrote
	end
	
	for i = 1,40 do
		local name = UnitBuff("target",i);
		if name == nil then break; end;
		
		if name == "Protection Shield" then ApolloMage_HoldBack = true; end;
	
	end
	
	-- ABILITY FUNCTIONS ARE TRIGGERED HERE AND THE RESPONSES SENT TO APOLLO_CORE.LUA
	
	ApolloMage_SkillList = {
		"ApolloMage_FrostfireBolt",
		}
	
	if ApolloMage_IsMounted == true then return; end;

	for i = 1,40 do
	
		local x = ApolloMage_SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i] = _G[x]()
		
	end

end

-- This function runs in response to ingame events.
function MageFrame:OnEvent(event, arg1)

	-- Fired when the addon "Apollo" is loaded.
	if event == "ADDON_LOADED" and arg1 == "Apollo" then
		
	end
	
	-- Fires when the player loads the game world.
	if event == "PLAYER_ENTERING_WORLD" then
		print("Apollo: Mage module is loaded.")
		
		-- Assigns Spell Keybindings
		ApolloMage_Periodic()
		for i = 1,40 do
			if Apollo_Ability.SpellName[i] == nil then break; end;
			SetBindingSpell(Apollo_Ability.KeyBinding[i],Apollo_Ability.SpellName[i])
		end
		
	end
	
end

function ApolloMage_FrostfireBolt()
	local spell = "Frostfire Bolt"
	
	if ApolloMage_In40Range == false then return false, spell; end;
	if ApolloMage_CanAttack == false then return false, spell; end;
	if ApolloMage_AffectingCombat == false then return false, spell; end;
	
	return true, spell;
	
end

MageFrame:SetScript("OnEvent", MageFrame.OnEvent);