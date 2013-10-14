--------------------------------------
-- Minecraft Turtle Code: CoreATFv5 --
--------------------------------------

-- Note: This code has been revised to be completely standalone. This means that a separate class
-- file must be created calling methods from this class passing in expected values to work correctly

------------------------------------------------------------------------------------------------------
-- enderCheck()																						--
--																									--
-- This function is used to check if certain slots have items in them. It assumes that those items	--
-- are ender chests, and that you have placed the expected ender chests in the correct slots. As	--
-- this part is completely manual, it is up to the user to decide if the placement of chests is		--
-- correct.																							--
--																									--
-- Input:	- chestSlotArray, which contains:														--
--				> chestSlotArray[1]: Slot number													--
--				> chestSlotArray[2]: Chest Name/Identifier											--
--				> chestSlotArray[3]: Ender Chest Colour Code										--
--				> chestSlotArray[4]: Boolean to determine if code has checked for chest presence	--
--																									--
-- Output:	N/A																						--
------------------------------------------------------------------------------------------------------
function enderCheck(chestSlotArray)
	local isFinished = false
	local iter = 1
	while (!isFinished) do
		print("Master, please provide me with the appropriate Ender Chests for the following slots:")
		for iter = 1, 16 do
			if((chestSlotArray[iter][1] != 0) and (!chestSlotArray[iter][4])) then
				print("Slot " .. chestSlotArray[iter][1] .. ": " .. chestSlotArray[iter][2])
				print("Colour code: " .. chestSlotArray[iter][3])
			end
		end
		print("Hit any key when done.")
		os.pullEvent("key")
		for iter = 1, 16 do
			if((chestSlotArray[iter][1] != 0) and (!chestSlotArray[iter][4])) then
				if((turtle.getItemCount(chestSlotArray[iter][1])<1) and (isFinished)) then
					isFinished = false
				else
					if(turtle.getItemCount(chestSlotArray[iter][1]) > 0) then
						chestSlotArray[iter][4] = true
						isFinished = true
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- moveForward()																					--
------------------------------------------------------------------------------------------------------
function moveForward(originFB, originRL, direction)
	if(turtle.forward()) then
		if(direction == 0) then
			originFB = originFB + 1
		elseif(direction == 1) then
			originRL = originRL + 1
		elseif(direction == 2) then
			originFB = originFB - 1
		elseif(direction == 3) then
			originRL = originRL - 1
		end
		return true, originFB, originRL, direction
	end
	return false, originFB, originRL, direction
end

------------------------------------------------------------------------------------------------------
-- turnLeft()																						--
------------------------------------------------------------------------------------------------------
function turnLeft(direction)
	direction = direction - 1
	if(direction<0) then
		direction = 3
	end
	turtle.turnLeft()
	return direction
end

------------------------------------------------------------------------------------------------------
-- turnRight()																						--
------------------------------------------------------------------------------------------------------
function turnRight(direction)
	direction = direction + 1
	if(direction>0) then
		direction = 0
	end
	turtle.turnRight()
	return direction
end

------------------------------------------------------------------------------------------------------
-- moveUp()																							--
------------------------------------------------------------------------------------------------------
function moveUp(originUD)
	if(turtle.up()) then
		originUD = originUD + 1
		return true, originUD
	end
	return false, originUD
end

------------------------------------------------------------------------------------------------------
-- moveDown()																						--
------------------------------------------------------------------------------------------------------
function moveDown(originUD)
	if(turtle.down()) then
		originUD = originUD - 1
		return true, originUD
	end
	return false, originUD
end

------------------------------------------------------------------------------------------------------
-- mineUp()																							--
------------------------------------------------------------------------------------------------------
function mineUp(dumpChest, totalSlots, upsideDown, blankSlot)
	turtle.select(1)
	turtle.digUp()
	turtle.suckUp()
	itemDump(dumpChest, totalSlots, upsideDown, blankSlot)
	if(turtle.detectUp()) then
		return false
	end
	return true
