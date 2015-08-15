Apollo.Shaman = {}

local AS = Apollo.Shaman

function AS.Periodic()
	Apollo.Diagnostic.TimerStart = GetTime()
	
	local SkillList = {
			AS.LightningShield,
			AS.Purge,
			AS.AutoAttack,
			AS.LightningBolt,
			AS.SearingTotem,
			AS.LavaLash,
			AS.PrimalStrike,
			AS.FlameShock,
			AS.HealingSurge,
			}
	
	for i = 1,table.getn(SkillList) do
	
		local x = SkillList[i]
		if x == nil then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = SkillList[i]()
		
		if (not InCombatLockdown()) and Apollo.RebindKeys then
			SetBinding(Apollo_Ability.KeyBinding[i])
			SetBindingClick(Apollo_Ability.KeyBinding[i], string.gsub(Apollo_Ability.SpellName[i],":",""))
--			print(string.gsub(Apollo_Ability.SpellName[i],":",""))
		end
		
	end
	
	Apollo.RebindKeys = false;
	Apollo.Diagnostic.TimerStop = GetTime()
end

function AS.AutoAttack()
	local __func__ = "AS.AutoAttack"
	local spellName = "Auto Attack"
	local spellTarget = "target"
	
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	
	local isCurrent = IsCurrentSpell(spellID)
	local canAttack = UnitCanAttack("player", spellTarget)
	local isDead = UnitIsDead(spellTarget)
	
	AS.CreateButtons(__func__, spellName, spellTarget)
	
	if (not isCurrent) and canAttack and (not isDead) then
		spellCast = true
	end

	return spellCast, spellName, spellTarget
	
end

function AS.LightningBolt()

	local __func__ = "AS.LightningBolt"
	local spellName = "Lightning Bolt"
	local spellTarget = "target"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local inRange2 = IsSpellInRange("Primal Strike",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (canAttack) and (inRange == 1 and inRange2 == 0) and (not isDead)then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AS.PrimalStrike()

	local __func__ = "AS.PrimalStrike"
	local spellName = "Primal Strike"
	local spellTarget = "target"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local startTime = GetSpellCooldown(spellID) -- startTime = 0 if ready to be cast;
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (canAttack) and (inRange == 1) and (not isDead) and (startTime == 0)then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AS.HealingSurge()

	local __func__ = "AS.HealingSurge"
	local spellName = "Healing Surge"
	local spellTarget = "focus"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local inRange = IsSpellInRange(spellName,spellTarget)
	local health = (UnitHealth(spellTarget) + (UnitGetIncomingHeals(spellTarget) or 0)) / UnitHealthMax(spellTarget)
	local mana = UnitPower("player",0)
	local manaMax = UnitPowerMax("player",0)
	local manaCost = manaMax * .207
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (inRange == 1) and (health < .5) and (mana > manaCost) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AS.LightningShield()

	local __func__ = "AS.LightningShield"
	local spellName = "Lightning Shield"
	local spellTarget = "none"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local buff = UnitBuff("player","Lightning Shield")
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (not buff) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AS.LavaLash()

	local __func__ = "AS.LavaLash"
	local spellName = "Lava Lash"
	local spellTarget = "target"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local startTime = GetSpellCooldown(spellID) -- startTime = 0 if ready to be cast;
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (canAttack) and (inRange == 1) and (not isDead) and (startTime == 0) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AS.FlameShock()

	local __func__ = "AS.FlameShock"
	local spellName = "Flame Shock"
	local spellTarget = "target"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local startTime = GetSpellCooldown(spellID) -- startTime = 0 if ready to be cast;
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (canAttack) and (inRange == 1) and (not isDead) and (startTime == 0) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget

end

function AS.Purge()

	local __func__ = "AS.Purge"
	local spellName = "Purge"
	local spellTarget = "target"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isDead = UnitIsDead(spellTarget)
	
	local name, i, canPurge, dispelType = UnitExists(spellTarget), 1, false, ""
	while name do
		name, _, _, _, dispelType, _, _, _, _, _, spellID, _, _, _, _, _ = UnitBuff(spellTarget, i)
		i = i + 1
		if dispelType == "Magic" then canPurge = true; end;
	end
	
	AS.CreateButtons(__func__, spellName, spellTarget)

	if (canAttack) and (inRange == 1) and (not isDead) and (canPurge) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget

end

function AS.SearingTotem()
	local __func__ = "AS.SearingTotem"
	local spellName = "Searing Totem"
	local spellTarget = "none"
	
	local spellCast = false
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
	
	local inCombat = InCombatLockdown()
	local haveTotem = GetTotemInfo(1)
	
	AS.CreateButtons(__func__, spellName, spellTarget)
	
--	print(inCombat, haveTotem)
	if (inCombat) and (not haveTotem) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget

end

function AS.CreateButtons(a, b, c)

	local btnName, spellName, spellTarget = a .. "btn", b, c

	if not InCombatLockdown() then
		if _G[btnName] == nil then _G[btnName] = CreateFrame("Button", string.gsub(spellName,"%p",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[btnName]:SetAttribute("type", "macro");
		_G[btnName]:SetAttribute("macrotext", "/use [@"..spellTarget.."] "..spellName)
--		print(string.gsub(spellName,"%p",""))
	end
	
end