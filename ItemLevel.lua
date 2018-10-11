local DAI = select(2, ...)
--------------------------------------------------------------------------------
-- ItemLevel strings
-- fyhcslb
--------------------------------------------------------------------------------

DAI.ALWAYS_USE_TOOLTIP = true
local slotFontStrings = {}
DAI.ilvlFontStrings = slotFontStrings
local slotIDs = { -- http://wowprogramming.com/docs/api_types#inventoryID
	[1] = "HeadSlot",
	[2] = "NeckSlot",
	[3] = "ShoulderSlot",
	[5] = "ChestSlot",
	[6] = "WaistSlot",
	[7] = "LegsSlot",
	[8] = "FeetSlot",
	[9] = "WristSlot",
	[10] = "HandsSlot",
	[11] = "Finger0Slot",
	[12] = "Finger1Slot",
	[13] = "Trinket0Slot",
	[14] = "Trinket1Slot",
	[15] = "BackSlot",
	[16] = "MainHandSlot",
	[17] = "SecondaryHandSlot"
}

local function GetSlotFontString(id, slot)
	if(not slotFontStrings[id]) then
		if not slot then -- not flyout button
			slot = _G["Character" .. slotIDs[id]]
		end
		slotFontStrings[id] = slot:CreateFontString(nil, "OVERLAY")
		
		slotFontStrings[id]:SetFont(unpack(DAI:GetFont()))
		slotFontStrings[id]:SetPoint(unpack(DurabilityAndItemLevel["ilvlPoint"]))
	end
	return slotFontStrings[id]
end

CreateFrame("GameTooltip", "DAI_Scanner", WorldFrame, "GameTooltipTemplate")

-- http://www.wowinterface.com/forums/showthread.php?p=271406 Phanx
local S_ITEM_LEVEL = "^" .. string.gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

-- should not use itemLink, may contain inaccurate data
function DAI:GetItemLevelFromTooltip(slot, bag)
	local ilvl, scanedIlvl = 0
	
	-- use scanner
	DAI_Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
	if bag then
		ilvl = select(4, GetItemInfo(GetContainerItemLink(bag, slot))) or 0
		if bag == -1 then
			DAI_Scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slot, nil))
		else
			DAI_Scanner:SetBagItem(bag, slot)
		end
	else
		ilvl = select(4, GetItemInfo(GetInventoryItemLink("player", slot))) or 0
		DAI_Scanner:SetInventoryItem("player", slot)
	end

	for i = 2, DAI_Scanner:NumLines() do
		local text = _G["DAI_ScannerTextLeft"..i]:GetText()
        if text and string.find(text, S_ITEM_LEVEL) then
			scanedIlvl = string.match(text, S_ITEM_LEVEL)
			scanedIlvl = tonumber(scanedIlvl)
			break
        end
	end

	return scanedIlvl and scanedIlvl or ilvl
end

function DAI:GetItemInfo(itemLink, iLevel, checkEnchant)
	-- local iQualityColor = select(4, GetItemQualityColor(GetInventoryItemQuality("player", slotID)))
	-- local iQualityColor = string.sub(select(2, strsplit("|", itemLink)), 2)
	-- itemId:enchantId:jewelId1:jewelId2:jewelId3:jewelId4:suffixId:uniqueId:linkLevel
	local iQualityColor, itemString = itemLink:match("(|c%x+)|Hitem:([-%d:]+)|h%[.-%]|h|r")

	local s = iQualityColor .. iLevel
			
	-- gem & enchant
	if iLevel >= 300 then -- don't check old items
		local itemStats = GetItemStats(itemLink)
		local g = 1
		local e = 1
			
		if itemStats["EMPTY_SOCKET_PRISMATIC"] then -- has socket
			local gem = select(3, string.split(":", itemString))
			if gem == "" then g = 0 end
		end
		table.wipe(itemStats)
				
		if checkEnchant then
			local enchant = select(2, strsplit(":", itemString))
			if enchant == "" then e = 0 end
		end
			
		local result = tonumber(g .. e)
		if result == 10 then
			s = s .. " |cffff0000E|r"
		elseif result == 01 then
			s = s .. " |cffff0000G|r"
		elseif result == 00 then
			s = s .. " |cffff0000EG|r"
		end
	end

	return s
