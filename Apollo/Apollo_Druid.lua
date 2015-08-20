Apollo.Druid = {}

local AD = Apollo.Druid
AD.WildMushroomTick = 0

function AD.Periodic()
	Apollo.Diagnostic.TimerStart = GetTime()
	AD.glyphSocket = {}
	for i = 1,6 do
		_, _, _, AD.glyphSocket[i], _ = GetGlyphSocketInfo(i);
	end
	
	local Spec = GetSpecialization()
	local SkillList = {}
	
	if not Spec then
		SkillList = {
				AD.AutoAttack,
				AD.Wrath,
				AD.Moonfire,
				AD.Rejuvenation,
				AD.Shred,
				AD.FerociousBite,
				AD.Mangle,
				AD.HealthPotion,
				}
	end
	
	if Spec == 2 then
		SkillList = {
				AD.AutoAttack,		--Any Form
				AD.Wrath,			--Humanoid
				AD.Moonfire,		--Humanoid
				AD.HealingTouch,	--Cat/Humanoid
				AD.Rejuvenation,	--Cat/Humanoid
				AD.Shred,			--Cat Form
				AD.Rake,			--Cat Form
				AD.FerociousBite,	--Cat Form
				AD.Rip,				--Cat Form
				AD.Mangle,			--Bear Form
				AD.Rebirth,			--Any Form
--				AD.HealthPotion,
				}
	end
	
	if Spec == 4 then 
			SkillList = {
				AD.AutoAttack,
				AD.Wrath,			--Humanoid
				AD.WildMushroom,
				AD.HealingTouch,	--Humanoid
				AD.Regrowth,		--Humanoid
				AD.Rejuvenation,	--Humanoid
				AD.Lifebloom,		--Humanoid
				AD.Swiftmend,		--Humanoid
				AD.Ironbark,		--Humanoid
				AD.NaturesSwiftness,--Any Form
				AD.WildGrowth,		--Humanoid
				AD.Tranquility,		--Humanoid
				AD.NaturesCure,		--Humanoid
				AD.Shred,			--Cat Form
				AD.FerociousBite,	--Cat Form
				AD.Mangle,			--Bear Form
				AD.Rebirth,			--Any Form
--				AD.HealthPotion,
				}
	end
	
	for i = 1,table.getn(SkillList) do
	
		if not SkillList[i] then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = SkillList[i]()
		
		if (not InCombatLockdown()) and Apollo.RebindKeys then
			SetBinding(Apollo_Ability.KeyBinding[i])
			SetBindingClick(Apollo_Ability.KeyBinding[i], string.gsub(Apollo_Ability.SpellName[i],"%p",""))
		end
		
	end
	
	Apollo.RebindKeys = false;
	Apollo.Diagnostic.TimerStop = GetTime()
end

function AD.AutoAttack()
	local __func__ = "Apollo.Druid.AutoAttack"

	local spellCast = false
	local spellName = "Auto Attack"
	local spellTarget = "target"

	local isCurrent = IsCurrentSpell(spellName)
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange("Shred",spellTarget) or 1
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) and (canAttack) and (not isDead) and (not isCurrent) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.Wrath()
	local __func__ = "Apollo.Druid.Wrath"

	local spellCast = false
	local spellName = "Wrath"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local formName = AD.ShapeshiftForm()
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (ApolloHealer_Below75 == 0)
	and (formName == "Humanoid")
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
	
end

function AD.Moonfire()
	local __func__ = "Apollo.Druid.Moonfire"

	local spellCast = false
	local spellName = "Moonfire"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local debuff = UnitDebuff(spellTarget,spellName)
	local formName = AD.ShapeshiftForm()
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) and (canAttack) and (not isDead) and (startTime == 0) and (not debuff) and (formName == "Humanoid") then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.Rejuvenation()
	local __func__ = "Apollo.Druid.Rejuvenation"
	
	local spellCast = false
	local spellName = "Rejuvenation"
	local spellTarget = "focus"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local buff = UnitBuff(spellTarget,spellName)
	local clearcasting = UnitBuff("player","Clearcasting")
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local enhRejv = IsUsableSpell("Enhanced Rejuvenation")
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (not clearcasting)
	and (inRange == 1) 
	and (not buff) 
	and (healthPct < 1) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	if (not isDead) 
	and (not clearcasting)
	and (inRange == 1) 
	and (not buff) 
	and (healthPct < 1) 
	and (enhRejv) 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget

end

function AD.Swiftmend()
	local __func__ = "Apollo.Druid.Swiftmend"
	
	local spellCast = false
	local spellName = "Swiftmend"
	local spellTarget = "focus"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local buff = UnitBuff(spellTarget,"Rejuvenation")
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (inRange == 1) 
	and (buff) 
	and (healthPct < .75) 
	and (startTime == 0) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function AD.Regrowth()
	local __func__ = "Apollo.Druid.Regrowth"
	
	local spellCast = false
	local spellName = "Regrowth"
	local spellTarget = "focus"

	local name, _, _, castTime, minRange, maxRange = GetSpellInfo(spellName)
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local formName = AD.ShapeshiftForm()
	local globalcooldown = GetSpellCooldown("Wrath")
	local buff,_,_,_,_,_,buffExpires = UnitBuff("player","Clearcasting")
--	print((buffExpires or 0) - GetTime())
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local level = UnitLevel("player")
	local glyphFound = false
	local _,noMana = IsUsableSpell("Wild Growth")
	for _,v in pairs(AD.glyphSocket) do
		if v == 116218 then
			glyphFound = true
			break
		end
	end
	
	
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (glyphFound == true) 
	and (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (healthPct < .75) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	if (glyphFound == true) 
	and (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (buff)
	and (healthPct < 1) 
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	if (level < 26) 
	and (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (healthPct < .75) 
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	if (level >= 26) 
	and (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (healthPct < .5) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
	
end

function AD.HealingTouch()
	local __func__ = "Apollo.Druid.HealingTouch"
	
	local spellCast = false
	local spellName = "Healing Touch"
	local spellTarget = "focus"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local buff = UnitBuff("player","Predatory Swiftness")
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Wrath")
	local level = UnitLevel("player")
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (buff)
	and (not isDead)
	and (inRange == 1)
	and (globalcooldown == 0)
	then spellCast = true; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (healthPct < .75) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function AD.Lifebloom()
	local __func__ = "Apollo.Druid.Lifebloom"
	
	local spellCast = false
	local spellName = "Lifebloom"
	local spellTarget = Apollo.Healer.GetTank() or "player"

	local inCombat = InCombatLockdown()
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local buff = UnitBuff(spellTarget,spellName)
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (inRange == 1) 
	and (not buff) 
	and (not noMana)
	and (inCombat) 
	and (formName == "Humanoid") then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.NaturesSwiftness()
	local __func__ = "Apollo.Druid.NaturesSwiftness"
	
	local spellCast = false
	local spellName = "Nature's Swiftness"
	local spellTarget = "player"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) and (startTime == 0) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.Ironbark()
	local __func__ = "Apollo.Druid.Ironbark"
	
	local spellCast = false
	local spellName = "Ironbark"
	local spellTarget = Apollo.Healer.GetTank() or "player"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local inCombat = InCombatLockdown()
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (inRange == 1) 
	and (inCombat) 
	and (healthPct < .75) 
	and (startTime == 0) 
	and (not noMana)
	and (formName == "Humanoid") 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
	
end

function AD.Rebirth()
	local __func__ = "Apollo.Druid.Rebirth"
	
	local spellCast = false
	local spellName = "Rebirth"
	local spellTarget = Apollo.Healer.GetTank() or "player"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local inCombat = InCombatLockdown()
	local formName = AD.ShapeshiftForm()
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (isDead) 
	and (inRange == 1) 
	and (inCombat) 
	and (startTime == 0) 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
	
end

function AD.Tranquility()
	local __func__ = "Apollo.Druid.Tranquility"
	
	local spellCast = false
	local spellName = "Tranquility"
	local spellTarget = "none"
	
	local inCombat = InCombatLockdown()
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local formName = AD.ShapeshiftForm()
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (inCombat)
	and (not noMana)
	and (ApolloHealer_Below75 >= 3) 
	and (startTime == 0) 
	and (formName == "Humanoid") then spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.WildGrowth()
	local __func__ = "Apollo.Druid.WildGrowth"
	
	local spellCast = false
	local spellName = "Wild Growth"
	local spellTarget = "focus"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local formName = AD.ShapeshiftForm()
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (inRange == 1) 
	and (ApolloHealer_Below75 >= 3) 
	and (startTime == 0) 
	and (not noMana)
	and (formName == "Humanoid") then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AD.WildMushroom()
	local __func__ = "Apollo.Druid.WildMushroom"
	
	local spellCast = false
	local spellName = "Wild Mushroom"
	local spellTarget = Apollo.Healer.GetTank() or "player"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local bossHealth = UnitHealth("Boss1")
	local formName = AD.ShapeshiftForm()
	local haveTotem = GetTotemInfo(1)
	local inCombat = InCombatLockdown()
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (bossHealth > 0)
	and (inCombat)
	and (not noMana)
	and (inRange == 1)
	and (formName == "Humanoid")
	and ((AD.WildMushroomTick + 3 < time()) or (not haveTotem))
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function AD.NaturesCure()
	local __func__ = "Apollo.Druid.NaturesCure"
	
	local spellCast = false
	local spellName = "Nature's Cure"
	local spellTarget = "focus"

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local formName = AD.ShapeshiftForm()
	local debuffFound = AD.DebuffScan(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Wild Growth")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead)
	and (not noMana)
	and (startTime == 0)
	and (inRange == 1)
	and (formName == "Humanoid")
	and (debuffFound)
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
	
end

function AD.Shred()
	local __func__ = "Apollo.Druid.Shred"
	
	local spellCast = false
	local spellName = "Shred"
	local spellTarget = "target"
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local energy = UnitPower("player",3)
	local formName = AD.ShapeshiftForm()
	local _, _, _, _, _, _, _, _, _, _, clearcasting, _, _, _, _, _ = UnitBuff("player","Clearcasting")
	if (clearcasting == 135700) then energy = 500; end;
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (canAttack) 
	and (inRange == 1) 
	and (formName == "Cat Form") 
	and (energy > 65) 
	then spellCast = true; end;

	return spellCast, spellName, spellTarget
	
end

function AD.Rake()
	local __func__ = "Apollo.Druid.Rake"
	
	local spellCast = false
	local spellName = "Rake"
	local spellTarget = "target"
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuff = UnitDebuff(spellTarget,spellName)
	local energy = UnitPower("player",3)
	local formName = AD.ShapeshiftForm()
	local _, _, _, _, _, _, _, _, _, _, clearcasting, _, _, _, _, _ = UnitBuff("player","Clearcasting")
	if (clearcasting == 135700) then energy = 500; end;
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
--	print(buff)

	if (not isDead) 
	and (canAttack) 
	and (inRange == 1) 
	and (formName == "Cat Form") 
	and (not debuff)
	and (energy > 60) 
	then spellCast = true; end;

	return spellCast, spellName, spellTarget
	
end

function AD.Rip()
	local __func__ = "Apollo.Druid.Rip"
	
	local spellCast = false
	local spellName = "Rip"
	local spellTarget = "target"
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuff = UnitDebuff(spellTarget,spellName)
	local cPoints = UnitPower("player",4)
	local energy = UnitPower("player",3)
	local formName = AD.ShapeshiftForm()
	local _, _, _, _, _, _, _, _, _, _, clearcasting, _, _, _, _, _ = UnitBuff("player","Clearcasting")
	if (clearcasting == 135700) then energy = 500; end;
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
--	print(buff)
	
	if (not isDead) 
	and (canAttack) 
	and (inRange == 1) 
	and (formName == "Cat Form") 
	and (not debuff)
	and (energy > 30)
	and (cPoints == 5)
	then spellCast = true; end;

	return spellCast, spellName, spellTarget
	
end

function AD.FerociousBite()
	local __func__ = "Apollo.Druid.FerociousBite"
	
	local spellCast = false
	local spellName = "Ferocious Bite"
	local spellTarget = "target"
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local energy = UnitPower("player",3)
	local cPoints = UnitPower("player",4)
	local formName = AD.ShapeshiftForm()
	local _, _, _, _, _, _, _, _, _, _, clearcasting, _, _, _, _, _ = UnitBuff("player","Clearcasting")
	if (clearcasting == 135700) then energy = 500; end;
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (canAttack) 
	and (inRange == 1) 
	and (formName == "Cat Form") 
	and (energy > 30) 
	and (cPoints == 5)
	then spellCast = true; end;

	return spellCast, spellName, spellTarget
	
end

function AD.Mangle()
	local __func__ = "Apollo.Druid.Mangle"
	
	local spellCast = false
	local spellName = "Mangle"
	local spellTarget = "target"
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local formName = AD.ShapeshiftForm()
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (not isDead) 
	and (canAttack) 
	and (inRange == 1) 
	and (formName == "Bear Form") 
	and (startTime == 0) 
	then spellCast = true; end;

	return spellCast, spellName, spellTarget
	
end

function AD.HealthPotion()
	local __func__ = "Apollo.Druid.HealthPotion"
	
	local spellCast = false
	local itemID = 122663
	local itemTarget = "none"
	
	local inCombat = InCombatLockdown()
	local isDead = UnitIsDeadOrGhost("player")
	local healthPct = Apollo.UnitHealthPct("player")
	local startTime = GetItemCooldown(itemID)
	
	AD.CreateItemButton(__func__, itemID, itemTarget)
	
	if (not isDead)
	and (not inCombat)
	and (healthPct < .7)
	and (startTime == 0)
	then spellCast = true; end;
	
	return spellCast, itemID, itemTarget


end
-- ================================================================================ --










-- ================================================================================ --
function Apollo.CreateSkillButtons(a, b, c)

	local btnName, spellName, spellTarget = a .. "btn", b, c
	
--	print(btnName,string.gsub(spellName,"%p",""))

	if not InCombatLockdown() then
		if _G[btnName] == nil then _G[btnName] = CreateFrame("Button", string.gsub(spellName,"%p",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[btnName]:SetAttribute("type", "macro");
		_G[btnName]:SetAttribute("macrotext", "/use [@"..spellTarget.."] "..spellName)
	end
	
--	print("/use [@"..spellTarget.."] "..spellName)
	
end

function AD.CreateItemButton(a, b, c)

	local btnName, itemID, itemTarget = a .. "btn", b, c
	local itemName = GetItemInfo(itemID)
	
	if not InCombatLockdown() then
		if _G[btnName] == nil then _G[btnName] = CreateFrame("Button", string.gsub(itemID,"%p",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[btnName]:SetAttribute("type", "macro");
		_G[btnName]:SetAttribute("macrotext", "/use [@"..itemTarget.."] item:"..itemID)
	end
	
end

function AD.ShapeshiftForm()
	local formName
	local nStance = GetShapeshiftForm()

	if (nStance == 0) or (nStance == 4) then formName = "Humanoid"
	else _,formName = GetShapeshiftFormInfo(nStance); end;
	
	if formName == "Claws of Shirvallah" then formName = "Cat Form"; end;
	return formName
	
end

function AD.DebuffScan(a)
	
	local spellTarget = a
	local debuffFound = false
	local name, dispelType = true, ""
	i = 1
	while name do
		name, _, _, _, dispelType, _, _, _, _, _, _, _, _, _, _, _ = UnitDebuff(spellTarget,i)
		if dispelType == "Magic" then debuffFound = true; end;
		if dispelType == "Curse" then debuffFound = true; end;
		if dispelType == "Poison" then debuffFound = true; end;
		i = i + 1;
	end
	
	return debuffFound
	
end

local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event, ...)

  local timestamp, type, hideCaster,
    sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

		if (type == "SPELL_HEAL") then

			local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)

			if (spellName == "Wild Mushroom") then
				AD.WildMushroomTick = time()
			end
		end
	
		if (type == "SPELL_AURA_APPLIED") then

			local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)

			if (spellName == "Wild Mushroom") then
				AD.WildMushroomTick = time()
			end
		end
		
		if (type == "SPELL_CAST_FAILED") then
			local failedSpell,_,failedType = select(13, ...)
			if failedType == "Target not in line of sight" then 
				local failedFocus = UnitName("focus")
				AD.ApplyBlacklist(failedSpell,failedFocus)
			end
		end
		
	end
end);

function AD.ApplyBlacklist(a, b)
	local failedSpell, failedFocus = a, b;
	if failedSpell ~= "Wrath" then
		table.insert(Apollo.Blacklist.Name, 1,failedFocus)
		table.insert(Apollo.Blacklist.Time, 1,time()+3)
--		print(Apollo.Blacklist.Name[1])
	end

end