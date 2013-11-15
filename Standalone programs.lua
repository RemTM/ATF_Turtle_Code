-- Simple Standalone Programs

-- Aim:
-- Simplify code to use only what is necessary to get the job done and prevent server lag

-- Program #1: Simply Advanced Controlled Attack Loop
-- This is based on the assumption that the turtle will always attack forward, have all items it currently has
-- automatically removed from its inventory by an external system, and receive a rednet signal from a nearby computer
-- which will act as a master computer controller for all spawners.
-- The redstone signal will shut the turtle down after one more minute to kill all mobs.
-- It will be assumed that the "grindbox" or "slaughterhouse" where mobs will be killed in are located in a 3x3x3 area
-- with water in the middle for maximum effect. It will also be assumed that all items and XP are handled to prevent lag
-- in the surrounding area.

rednet.open("<side modem is connected on>")
id, message = rednet.receive()

while(true) do
	if(message == ("ON")) then
		print("ON command received. Activating attackLoop code...")
		parallel.waitForAny((id, message = rednet.receive()), attackLoop()) -- TODO: Test this!!!
	elseif(message == ("OFF") then
		print("OFF command received. Idling after 60 seconds...")
		parallel.waitForAny(sleep(60), attackLoop())
		id, message = rednet.receive()
	else
		print("Invalid command received. Idling after 60 seconds...")
		id, message = rednet.receive()
	end
end

function attackLoop()
	while(true) do
		turtle.select(1)
		turtle.attack()
		sleep(2)	-- to prevent it from spamming attack continuously just in case... may not be needed
	end
end

-- Program #2: Advanced Control Master Computer
-- This program is used on the master computer controlling the mob spawners and "grindbox".
-- It will use rednet and wireless redstone to communicate with computer, turtles and spawners.
-- Placement will be:
-- Bottom: Modem
-- Front: ON/OFF Redstone switch
-- Back, Left, Right, Top: Outputs

-- Note: Before running this, first check if all sides are indeed usable by running rs.getSides(). It returns a table of all possible sides redstone signals can be monitored/controlled from

rednet.open("bottom")	-- will be assumed that modem will always be installed below computer
print("Launching Grindbox Master Control...")

rs.setOutput("back", true)
rs.setOutput("left", true)
rs.setOutput("right", true)
-- Note: Setting the top here should not be needed at the beginning, as it is by default always on via the redstone torch
local signal = false

while(true) do
	signal = rs.getInput("front")
	if(signal) then
		rednet.broadcast("ON")
		rs.setOutput("back", false)
		rs.setOutput("left", false)
		rs.setOutput("right", false)
		rs.setOutput("top", true)	-- inverted due to redstone torch requirement
	else
		rednet.broadcast("OFF")
		rs.setOutput("back", true)
		rs.setOutput("left", true)
		rs.setOutput("right", true)
		rs.setOutput("top", false)	-- inverted due to redstone torch requirement
	end
	while(signal == rs.getInput("front")) do
		sleep(60) -- will sleep for a minute before checking to see if signal has changed.
	end
end

-- Program #3: Room Clearing Code
-- Note: This will require the following ender chests
-- > Dump Chest
-- > Refuel Chest
-- Aim for this program is to automatically clear out a room based on width, height and length provided. Will automatically dump mined materials and refuel itself when required.
-- Note2: There is currently no handling for when the wrong value is provided in turtle
-- Note3: The turtle will go forward one before clearing out an area to the front and right of itself.
-- Note4: The turtle will initially go forward before it encounters a block, then will begin digging from there. Useful if clearing was interrupted partway previously.
-- Note5: Will not like cobblegens and bedrock.
-- TODO: Test to see of code works
-- TODO: Ability to reverse effects to clear an area below it
-- TODO: Ability to automatically place torches
-- TODO: Ability to "loot"

local totalSlots = 13
local blankSlot = 14
local dumpChest = 15
local refuelChest = 16
local originUD = 1
local originFB = 0	-- set due to requiring to move forward 1 before clearing
local originRL = 1
local direction = 1	-- set as it will be looking to its right when first attempting to clear (0: forward, 1: right, etc...)
local oddHeight = false
local fuelCheckLimit = 1000
local slotNum = 1

print("Please enter how high the cleared area will need to be:")
local height = tonumber(read())
print("Please enter how wide the cleared area will need to be:")
local width = tonumber(read())
print("Please enter how long the cleared area will need to be:")
local length = tonumber(read())

if(height % 2 == 1) then -- detects odd height for code
	oddHeight = true
end

-- Initial moving forward until block detected
while(not turtle.detect()) do
	while(not turtle.forward()) do
		turtle.attack()
	end
	originFB = originFB + 1
end

-- Block encountered, initialise clear position
while(turtle.detect()) do
	turtle.dig()
end
while(not turtle.forward()) do
	turtle.attack()
end
turtle.turnRight()

nextLayer = false
local continue = true
-- In position, begin clearing
while(continue) do
	-- refuel check
	if(turtle.getFuelLevel() < fuelCheckLimit) then
		if(originUD > 1) then
			turtle.select(refuelChest)
			turtle.placeDown()
		else
			turtle.select(1)
			while(turtle.detectUp()) do
				turtle.digUp()
			end
			turtle.select(refuelChest)
			turtle.placeUp()
		end
		-- refuelling...
		while(turtle.getFuelLevel() < fuelCheckLimit) do
			turtle.select(blankSlot)
			turtle.refuel()
		end
		-- finished, getting chest back
		turtle.select(refuelChest)
		if(originUD > 1) then
			turtle.digDown()
		else
			turtle.digUp()
		end
	end
	
	-- dump check
	if(turtle.getItemCount(totalSlots) > 0) then
		if(originUD > 1) then
			turtle.select(dumpChest)
			turtle.placeDown()
		else
			turtle.select(1)
			while(turtle.detectUp()) do
				turtle.digUp()
			end
			turtle.select(dumpChest)
			turtle.placeUp()
		end
		-- dumping...
		for slotNum = 1, totalSlots do
			turtle.select(slotNum)
			if(originUD > 1) then
				turtle.dropDown()
			else
				turtle.dropUp()
			end
		end
		-- finished, getting chest back
		turtle.select(dumpChest)
		if(originUD > 1) then
			turtle.digDown()
		else
			turtle.digUp()
		end
	end
	
	-- dig check
	if(originUD == height) then	-- check if need to move to next layer
		if(oddHeight) then
			if(originRL == width) then
				nextLayer = true
			end
		else
			if(originRL == 1) then
				nextLayer = true
			end
		end
	end
	
	-- Do required action
	if(nextLayer) then
		-- check if aligned left
		while(direction ~= 3) do
			turtle.turnLeft()
			direction = direction - 1
			if(direction < 0) then
				direction = 3
			end
		end
		
		-- check position
		while(originRL ~= 1) do
			while(turtle.detect()) do
				turtle.dig()
			end
			while(not turtle.forward()) do
				turtle.attack()
			end
			originRL = originRL - 1
		end
		while(originUD ~= 1) do
			while(turtle.detectDown()) do
				turtle.digDown()
			end
			while(not turtle.down()) do
				turtle.attackDown()
			end
			originUD = originUD - 1
		end
		
		-- Check if continue to next layer or go back to origin
		if(originFB == length) then -- go back to origin
			while(direction ~= 2) do
				turtle.turnLeft()
				direction = direction - 1
				if(direction < 0) then
					direction = 3
				end
			end
			while(originFB ~= 0) then
				while(turtle.detect()) do
					turtle.dig()
				end
				while(not turtle.forward()) do
					turtle.attack()
				end
				originFB = originFB - 1
			end
			turtle.turnLeft()
			turtle.turnLeft()
			continue = false	-- should break loop and stop the clear code
		else -- go to next layer
			turtle.turnRight()
			while(turtle.detect()) do
				turtle.dig()
			end
			while(not turtle.forward()) do
				turtle.attack()
			end
			turtle.turnRight()
			direction = 1
			nextLayer = false
			originFB = originFB + 1
		end
	else
		-- Check if need to move to next row
		if((originRL == 1 and direction == 3) or (originRL == width and direction == 1)) then
			while(turtle.detectUp()) do
				turtle.digUp()
			end
			while(not turtle.up()) do
				turtle.attackUp()
			end
			originUD = originUD + 1
			turtle.turnLeft()
			turtle.turnLeft()
			if(direction == 1) then
				direction == 3
			elseif(direction == 3) then
				direction == 1
			end
		else	-- dig forward normally
			while(turtle.detect()) do
				turtle.dig()
			end
			while(not turtle.forward()) do
				turtle.attack()
			end
			if(direction == 1) then
				originRL = originRL + 1
			elseif(direction == 3) then
				originRL = originRL - 1
			end
		end
	end
end

print("Finished clearing area")

-- Program #4: Selective Quarry Turtle
-- Inspired from a speedy quarry turtle vid, this will not mine the two blocks provided in the 13th and 14th slot, will dump the mined materials into the dump chest located in the 15th slot, and will refuel from the chest in the 16th slot
-- This code is meant to rival the speed of a quarry as well as the speed of the turtle in the vid by eliminating the need to mine all blocks and for the turtle to continuously go back up to the surface to dump materials and refuel.
-- This code is intended to NOT mine past the bedrock level, but it will (hopefully) expose the top level.

-- Required steps to fulfil similar algorithm of speed quarry turtle:
-- 1. Mine down to bottom level to collect rare ores first
-- 2. Move up 3 blocks and repeat the process, returning to original corner to simplify code
-- 3. Mine entire level it is on, while checking block directly above and below itself to see if it is the same as provided blocks it needs to ignore.
-- 4. Once slot 11 has at least one block in it, place dump chest down behind itself and immediately dump all inventory besides the last four slots into the dump chest, pick it back up, turn around, then continue mining.
-- 5. Turtle will check for refuel depending on size of area being mined once per layer to increase speed. Note: Each chunk is a 16x16 area. Therefore, if you want to maximise the amount of materials the turtle can mine while minimising the use of a chunk loader, here are the relative values required. Recommended fuel levels are based on total number of blocks per layer, plus another 2 times the width of the square being quarried, plus another 5 to make sure it is in place before the next fuel check. Depending on how long the refuel process takes, it may be faster to provide fuel every few levels rather than every level.
-- > 1 chunk radius (16x16): 256 blocks; recommended 293 fuel limit minimum
-- > 2 chunk radius (48x48): 2304 blocks; recommended 2405 fuel limit minimum
-- > etc... will likely program this into the turtle to automatically determine if it has enough fuel for a full layer depending on provided area size
-- 6. Will need testing, but when it breaks blocks, it will always immediately suck in whatever direction it was breaking. Hopefully this will handle obtaining items from whenever inventories of any sort that are broken as a result of this mining procedure. If not, it will need to be considered as to whether or not the turtle checks for chests on top of this auto-suck operation to obtain the maximum amount of loot while quarrying.

-- Program #5: ME Bridge Programs
-- These programs can be used in a variety of ways, but basically requires the ME Bridge and a connecting computer to be used.

--needed
meb = peripheral.wrap("<side ME Bridge is on>")

-- Auto-resupply subsystem bridge (optional STANDALONE)
-- Note: It is recommended to make dedicated machines for processing required materials to prevent clogging up the system.
-- Note2: This program will ensure at least 10 stacks of each item is available in the sub-system, while another 10 stacks are available in the main system. This will ensure that there is still a backlog supply, useful as it will only do an action every 10 seconds IN ORDER, requesting/crafting items as necessary.
-- Note3: An ME Interface will be located to the right of the computer for dumping items into the subsystem
-- Note4: IDs are as follows:
-- > Torch: 50
-- > Sandstone: 24
-- > Charcoal: 263:1
-- > Cobblestone: 4
local mebMAIN = peripheral.wrap("top")
local mebSUB = peripheral.wrap("bottom")
-- following table reserved only for craft-able items
local itemSupplyTable = {50, 24, 263:1}
local supplyNum = 3
-- following table reserved only for non-craft-able items
local itemSimpleTable = {4}
local simpleNum = 1
while(true) do
	for iter = 1, supplyNum do
		if(mebSUB.listItems()[itemSupplyTable[iter]] < (64*10)) then
			mebSUB.retrieve(itemSupplyTable[iter], ((64*10) - mebSUB.listItems()[itemSupplyTable[iter]]), "right")
		end
		sleep(10)
		if(mebMAIN.listItems()[itemSupplyTable[iter]] < (64*10)) then
			mebMAIN.craft(itemSupplyTable[iter], ((64*10) - mebSUB.listItems()[itemSupplyTable[iter]]))
		end
		sleep(10)
	end
	-- Note that "Simple" basically means that it can't be crafted and is pretty much the 'raw' material
	for iter = 1, simpleNum do
		if((mebSUB.listItems()[itemSimpleTable[iter]] < (64*10)) and (mebMAIN.listItems()[itemSimpleTable[iter]] > (64*10))) then
			mebSUB.retrieve(itemSimpleTable[iter], ((64*10) - mebSUB.listItems()[itemSimpleTable[iter]]), "right")
		end
		sleep(10)
	end
end

-- Auto-Restocking Management Monitor (Optional STANDALONE)
-- Similar to the auto-resupply subsystem, although this is just to keep basic crafting materials stocked, as it would reduce the time taken to wait for materials to be processed in slower machines.
-- GT steel: 21256:26
-- Iron: 265
-- Refined Iron:
-- Flint:
-- Sand:
-- Glass:
-- Tin:
-- Copper:
-- Bronze:
-- Lead:
-- Electrum:
-- Silver:
-- String (only until spiders are put into grinder):
-- Wool (tricky... as we could use string or cotton):
-- Note: Currently hardcoded to keep two stacks in stock at all times of every provided material
local mebMAIN = peripheral.wrap("top")
local itemStockTable = {<place item ids here like in the previous program>}
local stockNum = <total items in table>

while(true) do
	for iter = 1, stockNum do
		if(mebMAIN.listItems()[itemStockTable[iter]] < (64*2)) then
			meb.craft(itemStockTable[iter], ((64*2) - meb.listItems()[itemSimpleTable[iter]]))
		end
		sleep(10)
	end
end

-- Auto-Restock Advanced Management Monitor (MASTER)
-- Basically, advanced version of everything mentioned, as it keeps things supplied while also checking if the raw materials required are plentiful in supply depending on provided info
-- TODO
local mebMAIN = peripheral.wrap("top")
local mebSUB = peripheral.wrap("bottom")
local resupplyTable = {<place items here that require resupply>}
local requiredTable = {}
local resupplyNum = <total number of items required for resupply>
for iter = 1, resupplyNum do
	requiredTable[iter] = {}	-- used to provide ids of any materials required to make the item at iter
	-- Note: will need to be extended one more so the id and amount of each item required can be placed at positin iter
end


-- How to use
return meb.listItems()[itemID] -- returns amount
return meb.retrieve(itemID, amount, direction) -- returns amount sent
meb.craft(itemID, amount) -- attempts to craft item