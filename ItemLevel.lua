local DAI = select(2, ...)
--------------------------------------------------------------------------------
-- ItemLevel strings
--------------------------------------------------------------------------------

local GetItemInfo = C_Item.GetItemInfo
local GetItemStats = C_Item.GetItemStats
local GetItemInfoInstant = C_Item.GetItemInfoInstant
local GetItemQualityColor = C_Item.GetItemQualityColor

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

-- local specEnchantSlots = {
--     -- 250 - Death Knight: Blood
--     [250] = {},
--     -- 251 - Death Knight: Frost
--     [251] = {},
--     -- 252 - Death Knight: Unholy
--     [252] = {},

--     -- 577 - Demon Hunter: Havoc
--     [577] = {},
--     -- 581 - Demon Hunter: Vengeance
--     [581] = {},

--     -- 102 - Druid: Balance
--     [102] = {},
--     -- 103 - Druid: Feral
--     [103] = {},
--     -- 104 - Druid: Guardian
--     [104] = {},
--     -- Druid: Restoration
--     [105] = {},

--     -- 253 - Hunter: Beast Mastery
--     [253] = {},
--     -- 254 - Hunter: Marksmanship
--     [254] = {},
--     -- 255 - Hunter: Survival
--     [255] = {},

--     -- 62 - Mage: Arcane
--     [62] = {},
--     -- 63 - Mage: Fire
--     [63] = {},
--     -- 64 - Mage: Frost
--     [64] = {},

--     -- 268 - Monk: Brewmaster
--     [268] = {},
--     -- 269 - Monk: Windwalker
--     [269] = {},
--     -- 270 - Monk: Mistweaver
--     [270] = {},

--     -- 65 - Paladin: Holy
--     [65] = {},
--     -- 66 - Paladin: Protection
--     [66] = {},
--     -- 70 - Paladin: Retribution
--     [70] = {},

--     -- 256 - Priest: Discipline
--     [256] = {},
--     -- 257 - Priest: Holy
--     [257] = {},
--     -- 258 - Priest: Shadow
--     [258] = {},

--     -- 259 - Rogue: Assassination
--     [259] = {},
--     -- 260 - Rogue: Outlaw
--     [260] = {},
--     -- 261 - Rogue: Subtlety
--     [261] = {},

--     -- 262 - Shaman: Elemental
--     [262] = {},
--     -- 263 - Shaman: Enhancement
--     [263] = {},
--     -- 264 - Shaman: Restoration
--     [264] = {},

--     -- 265 - Warlock: Affliction
--     [265] = {},
--     -- 266 - Warlock: Demonology
--     [266] = {},
--     -- 267 - Warlock: Destruction
--     [267] = {},

--     -- 71 - Warrior: Arms
--     [71] = {},
--     -- 72 - Warrior: Fury
--     [72] = {},
--     -- 73 - Warrior: Protection
--     [73] = {},
-- }

local function GetSlotFontString(id, slot)
    if(not slotFontStrings[id]) then
        if not slot then -- not flyout button
            slot = _G["Character" .. slotIDs[id]]
        end
        slotFontStrings[id] = slot:CreateFontString(nil, "OVERLAY")

        slotFontStrings[id]:SetFont(unpack(DAI.GetFont()))
        slotFontStrings[id]:SetPoint(unpack(DurabilityAndItemLevel["ilvlPoint"]))
    end
    return slotFontStrings[id]
end

-- CreateFrame("GameTooltip", "DAI_Scanner", WorldFrame, "GameTooltipTemplate")

-- http://www.wowinterface.com/forums/showthread.php?p=271406 Phanx
local S_ITEM_LEVEL = "^" .. string.gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

-- should not use itemLink, may contain inaccurate data
function DAI.GetItemLevelFromTooltip(slot, bag)
    local ilvl, scanedIlvl = 0
    local tooltipData

    -- use scanner
    -- DAI_Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
    if bag then
        ilvl = select(4, GetItemInfo(C_Container.GetContainerItemLink(bag, slot))) or 0
        if bag == -1 then
            -- DAI_Scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slot, nil))
            tooltipData = C_TooltipInfo.GetInventoryItem("player", BankButtonIDToInvSlotID(slot, nil))
        else
            -- DAI_Scanner:SetBagItem(bag, slot)
            tooltipData = C_TooltipInfo.GetBagItem(bag, slot)
        end
    else
        ilvl = select(4, GetItemInfo(GetInventoryItemLink("player", slot))) or 0
        -- DAI_Scanner:SetInventoryItem("player", slot)
        tooltipData = C_TooltipInfo.GetInventoryItem("player", slot)
    end

    -- for i = 2, DAI_Scanner:NumLines() do
    --     local text = _G["DAI_ScannerTextLeft"..i]:GetText()
    --     if text and string.find(text, S_ITEM_LEVEL) then
    --         scanedIlvl = string.match(text, S_ITEM_LEVEL)
    --         scanedIlvl = tonumber(scanedIlvl)
    --         break
    --     end
    -- end

    if tooltipData then
        for i = 2, #tooltipData.lines do
            local line = tooltipData.lines[i]
            if line.leftText and string.find(line.leftText, S_ITEM_LEVEL) then
                scanedIlvl = string.match(line.leftText, S_ITEM_LEVEL)
                scanedIlvl = tonumber(scanedIlvl)
                break
            end
        end
    end

    return scanedIlvl and scanedIlvl or ilvl
