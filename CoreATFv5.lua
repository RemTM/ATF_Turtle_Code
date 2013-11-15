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
--				> chestSlotArray[n][1]: Slot number													--
--				> chestSlotArray[n][2]: Chest Name/Identifier										--
--				> chestSlotArray[n][3]: Boolean to determine if code has checked for chest presence	--
--																									--
-- Output:	N/A																						--
------------------------------------------------------------------------------------------------------
function enderCheck(chestSlotArray, chests)
	local isFinished = false
	local iter = 1
	while (not isFinished) do
		print("Master, please provide me with the appropriate Ender Chests for the following slots:")
		for iter = 1, chests do
			if((chestSlotArray[iter][1] ~= 0) and (not chestSlotArray[iter][3])) then
				print("Slot " .. chestSlotArray[iter][1] .. ": " .. chestSlotArray[iter][2])
			end
		end
		print("Hit any key when done.")
		os.pullEvent("key")
		for iter = 1, chests do
			if((chestSlotArray[iter][1] ~= 0) and (not chestSlotArray[iter][3])) then
				if((turtle.getItemCount(chestSlotArray[iter][1])<1) and (isFinished)) then
					isFinished = false
				else
					if(turtle.getItemCount(chestSlotArray[iter][1]) > 0) then
						chestSlotArray[iter][3] = true
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
		return true, originFB, originRL
	end
	return false, originFB, originRL
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
	if(direction>3) then
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
	if(turtle.getFuelLevel() <= 100)
		chestPlace(refuelChest, blankSlot, upsideDown)
		if(turtle.suckUp() or turtle.suckDown()) then	-- note that there is no proper check hear, fix needed
			turtle.refuel()
			print("I have finished refuelling, master.")
			chestRemove(refuelChest, dumpChest, blankSlot, upsideDown)
			return true, true
		else
			print("Please check the fuel supply, master. I cannot refuel.")
			print("Hit any key when fuel supply has been restored. Otherwise I'll just check again in 30 seconds, okay Master?")
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
	local success = false
	chestPlace(resupplyChest, blankSlot, upsideDown)
	turtle.select(buildBlocks)
	if (turtle.suckUp() or turtle.suckDown()) then
		success = true
	end
	chestRemove(resupplyChest, dumpChest, blankSlot, upsideDown)
	return success
end

------------------------------------------------------------------------------------------------------
-- torchResupply()																					--
------------------------------------------------------------------------------------------------------
function torchResupply(torchResupplyChest, torchSlot, blankSlot, upsideDown, dumpChest)
	local success = false
	chestPlace(torchResupplyChest, blankSlot, upsideDown)
	turtle.select(torchSlot)
	if (turtle.suckUp() or turtle.suckDown()) then
		success = true
	end
	chestRemove(torchResupplyChest, dumpChest, blankSlot, upsideDown)
	return success
end

------------------------------------------------------------------------------------------------------
-- itemDump()																						--
------------------------------------------------------------------------------------------------------
function itemDump(dumpChest, totalSlots, upsideDown, blankSlot)
	if(turtle.getItemCount(2)>0)
		chestPlace(dumpChest, blankSlot, upsideDown)
		-- begin emptying slots
		local slotNum = 1
		for slotNum = 1, totalSlots do
			turtle.select(slotNum)
			if (upsideDown==true) then
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
	if (upsideDown==true) then
		turtle.digDown()
		turtle.select(chest)
		turtle.placeDown()
	else
		while (turtle.detectUp()) do
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
	if (upsideDown==true) then
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
						turtle.placeUp()
					else
						turtle.up()
						turtle.placeDown()
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
			for slotNum = 1, 16 do
				turtle.select(slotNum)
				turtle.dropDown()
				if(turtle.getItemCount(slotNum + 1)==0) then break end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- forwardAttack()																						--
------------------------------------------------------------------------------------------------------
function forwardAttack()
	turtle.select(1)
	turtle.attack()
	turtle.suck()
end

function upAttack()
	turtle.select(1)
	turtle.attackUp()
	turtle.suckUp()
end

