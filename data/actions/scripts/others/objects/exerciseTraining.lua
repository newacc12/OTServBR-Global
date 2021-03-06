local skills = {
	[32384] = {id=SKILL_SWORD,voc=4}, -- KNIGHT
	[32385] = {id=SKILL_AXE,voc=4}, -- KNIGHT
	[32386] = {id=SKILL_CLUB,voc=4}, -- KNIGHT
	[32387] = {id=SKILL_DISTANCE,voc=3,range=CONST_ANI_SIMPLEARROW}, -- PALADIN
	[32388] = {id=SKILL_MAGLEVEL,voc=2,range=CONST_ANI_SMALLICE}, -- DRUID
	[32389] = {id=SKILL_MAGLEVEL,voc=1,range=CONST_ANI_FIRE}, -- SORCERER
	[32124] = {id=SKILL_SWORD,voc=4}, -- KNIGHT
	[32125] = {id=SKILL_AXE,voc=4}, -- KNIGHT
	[32126] = {id=SKILL_CLUB,voc=4}, -- KNIGHT
	[32127] = {id=SKILL_DISTANCE,voc=3,range=CONST_ANI_SIMPLEARROW}, -- PALADIN
	[32128] = {id=SKILL_MAGLEVEL,voc=2,range=CONST_ANI_SMALLICE}, -- DRUID
	[32129] = {id=SKILL_MAGLEVEL,voc=1,range=CONST_ANI_FIRE} -- SORCERER
}

local dummies = {32142, 32143, 32144, 32145, 32146, 32147, 32148, 32149}
local skillRate = 1*configManager.getNumber(configKeys.RATE_SKILL)
-- skillRate = 1.1*30 = 30 + 3 (10%) = 33x

local function start_train(pid,start_pos,itemid,fpos)
	local player = Player(pid)
	if player ~= nil then
		local pos_n = player:getPosition()
		if start_pos:getDistance(pos_n) == 0 and getTilePzInfo(pos_n) then
			if player:getItemCount(itemid) >= 1 then
				local exercise = player:getItemById(itemid,true)
				if exercise:isItem() then
					if exercise:hasAttribute(ITEM_ATTRIBUTE_CHARGES) then
						local charges_n = exercise:getAttribute(ITEM_ATTRIBUTE_CHARGES)
						if charges_n >= 1 then
							exercise:setAttribute(ITEM_ATTRIBUTE_CHARGES,(charges_n-1))

							local voc = player:getVocation()

							if skills[itemid].id == SKILL_MAGLEVEL then
								magicTry = voc:getRequiredManaSpent(player:getBaseMagicLevel() + 1)-player:getManaSpent()
								player:addManaSpent(math.ceil(250))
							else
								player:addSkillTries(skills[itemid].id, 1*skillRate)
							end
								fpos:sendMagicEffect(CONST_ME_HITAREA)
							if skills[itemid].range then
								pos_n:sendDistanceEffect(fpos, skills[itemid].range)
							end
							local training = addEvent(start_train, voc:getAttackSpeed(), pid,start_pos,itemid,fpos)
							player:setStorageValue(Storage.isTraining,1)
						else
							exercise:remove(1)
							player:sendTextMessage(MESSAGE_INFO_DESCR, "Your training weapon vanished.")
							stopEvent(training)
							player:setStorageValue(Storage.isTraining,0)
						end
					end
				end
			end
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Youy training has stopped.")
			stopEvent(training)
			player:setStorageValue(Storage.isTraining,0)
		end
	else
		stopEvent(training)
		if player then -- verificar se o player ainda existe (logado), caso esteja, enviar mensagem de erro e parar treino. isso evita erros no console
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Youy training has stopped.")
			player:setStorageValue(Storage.isTraining,0)
		end
	end
	return true
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local start_pos = player:getPosition()
	if player:getStorageValue(Storage.isTraining) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You are already training.")
		return false
	end
	if target:isItem() then
		if isInArray(dummies,target:getId()) then
			if not skills[item.itemid].range and (start_pos:getDistance(target:getPosition()) > 1) then
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Get closer to the dummy.")
				stopEvent(training)
				return true
			end
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You started training.")
			start_train(player:getId(),start_pos,item.itemid,target:getPosition())
		end
	end
	return true
end