end

local function Update(slotID, itemLink, flyoutButton, flyoutButtonID, flyoutBag, flyoutSlot)
	local slotFontString = GetSlotFontString(slotID, flyoutButton)
	
	-- if slot is ignored, also hide on its flyouts
	if flyoutButtonID and not slotIDs[flyoutButtonID] then
		slotFontString:SetText("")
		return
	end

	local s = ""
	if itemLink then  -- has item
		-- ilevel
		local iLevel

		-- forceTooltip or isArtifactWeapon Legion
		-- if DurabilityAndItemLevel["forceTooltip"] or ((slotID == 16 or slotID == 17) and select(3, GetItemInfo(itemLink)) == 6) then -- GetInventoryItemQuality("player", slotID) == 6
		if DAI.ALWAYS_USE_TOOLTIP then
			if flyoutBag and flyoutSlot then
				iLevel = DAI:GetItemLevelFromTooltip(flyoutSlot, flyoutBag)
			else
				if flyoutSlot then slotID = flyoutSlot end -- flyoutBag == nil, it's an equipped item. Rings, Trinkets, Single-hand Weapons...
				iLevel = DAI:GetItemLevelFromTooltip(slotID)
			end
		else
			iLevel = select(4, GetItemInfo(itemLink))
		end
		
		if iLevel then
			local checkEnchant = false
			-- mainhand, hands, fingers
			if tContains({10, 11, 12, 16}, slotID) or tContains({10, 11, 12, 16}, flyoutButtonID) then
				checkEnchant = true
			elseif slotID == 17 or flyoutButtonID == 17 then -- offhand
				local itemEquipLoc = select(4, GetItemInfoInstant(itemLink))
				if itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
					checkEnchant = true
				end
			end
			
			s = DAI:GetItemInfo(itemLink, iLevel, checkEnchant)
		end
	end
	slotFontString:SetText(s)
end

local function UpdateFlyout(button)
	local location = button.location
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
	
	local itemLink = nil
	if voidStorage and voidSlot then -- currently ignore void storage
		itemLink = nil
	elseif bag and slot then
		itemLink = GetContainerItemLink(bag, slot)
	elseif bank or (player and slot) then -- main bank bag begins with 48
		itemLink = GetInventoryItemLink("player", slot)
	end

	-- button.id: invertoryID (slotID)
	-- button:GetName() -> EquipmentFlyoutFrameButton1 ...
	Update(button:GetName(), itemLink, button, button.id, bag, slot)
end

function DAI:UpdateAllIlvl()
	for id, _ in pairs(slotIDs) do
		Update(id, GetInventoryItemLink("player", id))
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		CharacterFrame:HookScript("OnShow", function()
			f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:RegisterEvent("UNIT_INVENTORY_CHANGED")
			C_Timer.After(.1, function()
				DAI:UpdateAllIlvl()
			end)
		end)
		
		CharacterFrame:HookScript("OnHide", function()
			f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
		end)

		-- Interface\FrameXML\EquipmentFlyout.lua
		hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
			UpdateFlyout(button)
		end)

	elseif event == "UNIT_INVENTORY_CHANGED" then -- UNIT_INVENTORY_CHANGED
		if arg1 == "player" then
			C_Timer.After(.1, function()
				DAI:UpdateAllIlvl()
			end)
		end
	else -- PLAYER_EQUIPMENT_CHANGED
		if slotIDs[arg1] then
			Update(arg1, GetInventoryItemLink("player", arg1))
		end
		
	end
end)