function downAttack()
	turtle.select(1)
	turtle.attackDown()
	turtle.suckDown()
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
				if (noBook) then
					print("There are now books available to enchant, master. I will now continue to enchant books.")
					noBook = false
				end
			else
				if (not noBook) then
					print("There are no more books available to enchant, master. I will continue grinding for now.")
					noBook = true
				end
			end
		end
		
		forwardAttack()
		
		if (not noBook) then
			if (turtle.getLevels()>=30) then
				if (not noDump) then
					turtle.select(16)
					turtle.transferTo(15, 1)
					turtle.select(15)
					turtle.enchant(30)
					if (not turtle.dropDown()) then
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
			for slotNum = 1, 14 do
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
				if (noBook) then
					print("There are now books available to enchant, master. I will now continue to enchant books.")
					noBook = false
				end
			else
				if (not noBook) then
					print("There are no more books available to enchant, master. I will continue grinding for now.")
					noBook = true
				end
			end
		end
		
		if (not noBook) then
			if (turtle.getLevels()>=30) then
				if (not noDump) then
					turtle.select(16)
					turtle.transferTo(15, 1)
					turtle.select(15)
					turtle.enchant(30)
					if (not turtle.dropDown()) then
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

-- Initial area clearing code (self sufficient)
-- A simple clear code which "clears out" a given area
-- Can dig up or down
-- Will always place torches on lowest level of clearing to ensure no mob spawn
-- UNDER CONSTRUCTION

