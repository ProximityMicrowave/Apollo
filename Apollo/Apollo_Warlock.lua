Apollo.Warlock = {}
local AW = Apollo.Warlock
AW.ImmolateTick = 0

function AW.Periodic()
	Apollo.Diagnostic.TimerStart = GetTime()
	
	AW.glyphSocket = {}
	for i = 1,6 do
		_, _, _, AW.glyphSocket[i], _ = GetGlyphSocketInfo(i);
	end
	
	local Spec = GetSpecialization()
	local SkillList = {}
	
	if not Spec then
		SkillList = {
				AW.AutoAttack,
				AW.ShadowBolt,
				AW.Corruption,
				}
	end
	
	if GetSpecialization() == 3 then
		SkillList = {
--				AW.AutoAttack,
				AW.ShadowBolt,
				AW.Corruption,
				AW.Conflagrate,
				AW.Shadowburn,
				AW.ChaosBolt,
				}
	end
--	print(table.getn(SkillList))
	for i = 1,table.getn(SkillList) do
	
--		if not SkillList[i] then break; end;
		Apollo_Ability.Cast[i], Apollo_Ability.SpellName[i], Apollo_Ability.Type[i] = SkillList[i]()
		if (not InCombatLockdown()) and Apollo.RebindKeys then
			SetBinding(Apollo_Ability.KeyBinding[i])
			SetBindingClick(Apollo_Ability.KeyBinding[i], string.gsub(Apollo_Ability.SpellName[i],"%p",""))
		end
		
	end
	
	Apollo.RebindKeys = false;
	Apollo.Diagnostic.TimerStop = GetTime()
end

function AW.AutoAttack()
	local __func__ = "Apollo.Warlock.AutoAttack"

	local spellCast = false
	local spellName = "Shoot"
	local spellTarget = "target"

	local isCurrent = IsCurrentSpell(spellName)
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget) or 1
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) and (canAttack) and (not isDead) and (not isCurrent) then
		spellCast = true
	end
	
	return spellCast, spellName, spellTarget
	
end

function AW.ShadowBolt()
	local __func__ = "Apollo.Warlock.ShadowBolt"

	local spellCast = false
	local spellName = "Shadow Bolt"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local startTime = GetSpellCooldown(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function Apollo.Warlock.Corruption()
	local __func__ = "Apollo.Warlock.Corruption"

	local spellCast = false
	local spellName = "Corruption"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuff = UnitDebuff(spellTarget,"Corruption") or UnitDebuff(spellTarget,"Immolate")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (not debuff) 
	and (AW.ImmolateTick + 3 < time())
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function AW.Conflagrate()
	local __func__ = "Apollo.Warlock.Conflagrate"

	local spellCast = false
	local spellName = "Conflagrate"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local startTime = GetSpellCooldown(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (startTime == 0) 
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end

function AW.Shadowburn()
	local __func__ = "Apollo.Warlock.Shadowburn"

	local spellCast = false
	local spellName = "Shadowburn"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local burningEmbers = UnitPower("player",14)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (burningEmbers >= 1)
	and (healthPct < .2)
	then spellCast = true; print("SHADOWBURN!"); end;
	
	return spellCast, spellName, spellTarget
end

function AW.ChaosBolt()
	local __func__ = "Apollo.Warlock.ChaosBolt"

	local spellCast = false
	local spellName = "Chaos Bolt"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local burningEmbers = UnitPower("player",14)
	local casting = UnitCastingInfo("player")
	if casting == "Chaos Bolt" then burningEmbers = burningEmbers - 1; end;
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (burningEmbers >= 2)
	then spellCast = true; end;
	
	return spellCast, spellName, spellTarget
end







local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event, ...)

	local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
		destGUID, destName, destFlags, destRaidFlags = ...

	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		if (type == "SPELL_CAST_START") then

			local spellId, spellName, spellSchool, amount,
			overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)

			if (spellName == "Immolate") then
				AW.ImmolateTick = time()
			end
		end
	end
	
end);