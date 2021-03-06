hook.Add('PhysgunPickup', 'bw_gm_sandboxhooksworkaround_physgunpickup', function(ply, ent) --i'll fix this later...
	if ent:GetMaxHealth() > 0 and ent:Health() <= 0 then
		return false
	end
end)

if CLIENT then return end

function GM:EntityTakeDamage(ent, dmg)
	if not ent:IsPlayer() and ent:GetMaxHealth() > 0 then
		local owner = ent:CPPIGetOwner()

		if owner then
			local att = dmg:GetAttacker()
			local isRaider = (att:IsPlayer() and att:IsRaiding(owner))
			
			if not isRaider then 
				dmg:ScaleDamage(0.1)
			end

			if ent:GetClass() ~= 'prop_physics' then
				ent:SetHealth(ent:Health() -dmg:GetDamage())
				
				if ent:Health() <= 0 then
					if isRaider then
						att:AddXP(BaseWars.Config.raid_reward_xp_ent)
						att:AddMoney(BaseWars.Config.raid_reward_ent) 
						BaseWars.AddNotification(att, 3, "You've been rewarded "..BaseWars.FormatMoney(BaseWars.Config.raid_reward_ent)..' and '..BaseWars.Config.raid_reward_xp_ent..'XP for destroying '..ent.PrintName..'!')
					end
				
					local price = ent:GetPrice() *BaseWars.Config.price_refund_multiplier
					owner:AddMoney(price)
					BaseWars.AddNotification(owner, 2, 'You got '..BaseWars.FormatMoney(price)..' for your destroyed '..(ent.PrintName or 'Object')..'.')
					local explosion = EffectData()
					explosion:SetOrigin(ent:GetPos())
					util.Effect('Explosion', explosion)
					ent:Remove()
				end
			elseif owner ~= att then
				ent:SetHealth(ent:Health() -dmg:GetDamage())				
				local percentage = math.Clamp(ent:Health() /ent:GetMaxHealth(), 0, 1)
				ent:SetColor(Color(255, 255 *percentage, 255 *percentage))
		
				if ent:Health() <= 0 then
					if isRaider then 
						att:AddXP(BaseWars.Config.raid_reward_xp_prop) 
					end
					
					constraint.RemoveAll(ent)
					ent:GetPhysicsObject():EnableMotion(true)
					ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
					--ent:EmitSound('physics/concrete/concrete_break'..math.random(2, 3)..'.wav')
					timer.Simple(5, function() if ent:IsValid() then ent:Remove() end end)
				end
			end
		end
	end
end

function GM:PlayerSpawnedProp(ply, mdl, ent)
	local health = BaseWars.Config.prop_material_health[ent:GetMaterialType()] or 100
	ent:SetMaxHealth(health)
	ent:SetHealth(health)
end

function GM:PlayerSpawnEffect(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn effects!")
	return false
end

function GM:PlayerSpawnNPC(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn NPCs!")
	return false
end

function GM:PlayerSpawnRagdoll(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn Ragdolls!")
	return false
end

function GM:PlayerSpawnSENT(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn entities!")
	return false
end

function GM:PlayerSpawnSWEP(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn weapons!")
	return false
end

function GM:PlayerSpawnVehicle(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to spawn vehicles!")
	return false
end

function GM:PlayerGiveSWEP(ply)
	BaseWars.Notify(ply, 1, 5, "You're not allowed to give yourself weapons!")
	return false
end

for order, data1 in pairs(BaseWars.Config.buyables) do
	for name, data2 in pairs(data1.items) do
		FPP.Blocked.Toolgun1[name] = true
		FPP.Blocked.Spawning1[name] = true
	end
end