function areaClear()
	local originFB = 0
	local originRL = 0
	local originUD = 0
	local direction = 0
	local previousDirection = 0
	local upsideDown = false
	local mined = true
	local moveSuccess = true
	local doMineUp, doMineForward, doMineDown = true, true, true
	local operation = 0
	local upDirection = true
	
	print("Initialising Area Clear Code...")
	
	local enderChestArray = {}
	local iter = 1
	for iter = 1, 4 do
		enderChestArray[iter] = {}
	end
	
	-- Array of required ender chests
	enderChestArray[1][1] = 14
	enderChestArray[1][2] = "Dump Chest"
	enderChestArray[1][3] = false
	enderChestArray[2][1] = 15
	enderChestArray[2][2] = "Refuel Chest"
	enderChestArray[2][3] = false
	enderChestArray[3][1] = 16
	enderChestArray[3][2] = "Torch Resupply Chest"
	enderChestArray[3][3] = false
	enderCheck(enderChestArray, 3)
	
	-- Working inventory for turtle
	local totalSlots = 11
	local blankSlot = 12
	local torchSlot = 13
	local dumpChest = 14
	local refuelChest = 15
	local torchResupplyChest = 16
	
	print("Master, how wide do you want me to make the area?")
	local width = tonumber(read())
	print("Master, how far forward do you want me to go?")
	local length = tonumber(read())
	print("Master, how high do you want me to dig the area?")
	local height = tonumber(read())
	if(height > 0) then
		upsideDown = false
	elseif(height < 0) then
		upsideDown = true
	else
		-- invalid
	end
	print("I will begin clearing out the area then, master. I will return here once finished.")
	
	-- will assume for now that you are not using this near bedrock in the wrong direction
	if((not upsideDown) and (height > 1)) then
		while (turtle.detectUp()) do
			mined = mineUp(dumpChest, totalSlots, upsideDown, blankSlot)
			sleep(2)
		end
		moveSuccess, originUD = moveUp(originUD)
		while(not moveSuccess) do
			upAttack()
			moveSuccess, originUD = moveUp(originUD)
		end
		upDirection = true
	elseif((upsideDown) and (height < -1)) then
		while (turtle.detectDown()) do
			mined = mineDown(dumpChest, totalSlots, upsideDown, blankSlot)
			sleep(2)
		end
		moveSuccess, originUD = moveDown(originUD)
		while(not moveSuccess) do
			downAttack()
			moveSuccess, originUD = moveDown(originUD)
		end
		upDirection = false
	end
	
	local needRefuel = false
	local hasRefueled = false
	
	while ((originFB < length) and (mined)) do
		-- refuel check
		needRefuel, hasRefueled = refuel(refuelChest, blankSlot, upsideDown, dumpChest)
		while ((needRefuel) and (not hasRefueled)) do
			sleep(60)
			needRefuel, hasRefueled = refuel(refuelChest, blankSlot, upsideDown, dumpChest)
		end
		
		-- torch resupply check
		if(turtle.getItemCount(torchSlot) == 0) then
			while(not torchResupply(torchResupplyChest, torchSlot, blankSlot, upsideDown, dumpChest)) do
				sleep(60)
			end
		end
		
		-- CHECK: Confirmed working up to this point. Fails afterwards
		-- Possible that variable is missing from method calls or similar
		
		if((originRL == (width - 1)) or (originRL == 0)) then -- currently at edge
			previousDirection = direction
			if((upsideDown and (((originUD == height + 2) and not upDirection) or ((originUD == -1) and upDirection))) or (not upsideDown and (((originUD == height - 2) and upDirection) or ((originUD == 1) and not upDirection)))) then
				upDirection = (not upDirection)
				operation = 1 -- go forward
			else
				if(not upsideDown and ((originUD + 1) % 3 ~= 0) or (upsideDown and ((originUD - 1) % 3 ~= 0))) then
					operation = 0 -- go up/down
				else
					operation = 1 -- go forward
				end
			end
			while(direction ~= 0) do
				direction = turnLeft(direction)
			end
		else
			operation = 1 -- go forward
		end
		
		if(previousDirection == 0) then -- previously going forward/up/down/at start
			if(originRL == 0) then
				while(direction ~= 1) do
					direction = turnRight(direction)
				end
			elseif(originRL == (width - 1)) then
				while(direction ~= 3) do
					direction = turnLeft(direction)
				end
			end
		end
		
		-- dig operation check
		if(upsideDown) then
			if(originUD == 0) then	-- should never happen
				doMineUp = false
				doMineDown = true
			elseif(originUD == (height + 1)) then -- should never happen
				doMineUp = true
				doMineDown = false
			else
				doMineUp = true
				doMineDown = true
			end
		else
			if(originUD == (height - 1)) then -- should never happen
				doMineUp = false
				doMineDown = true
			elseif(originUD == 0) then -- should never happen
				doMineUp = true
				doMineDown = false
			else
				doMineUp = true
				doMineDown = true
			end
		end
		if(((originRL == 0) and (direction == 3)) or ((originRL == (width - 1)) and (direction == 1)) or ((originFB == (length - 1)) and (direction == 0))) then
			-- should only happen at final position before returning to origin or when moving up/down
			doMineForward = false
		else
			doMineForward = true
		end
		
		if(operation == 1) then
			if(((originRL + 1) % 3 == 0) and ((originFB + 1) % 3 == 0) and (upsideDown and (originUD == (height + 2))) or (not upsideDown and (originUD == 1))) then
				-- torch embed down
				if(mineDown(dumpChest, totalSlots, upsideDown, blankSlot)) then
					moveSuccess, originUD = moveDown(originUD)
					if(moveSuccess) then
						floorEmbedTorch(torchSlot, dumpChest, totalSlots, upsideDown, blankSlot)
						moveSuccess, originUD = moveUp(originUD)
						-- can place something here if move failed
					end
				end
			elseif((((originRL == 0 or originRL == (width - 1)) and ((originFB + 1) % 3 == 0)) or ((originFB == 0 or originFB == (length - 1)) and ((originRL + 1) % 3 == 0))) and ((not upsideDown and ((originUD + 1) % 3 == 0)) or (upsideDown and (-(originUD - 1) % 3 == 0)))) then
				-- wall embed torch
				previousDirection = direction
				if(originRL == 0) then
					while(direction ~= 3) do
						direction = turnRight(direction)
					end
				elseif(originRL == (width - 1)) then
					while(direction ~= 1) do
						direction = turnRight(direction)
					end
				elseif(originFB == 0) then
					while(direction ~= 2) do
						direction = turnRight(direction)
					end
				elseif(originFB == (length - 1)) then
					while(direction ~= 0) do
						direction = turnRight(direction)
					end
				end
				wallEmbedTorch(torchSlot, dumpChest, totalSlots, upsideDown, blankSlot)
				while(direction ~= previousDirection) do
					direction = turnLeft(direction)
				end
			end
			mined, originFB, originRL = mineOutForward(dumpChest, totalSlots, upsideDown, blankSlot, originFB, originRL, direction, doMineUp, doMineForward, doMineDown)
		elseif(operation == 0) then --TODO: Proper management required
			if(upDirection == true) then
				moveSuccess, originUD = moveUpAdvanced(originUD, dumpChest, totalSlots, upsideDown, blankSlot)
			else
				moveSuccess, originUD = moveDownAdvanced(originUD, dumpChest, totalSlots, upsideDown, blankSlot)
			end
		end
	end
	
	print("I have now finished clearing out the area, master.")
	while((originFB ~= 0) and (originRL ~= 0) and (originUD ~= 0)) do
		if(originFB ~= 0) then
			while(direction ~= 2) do
				direction = turnLeft(direction)
			end
			mineOutForward(dumpChest, totalSlots, upsideDown, blankSlot, originFB, originRL, direction, true, true, true)
		elseif(originRL ~= 0) then
			while(direction ~= 3) do
				direction = turnLeft(direction)
			end
			mineOutForward(dumpChest, totalSlots, upsideDown, blankSlot, originFB, originRL, direction, true, true, true)
		elseif(originUD ~= 0) then
			while(direction ~= 0) do
				direction = turnLeft(direction)
			end
			if(upsideDown) then
				while(turtle.detectUp()) do
					mined = mineUp(dumpChest, totalSlots, upsideDown, blankSlot)
					sleep(2)
				end
				moveSuccess, originUD = moveUp(originUD)
				while(not moveSuccess) do
					upAttack()
					moveSuccess, originUD = moveUp(originUD)
				end
			else
				while (turtle.detectDown()) do
					mined = mineDown(dumpChest, totalSlots, upsideDown, blankSlot)
					sleep(2)
				end
				moveSuccess, originUD = moveDown(originUD)
				while(not moveSuccess) do
					downAttack()
					moveSuccess, originUD = moveDown(originUD)
				end
			end
		end
	end