end

------------------------------------------------------------------------------------------------------
-- mineDown()																						--
------------------------------------------------------------------------------------------------------
function mineDown(dumpChest, totalSlots, upsideDown, blankSlot)
	turtle.select(1)
	turtle.digDown()
	turtle.suckDown()
	itemDump(dumpChest, totalSlots, upsideDown, blankSlot)
	if(turtle.detectDown()) then
		return false
	end
	return true
end

------------------------------------------------------------------------------------------------------
-- mineForward()																					--
------------------------------------------------------------------------------------------------------
function mineForward(dumpChest, totalSlots, upsideDown, blankSlot)
	turtle.select(1)
	turtle.dig()
	turtle.suck()
	itemDump(dumpChest, totalSlots, upsideDown, blankSlot)
	if(turtle.detect()) then
		return false
	end
	return true
end

------------------------------------------------------------------------------------------------------
-- buildDown()																						--
------------------------------------------------------------------------------------------------------
function buildDown(buildBlocks, resupplyChest, blankSlot, upsideDown, dumpChest)
	if(turtle.getItemCount(buildBlocks)==0) then
		resupply(resupplyChest, buildBlocks, blankSlot, upsideDown, dumpChest)
	end
	turtle.select(buildBlocks)
	if(turtle.placeDown()) then
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- buildUp()																						--
------------------------------------------------------------------------------------------------------
function buildUp(buildBlocks, resupplyChest, blankSlot, upsideDown, dumpChest)
	if(turtle.getItemCount(buildBlocks)==0) then
		resupply(resupplyChest, buildBlocks, blankSlot, upsideDown, dumpChest)
	end
	turtle.select(buildBlocks)
	if(turtle.placeUp()) then
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- buildForward()																					--
------------------------------------------------------------------------------------------------------
function buildForward(buildBlocks, resupplyChest, blankSlot, upsideDown, dumpChest)
	if(turtle.getItemCount(buildBlocks)==0) then
		resupply(resupplyChest, buildBlocks, blankSlot, upsideDown, dumpChest)
	end
	turtle.select(buildBlocks)
	if(turtle.place()) then
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- refuel()																							--
------------------------------------------------------------------------------------------------------
function refuel(refuelChest, blankSlot, upsideDown, dumpChest)
	if(turtle.getFuelLevel() <= 1)
		chestPlace(refuelChest, blankSlot, upsideDown)
		if(turtle.suckUp() or turtle.suckDown()) then	-- note that there is no proper check hear, fix needed
			turtle.refuel()
			print("I have finished refuelling, master.")
			chestRemove(refuelChest, dumpChest, blankSlot, upsideDown)
			return true, true
		else
			print("Please check the fuel supply, master. I cannot refuel.")
			print("Hit any key when fuel supply has been restored. Otherwise I'll just just check again in 30 seconds, okay Master?")
			parallel.waitForAny(os.pullEvent("key"), wait(30))
			chestRemove(refuelChest, dumpChest, blankSlot, upsideDown)
		end
		return true, false
	end
	return false, false
end

------------------------------------------------------------------------------------------------------
-- resupply()																						--
------------------------------------------------------------------------------------------------------
function resupply(resupplyChest, buildBlocks, blankSlot, upsideDown, dumpChest)
	chestPlace(resupplyChest, blankSlot, upsideDown)
	turtle.select(buildBlocks)
	if (turtle.suckUp() or turtle.suckDown()) then
		return true
	else
		return false
	end
	chestRemove(resupplyChest, dumpChest, blankSlot, upsideDown)
end

------------------------------------------------------------------------------------------------------
-- torchResupply()																					--
------------------------------------------------------------------------------------------------------
function torchResupply(torchResupplyChest, torchSlot, blankSlot, upsideDown, dumpChest)
	chestPlace(torchResupplyChest, blankSlot, upsideDown)
	turtle.select(torchSlot)
	if (turtle.suckUp() or turtle.suckDown()) then
		return true
	else
		return false
	end
	chestRemove(torchResupplyChest, dumpChest, blankSlot, upsideDown)
