if item_shotgun_v2 == nil then item_shotgun_v2 = class({}) end

LinkLuaModifier("modifier_item_shotgun_v2", "items/item_shotgun_v2.lua", LUA_MODIFIER_MOTION_NONE)


function item_shotgun_v2:GetIntrinsicModifierName()
	return "modifier_item_shotgun_v2"
end



if modifier_item_shotgun_v2 == nil then modifier_item_shotgun_v2 = class({}) end

function modifier_item_shotgun_v2:IsDebuff() return false end
function modifier_item_shotgun_v2:IsHidden() return true end
function modifier_item_shotgun_v2:IsPurgable() return false end
function modifier_item_shotgun_v2:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_shotgun_v2:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	if not IsServer() then return end

	for _, mod in pairs(self:GetParent():FindAllModifiersByName(self:GetName())) do
		mod:GetAbility():SetSecondaryCharges(_)
	end 
end 

function modifier_item_shotgun_v2:OnDestroy()
	if not IsServer() then return end

	for _, mod in pairs(self:GetParent():FindAllModifiersByName(self:GetName())) do
		mod:GetAbility():SetSecondaryCharges(_)
	end 
end

function modifier_item_shotgun_v2:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK


	}
	return funcs
end

function modifier_item_shotgun_v2:OnCreated()

	local ability = self:GetAbility()
	self.attack_radius = ability:GetSpecialValueFor("attack_radius")
	self.attack_percent = ability:GetSpecialValueFor("attack_percent")
	
end

function modifier_item_shotgun_v2:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_shotgun_v2:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end


function modifier_item_shotgun_v2:GetModifierProcAttack_Feedback(keys)
	if not keys.attacker:IsRealHero() or not keys.attacker:IsRangedAttacker() then return end
	if keys.attacker:GetTeam() == keys.target:GetTeam() then return end
	if keys.target:IsBuilding() then return end
	
	local ability = self:GetAbility()
	local target_loc = keys.target:GetAbsOrigin()
	local damage = keys.original_damage  * self.attack_percent * 0.01
	
	local blast_pfx = ParticleManager:CreateParticle("particles/custom/shrapnel.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(blast_pfx, 0, target_loc)
	ParticleManager:ReleaseParticleIndex(blast_pfx)

	local enemies = FindUnitsInRadius(keys.attacker:GetTeamNumber(), target_loc, nil, self.attack_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= keys.target then
			ApplyDamage({
				victim 			= enemy,
				attacker 		= keys.attacker,
				damage 			= damage,
				damage_type 	= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability 		= ability,
			})
		end
	end
end
