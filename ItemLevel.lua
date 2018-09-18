local DAI = select(2, ...)
--------------------------------------------------------------------------------
-- ItemLevel strings
-- fyhcslb
--------------------------------------------------------------------------------

local I = LibStub("LibItemUpgradeInfo-1.0")
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

CreateFrame("GameTooltip", "DAI_ScanningTooltip", nil, "GameTooltipTemplate")

-- http://www.wowinterface.com/forums/showthread.php?p=271406 Phanx
local S_ITEM_LEVEL = "^" .. string.gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")
-- should not use itemLink, may contain inaccurate data
local function GetItemLevelByTooltip(slot, bag)
	local ilvl, scanedIlvl = 0, 0
	
	-- use scanner
	DAI_ScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	if bag then
		ilvl = I:GetUpgradedItemLevel(GetContainerItemLink(bag, slot)) or 0
		DAI_ScanningTooltip:SetBagItem(bag, slot)
	else
		ilvl = I:GetUpgradedItemLevel(GetInventoryItemLink("player", slot)) or 0
		DAI_ScanningTooltip:SetInventoryItem("player", slot)
	end

	for i = 2, DAI_ScanningTooltip:NumLines() do
		local text = _G["DAI_ScanningTooltipTextLeft"..i]:GetText()
        if text and string.find(text, S_ITEM_LEVEL) then
			scanedIlvl = string.match(text, S_ITEM_LEVEL)
			scanedIlvl = tonumber(scanedIlvl)
			break
        end
	end

	return scanedIlvl and scanedIlvl or ilvl
end

local function Update(id, itemLink, flyoutButton, flyoutButtonID, flyoutBag, flyoutBagSlot)
	local slotFontString = GetSlotFontString(id, flyoutButton)
	
	-- not shown slot, also hide on its flyouts
	if flyoutButtonID and not slotIDs[flyoutButtonID] then
		slotFontString:SetText("")
		return
	end

	if itemLink then  -- has item
		local s = ""
		-- ilevel
		local iLevel

		-- forceTooltip or isArtifactWeapon Legion
		if DurabilityAndItemLevel["forceTooltip"] or ((id == 16 or id == 17) and select(3, GetItemInfo(itemLink)) == 6) then
			-- GetInventoryItemQuality("player", id) == 6
			if flyoutBag and flyoutBagSlot then
				iLevel = GetItemLevelByTooltip(flyoutBagSlot, flyoutBag)
			else
				iLevel = GetItemLevelByTooltip(id)
			end
		else
			iLevel = I:GetUpgradedItemLevel(itemLink)
		end
		
		if iLevel then
			-- local iQualityColor = select(4, GetItemQualityColor(GetInventoryItemQuality("player", id)))
			-- local iQualityColor = string.sub(select(2, strsplit("|", itemLink)), 2)
			-- itemId:enchantId:jewelId1:jewelId2:jewelId3:jewelId4:suffixId:uniqueId:linkLevel
			local iQualityColor, itemString = itemLink:match("(|c%x+)|Hitem:([-%d:]+)|h%[.-%]|h|r")

			s = iQualityColor .. iLevel
			
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
				
				-- weapon, hands, fingers
				if tContains({10, 11, 12, 16}, id) or tContains({10, 11, 12, 16}, flyoutButtonID) then
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
			
			slotFontString:SetText(s)
		else
			slotFontString:SetText("")
		end
	else
		slotFontString:SetText("")
	end
end

local function UpdateFlyout(button)
	local location = button.location
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
	
	local itemLink = nil
	if voidStorage and voidSlot then -- currently ignore void storage
		itemLink = nil
	elseif bag and slot then
		itemLink = GetContainerItemLink(bag, slot)
	elseif (player and slot) then
		itemLink = GetInventoryItemLink("player", slot)
	end
	
	-- button.id: invertoryID, check enchant
	Update(button:GetName(), itemLink, button, button.id, bag, slot)
end

function DAI:UpdateAllIlvl()
	for id, _ in pairs(slotIDs) do
		Update(id, GetInventoryItemLink("player", id))
	end
end

local oldFlyout
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		CharacterFrame:HookScript("OnShow", function()
			-- f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:RegisterEvent("UNIT_INVENTORY_CHANGED")
			C_Timer.After(.1, function()
				DAI:UpdateAllIlvl()
			end)
		end)
		
		CharacterFrame:HookScript("OnHide", function()
			-- f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
		end)

		-- Interface\FrameXML\EquipmentFlyout.lua
		hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
			UpdateFlyout(button)
		end)

	else -- PLAYER_EQUIPMENT_CHANGED or UNIT_INVENTORY_CHANGED
		-- if slotIDs[arg1] then
		-- 	Update(arg1, GetInventoryItemLink("player", arg1))
		-- end
		if arg1 == "player" then
			C_Timer.After(.1, function()
				DAI:UpdateAllIlvl()
			end)
		end
	end
end)