end

------------------------------------------------------------------------------------------------------
-- itemDump()																						--
------------------------------------------------------------------------------------------------------
function itemDump(dumpChest, totalSlots, upsideDown, blankSlot)
	if(turtle.getItemCount(2)>0)
		chestPlace(dumpChest, blankSlot, upsideDown)
		-- begin emptying slots
		local slotNum = 1
		for slotNum = 1, totalSlots
		do
			turtle.select(slotNum)
			if upsideDown==true then
				turtle.dropDown()
			else
				turtle.dropUp()
			end
		end
		-- finished emptying inventory
		chestRemove(dumpChest, dumpChest, blankSlot, upsideDown)
		turtle.select(1)
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- chestPlace()																						--
------------------------------------------------------------------------------------------------------
function chestPlace(chest, blankSlot, upsideDown)
	turtle.select(blankSlot)
	if upsideDown==true then
		turtle.digDown()
		turtle.select(chest)
		turtle.placeDown()
	else
		while turtle.detectUp() do
			turtle.digUp()
		end
		turtle.select(chest)
		turtle.placeUp()
	end
end

------------------------------------------------------------------------------------------------------
-- chestRemove()																					--
------------------------------------------------------------------------------------------------------
function chestRemove(chest, dumpChest, blankSlot, upsideDown)
	turtle.select(chest)
	if upsideDown==true then
		turtle.digDown()
		turtle.select(dumpChest)
		turtle.placeDown()
		turtle.select(blankSlot)
		turtle.dropDown()
		turtle.select(dumpChest)
		turtle.digDown()
	else
		turtle.digUp()
		turtle.select(dumpChest)
		turtle.placeUp()
		turtle.select(blankSlot)
		turtle.dropUp()
		turtle.select(dumpChest)
		turtle.digUp()
	end
end

------------------------------------------------------------------------------------------------------
-- movePlaceTorch()																					--
------------------------------------------------------------------------------------------------------
function movePlaceTorch(torchSlot, originFB, originRL, direction)
	moveResult, originFB, originRL, direction = moveForward(originFB, originRL, direction)
	if(moveResult == true) then
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.select(torchSlot)
		turtle.place()
		turtle.turnRight()
		turtle.turnRight()
		return true, originFB, originRL, direction
	end
	return false, originFB, originRL, direction
end

------------------------------------------------------------------------------------------------------
-- floorEmbedTorch()																				--
------------------------------------------------------------------------------------------------------
function floorEmbedTorch(torchSlot, dumpChest, totalSlots, upsideDown, blankSlot)
	if(mineDown(dumpChest, totalSlots, upsideDown, blankSlot) == true) then
		turtle.select(torchSlot)
		turtle.placeDown()
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- wallEmbedTorch()																					--
------------------------------------------------------------------------------------------------------
function wallEmbedTorch(torchSlot, dumpChest, totalSlots, upsideDown, blankSlot)
	if(mineForward(dumpChest, totalSlots, upsideDown, blankSlot) == true) then
		turtle.select(torchSlot)
		turtle.place()
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- buildFloorSimple()																				--
------------------------------------------------------------------------------------------------------
function buildFloorSimple()
	if turtle.detect() then
		if turtle.back() then
			turtle.place()
		else
			turtle.turnLeft()
			if turtle.back() then
				turtle.place()
			else
				turtle.turnLeft()
				turtle.turnLeft()
				if turtle.back() then
					turtle.place()
				else
					turtle.turnLeft()
					if upsideDown then
						turtle.down()
						turtle.placeDown()
					else
						turtle.up()
						turtle.placeUp()
					end
					return true
				end
			end
		end
	else
		turtle.place()
	end
	return false