end

function moveUpAdvanced(originUD, dumpChest, totalSlots, upsideDown, blankSlot)
	local mined = false
	local moveSuccess = false
	if(turtle.detectUp()) then
		mined = mineUp(dumpChest, totalSlots, upsideDown, blankSlot)
		-- TODO: handle if bedrock detected at this point
	end
	upAttack()
	moveSuccess, originUD = moveUp(originUD)
	return moveSuccess, originUD
end

function moveDownAdvanced(originUD, dumpChest, totalSlots, upsideDown, blankSlot)
	local mined = false
	local moveSuccess = false
	if(turtle.detectDown()) then
		mined = mineDown(dumpChest, totalSlots, upsideDown, blankSlot)
		-- TODO: handle if bedrock detected at this point
	end
	downAttack()
	moveSuccess, originUD = moveDown(originUD)
	return moveSuccess, originUD
end

function mineOutForward(dumpChest, totalSlots, upsideDown, blankSlot, originFB, originRL, direction, doMineUp, doMineForward, doMineDown)
	local moveSuccess = false
	local mined = true
	while(turtle.detectUp() and mined and doMineUp) then
		mined = mineUp(dumpChest, totalSlots, upsideDown, blankSlot)
		if(not mined) then
			-- attempted to mine bedrock
			doMineUp = false
		end
		sleep(2)
	end
	while(turtle.detect() and mined and doMineForward) then
		mined = mineForward(dumpChest, totalSlots, upsideDown, blankSlot)
		if(not mined) then
			-- attempted to mine bedrock
			doMineForward = false
		end
		sleep(2)
	end
	while(turtle.detectDown() and mined and doMineDown) then
		mined = mineDown(dumpChest, totalSlots, upsideDown, blankSlot)
		if(not mined) then
			-- attempted to mine bedrock
			doMineDown = false
		end
		sleep(2)
	end
	if(mined and doMineForward) then
		moveSuccess, originFB, originRL = moveForward(originFB, originRL, direction)
		while(not moveSuccess) do
			forwardAttack()
			moveSuccess, originFB, originRL = moveForward(originFB, originRL, direction)
		end
	else
		-- bedrock detected, depth limit reached if mining down
		-- TODO: handling for when turtle encounters bedrock
	end
	return mined, originFB, originRL
end