end

local function ConvertRGBToHEX(r, g, b)
    local result = ""

    for key, value in pairs({r*255, g*255, b*255}) do
        local hex = ""

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = "00"

        elseif(string.len(hex) == 1)then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

function DAI.GetItemInfo(itemLink, iLevel, checkEnchant)
    -- https://warcraft.wiki.gg/wiki/ItemLink
    -- item : itemID : enchantID : gemID1 : gemID2 : gemID3 : gemID4 : suffixID : uniqueID : linkLevel : specializationID : modifiersMask : itemContext : numBonusIDs[:bonusID1:bonusID2:...] : numModifiers[:modifierType1:modifierValue1:...] : relic1NumBonusIDs[:relicBonusID1:relicBonusID2:...] : relic2NumBonusIDs[...] : relic3NumBonusIDs[...] : crafterGUID : extraEnchantID
    local quality, itemString = itemLink:match("|cnIQ(%d):|Hitem:(.+)|h%[.*%]|h|r")

    local s
    if DurabilityAndItemLevel["customIlvlColor"][1] then
        s = "|cff" .. ConvertRGBToHEX(unpack(DurabilityAndItemLevel["customIlvlColor"][2])) .. iLevel
    else
        quality = select(4, GetItemQualityColor(quality))
        s = "|c" .. quality .. iLevel
    end

    -- gem & enchant
    if iLevel >= 600 then -- don't check old items
        local itemStats = GetItemStats(itemLink)
        local g = 1
        local e = 1

        if itemStats["EMPTY_SOCKET_PRISMATIC"] then -- has socket
            local gem = select(3, string.split(":", itemString))
            if gem == "" then g = 0 end
        end
        wipe(itemStats)

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

-- local requireGatheringEnchant, isPrimaryStatStrength
local checkedSlots = {5, 7, 8, 9, 11, 12, 15, 16} -- chest, legs, feet, wrist, fingers, back, mainhand
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
        if flyoutBag and flyoutSlot then
            iLevel = DAI.GetItemLevelFromTooltip(flyoutSlot, flyoutBag)
        else
            if flyoutSlot then slotID = flyoutSlot end -- flyoutBag == nil, it's an equipped item. Rings, Trinkets, Single-hand Weapons...
            iLevel = DAI.GetItemLevelFromTooltip(slotID)
        end

        if iLevel then
            local checkEnchant = false

            -- if requireGatheringEnchant or isPrimaryStatStrength then
            --     checkedSlots = {5, 8, 9, 10, 11, 12, 15, 16} -- chest, feet, wrist, hands, fingers, back, mainhand
            -- else
            --     checkedSlots = {5, 8, 9, 11, 12, 15, 16} -- chest, feet, wrist, fingers, back, mainhand
            -- end

            if tContains(checkedSlots, slotID) or tContains(checkedSlots, flyoutButtonID) then
                checkEnchant = true
            elseif slotID == 17 or flyoutButtonID == 17 then -- offhand
                local itemEquipLoc = select(4, GetItemInfoInstant(itemLink))
                if itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
                    checkEnchant = true
                end
            end

            s = DAI.GetItemInfo(itemLink, iLevel, checkEnchant)
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
        itemLink = C_Container.GetContainerItemLink(bag, slot)
    elseif bank or (player and slot) then -- main bank bag begins with 48
        itemLink = GetInventoryItemLink("player", slot)
    end

    -- button.id: invertoryID (slotID)
    -- button:GetName() -> EquipmentFlyoutFrameButton1 ...
    Update(button:GetName(), itemLink, button, button.id, bag, slot)
end

function DAI.UpdateAllIlvl()
    for id, _ in pairs(slotIDs) do
        Update(id, GetInventoryItemLink("player", id))
    end
end

-- local function UpdateProfessions()
--     local prof1, prof2 = GetProfessions()
--     if prof1 then
--         prof1 = select(7, GetProfessionInfo(prof1))
--         prof1 = (prof1 == 182) or (prof1 == 186) or (prof1 == 393)
--     end
--     if prof2 then
--         prof2 = select(7, GetProfessionInfo(prof2))
--         prof2 = (prof2 == 182) or (prof2 == 186) or (prof2 == 393)
--     end
--     requireGatheringEnchant = prof1 or prof2
-- end

-- local function UpdatePrimaryStat()
--     -- Spec's primary stat, as listed in SPEC_STAT_STRINGS[1] global. 1 - Strength, 2 - Agility, 4 - Intellect.
--     local primaryStat = select(6, GetSpecializationInfo(GetSpecialization()))
--     isPrimaryStatStrength = primaryStat == 1
-- end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- f:RegisterEvent("SKILL_LINES_CHANGED")
-- f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")

        -- UpdateProfessions()
        -- UpdatePrimaryStat()

        CharacterFrame:HookScript("OnShow", function()
            f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            f:RegisterEvent("UNIT_INVENTORY_CHANGED")
            C_Timer.After(0.1, function()
                DAI.UpdateAllIlvl()
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

    -- elseif event == "SKILL_LINES_CHANGED" then
    --     UpdateProfessions()

    -- elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
    --     UpdatePrimaryStat()

    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            C_Timer.After(0.1, function()
                DAI.UpdateAllIlvl()
            end)
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if slotIDs[arg1] then
            Update(arg1, GetInventoryItemLink("player", arg1))
        end

    end
end)