end

------------------------------------------------------------------------------------------------------
-- attackLoop()																						--
------------------------------------------------------------------------------------------------------
function attackLoop()
	local slotNum = 1
	while (true) do
		turtle.select(1)
		turtle.attack()
		turtle.suck()
		if(turtle.getItemCount(1)>0)
			for slotNum = 1, 16
			do
				turtle.select(slotNum)
				turtle.dropDown()
				if(turtle.getItemCount(slotNum + 1)==0) then break end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- xpAttack()																						--
------------------------------------------------------------------------------------------------------
function xpAttack()
	turtle.select(1)
	turtle.attack()
	turtle.suck()
end

------------------------------------------------------------------------------------------------------
-- xpBookAttackGrinder()																			--
------------------------------------------------------------------------------------------------------
function xpBookAttackGrinder(side)
	local noBook = true
	local noDump = false
	local slotNum = 1
	
	xpTurtle = peripheral.wrap(side)
	xpTurtle.setAutoCollect(true)
	
	while (true) do
		if (turtle.getItemCount(16)==0) then
			turtle.select(16)
			if (turtle.suckUp()) then
				if (noBook==true) then
					print("There are now books available to enchant, master. I will now continue to enchant books.")
					noBook = false
				end
			else
				if (noBook==false) then
					print("There are no more books available to enchant, master. I will continue grinding for now.")
					noBook = true
				end
			end
		end
		
		xpAttack()
		
		if (noBook==false) then
			if (turtle.getLevels()>=30) then
				if (noDump==false) then
					turtle.select(16)
					turtle.transferTo(15, 1)
					turtle.select(15)
					turtle.enchant(30)
					if (turtle.dropDown()==false) then
						print("Output chest for enchanted books is full, master. I will continue grinding for now.")
						noDump = true
						turtle.select(16)
						turtle.dropUp()
						turtle.select(15)
						turtle.transferTo(16, 1)
					end
				else
					turtle.select(16)
					if (turtle.dropDown()) then
						print("Output chest for enchanted books is no longer full, master. I will continue enchanting books.")
						noDump = false
					end
				end
			end
		end
		
		if(turtle.getItemCount(1)>0)
			turtle.turnLeft()
			for slotNum = 1, 14
			do
				turtle.select(slotNum)
				turtle.drop()
				if(turtle.getItemCount(slotNum + 1)==0) then break end
			end
			turtle.turnRight()
		end
	end
end

------------------------------------------------------------------------------------------------------
-- xpBookGrinder()																					--
------------------------------------------------------------------------------------------------------
function xpBookGrinder(side)
	local noBook = true
	local noDump = false
	local slotNum = 1
	
	xpTurtle = peripheral.wrap(side)
	xpTurtle.setAutoCollect(true)
	
	while (true) do
		if (turtle.getItemCount(16)==0) then
			turtle.select(16)
			if (turtle.suckUp()) then
				if (noBook==true) then
					print("There are now books available to enchant, master. I will now continue to enchant books.")
					noBook = false
				end
			else
				if (noBook==false) then
					print("There are no more books available to enchant, master. I will continue grinding for now.")
					noBook = true
				end
			end
		end
		
		if (noBook==false) then
			if (turtle.getLevels()>=30) then
				if (noDump==false) then
					turtle.select(16)
					turtle.transferTo(15, 1)
					turtle.select(15)
					turtle.enchant(30)
					if (turtle.dropDown()==false) then
						print("Output chest for enchanted books is full, master. I will continue grinding for now.")
						noDump = true
						turtle.select(16)
						turtle.dropUp()
						turtle.select(15)
						turtle.transferTo(16, 1)
					end
				else
					turtle.select(16)
					if (turtle.dropDown()) then
						print("Output chest for enchanted books is no longer full, master. I will continue enchanting books.")
						noDump = false
					end
				end
			end
		end
	end
end