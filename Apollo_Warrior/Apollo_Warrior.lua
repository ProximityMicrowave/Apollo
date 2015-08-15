local WarriorFrame = CreateFrame("FRAME");
WarriorFrame:RegisterEvent("ADDON_LOADED");
WarriorFrame:RegisterEvent("UNIT_POWER_FREQUENT");
WarriorFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
WarriorFrame:RegisterEvent("SPELL_UPDATE_USABLE")
WarriorFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
WarriorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- This function is triggered once every frame.
function ApolloWarrior_OnUpdate(self, elapsed)

	-- resets abilities before check
--	for i = 1,40 do
--		if Apollo_Ability.Cast[i] == nil then break; end;
--		Apollo_Ability.Cast[i] = false
--	end

end

-- This function is triggered once every .2 seconds.
function ApolloWarrior_Periodic()

--	print("ApolloWarrior_Periodic() is running.")

	-- THIS SECTION RUNS CHECKS THAT ARE REQUIRED FOR MULTIPLE SKILLS IN ORDER TO AVOID REDUNDANCY.
	local _,_,_,_,_,_,_,_,a = UnitCastingInfo("target")	
	local _,_,_,_,_,_,_,b = UnitChannelInfo("target")	
	if a == false or b == false then ApolloWarrior_TargetInterruptable = true else ApolloWarrior_TargetInterruptable = false; end;	-- DETERMINES IF THE TARGETS SPELL CAN BE INTERUPTED
	
		-- HEALTH CALCULATIONS --
		ApolloWarrior_PlayerHealthMax = UnitHealthMax("player")
		ApolloWarrior_PlayerHealth = UnitHealth("player")
		ApolloWarrior_PlayerHealthPct = ApolloWarrior_PlayerHealth / ApolloWarrior_PlayerHealthMax	-- DETERMINES THE PLAYERS PERCENTAGE HEALTH
		
		ApolloWarrior_TargetHealth = UnitHealth("target")								-- DETERMINES THE ACTUAL HEALTH OF THE PLAYERS TARGET.
	
	ApolloWarrior_CanAttack = UnitCanAttack("player", "target")					-- DETERMINES IF THE PLAYERS CURRENT TARGET CAN BE ATTACKED
	ApolloWarrior_Rage = UnitPower("player");									-- DETERMINES HOW MUCH ENERGY THE PLAYER CURRENT HAS FOR ABILITIES
	ApolloWarrior_ComboPoints = UnitPower("player",4)								-- DETERMINES HOW MANY COMBO POINTS THE PLAYER CURRENTLY HAS
	ApolloWarrior_InCombat = InCombatLockdown()									-- DETERMINES IF THE PLAYER IS IN COMBAT
	_,_,ApolloWarrior_TargetClass = UnitClass("target")							-- DETERMINES THE TARGETS CLASS
	ApolloWarrior_TargetIsPlayerControlled = UnitPlayerControlled("target")		-- RETURNS TRUE IF THE TARGET IS CONTROLLED BY ANOTHER PLAYER
	ApolloWarrior_IsMounted = IsMounted()											-- RETURNS TRUE IF THE PLAYER IS MOUNTED
	
	if IsSpellInRange("Heroic Strike", "target") == 1 then						--
		ApolloWarrior_InMeleeRange = true else ApolloWarrior_InMeleeRange = false		-- THIS CHECK DETERMINES IF THE PLAYERS TARGET IS IN MELEE RANGE.
	end																				--
	
	-- COOLDOWN CHECKS --
	_,ApolloWarrior_HeroicStrikeCooldown,_ = GetSpellCooldown("Heroic Strike")

	
	-- THIS SCAN PERFORMS BUFF CHECKS ON THE PLAYER TO DETERMINE IF ANY BUFFS NEEDED FOR ABILITY TRIGGERS ARE ACTIVE
	ApolloWarrior_Stealth = false				-- ASSIGNS DEFAULT VALUE
	
	for i = 1,40 do														-- SCANS EACH PLAYER BUFF ONE AT A TIME
		local name = UnitBuff("player",i);								-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
--		if name == "Stealth" then ApolloWarrior_Stealth = true; end;					-- CHECKS IF THE PLAYER IS STEALTHED
	end
	
	for i = 1,40 do														-- SCANS EACH TARGET BUFF ONE AT A TIME
		local name = UnitDebuff("target",i);							-- GETS THE NAME OF THE BUFF IN THE CURRENTLY SCANNED SLOT
		if name == nil then break; end;									-- IF NO MORE BUFFS ARE FOUND, THE LOOP IS BROKEN
		
--		if name == "Revealing Strike" then ApolloWarrior_RevealingStrikeDebuff = true; end;					-- CHECKS IF THE TARGET HAS REVEALING STRIKE
	end
	
	-- ABILITY FUNCTIONS ARE TRIGGERED HERE AND THE RESPONSES SENT TO APOLLO_CORE.LUA
	
	ApolloWarrior_SkillList = {
		"ApolloWarrior_AutoAttack",
		"ApolloWarrior_HeroicStrike",
		}
	
	if ApolloWarrior_IsMounted == true then return; end;
	for i = 1,40 do
	
		local x = ApolloWarrior_SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i] = _G[x]()
		
	end

end

-- This function runs in response to ingame events.
function WarriorFrame:OnEvent(event, arg1)

	-- Fired when the addon "Apollo" is loaded.
	if event == "ADDON_LOADED" and arg1 == "Apollo" then
		
	end
	
	-- Fires when the player loads the game world.
	if event == "PLAYER_ENTERING_WORLD" then
		print("Apollo: Rogue module is loaded.")
		
		-- Assigns Spell Keybindings
		ApolloWarrior_Periodic()
		for i = 1,40 do
			if Apollo_Ability.SpellName[i] == nil then break; end;
			SetBindingSpell(Apollo_Ability.KeyBindging[i],Apollo_Ability.SpellName[i])
		end
		
	end
	
end

-- Checks to see if Auto Attack should be used.
function ApolloWarrior_AutoAttack()

	local isCurrent = IsCurrentSpell("Auto Attack")		-- Determines if Auto Attack is already activated.
	
	if ApolloWarrior_InMeleeRange == true and ApolloWarrior_CanAttack == true and isCurrent == false then
		return true, "Auto Attack"
	end
	
	return false, "Auto Attack"
	
end

function ApolloWarrior_HeroicStrike()
	
	if ApolloWarrior_InMeleeRange == true and ApolloWarrior_CanAttack == true and ApolloWarrior_HeroicStrikeCooldown == 0 and ApolloWarrior_Rage > 30 then
		return true, "Heroic Strike"
	end
	
	return false, "Heroic Strike"
	
end


WarriorFrame:SetScript("OnEvent", WarriorFrame.OnEvent);