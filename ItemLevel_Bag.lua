local DAI = select(2, ...)
--------------------------------------------------------------------------------
-- ItemLevel strings
-- fyhcslb
--------------------------------------------------------------------------------

local bagFontStrings = {}
DAI.bagFontStrings = bagFontStrings

function DAI:UpdateAllBags(show)
    if not show then
        for _, s in pairs(bagFontStrings) do
            s:SetText("")
        end
    end
end

local function GetButtonFontString(button)
    local name = button:GetName()
    if not bagFontStrings[name] then
        bagFontStrings[name] = button:CreateFontString(nil, "OVERLAY")
        bagFontStrings[name]:SetFont(unpack(DAI:GetFont()))
        bagFontStrings[name]:SetPoint(unpack(DurabilityAndItemLevel["bagPoint"]))
    end
    return bagFontStrings[name]
end

local checkedSlots = {"INVTYPE_FINGER", "INVTYPE_WRIST", "INVTYPE_CHEST", "INVTYPE_FEET", "INVTYPE_CLOAK", "INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND", "INVTYPE_RANGED"}
local function UpdateButton(button, bag, slot)
    if not DurabilityAndItemLevel["showInBags"] then return end

    local buttonFontString = GetButtonFontString(button)
    local itemLink = C_Container.GetContainerItemLink(bag, slot)

    local s = ""
    if itemLink then  -- has item
        local iLevel

        -- itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID
        local _, _, _, itemEquipLoc, _, itemClassID = GetItemInfoInstant(itemLink)

        if itemEquipLoc and itemEquipLoc ~= "" then
            -- if not tContains({2, 4}, itemClassID) then
            -- 	buttonFontString:SetText("")
            -- 	return
            -- end 

            -- get ilvl
            iLevel = DAI:GetItemLevelFromTooltip(slot, bag)

            if iLevel and iLevel >= DurabilityAndItemLevel["iThreshold"] then
                local checkEnchant = false
                if tContains(checkedSlots, itemEquipLoc) then
                    checkEnchant = true
                end
                
                s = DAI:GetItemInfo(itemLink, iLevel, checkEnchant)
            end
        end
    end
    buttonFontString:SetText(s)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    frame:UnregisterAllEvents()

    if IsAddOnLoaded("Bagnon") then -- Bagnon
        hooksecurefunc(Bagnon.Item, "Update", function(self)
            UpdateButton(self, self:GetBag(), self:GetID())
        end)
        
    elseif IsAddOnLoaded("Baggins") then -- Baggins
        hooksecurefunc(Baggins, "UpdateItemButton", function(baggins, bagframe, button, bag, slot)
            UpdateButton(button, bag, slot)
        end)

    elseif IsAddOnLoaded("Combuctor") then -- Combuctor
        hooksecurefunc(Combuctor.Item, "Update", function(self)
            UpdateButton(self, self:GetBag(), self:GetID())
        end)

    elseif IsAddOnLoaded("Inventorian") then -- Inventorian -- stolen from Simple Item Level
        local Inventorian = LibStub("AceAddon-3.0", true):GetAddon("Inventorian", true)
        local function ToIndex(bag, slot)
            return (bag < 0 and bag * 100 - slot) or (bag * 100 + slot)
        end
        local function UpdateSlot(self, bag, slot)
            if not self.items[ToIndex(bag, slot)] then return end
            UpdateButton(self.items[ToIndex(bag, slot)], bag, slot)
        end
        local function hookInventorian()
            hooksecurefunc(Inventorian.bag.itemContainer, "UpdateSlot", UpdateSlot)
            hooksecurefunc(Inventorian.bank.itemContainer, "UpdateSlot", UpdateSlot)
        end
        if Inventorian.bag then
            hookInventorian()
        else
            hooksecurefunc(Inventorian, "OnEnable", function()
                hookInventorian()
            end)
        end

    else -- blizzard bags
        -- hooksecurefunc("ContainerFrame_Update", function(frame)
        --     for i = 1, frame.size do
        --         local itemButton  = _G[frame:GetName() .. "Item" .. i]
        --         if itemButton then
        --             UpdateButton(itemButton, frame:GetID(), itemButton:GetID())
        --         end
        --     end
        -- end)
        --! Interface\FrameXML\ContainerFrame.lua - ContainerFrameMixin:UpdateItems()
        local function UpdateItems(frame)
            -- print(frame:GetName())
            for _, itemButton in frame:EnumerateValidItems() do
                UpdateButton(itemButton, itemButton:GetBagID(), itemButton:GetID())
            end
        end
        for _, frame in ipairs(UIParent.ContainerFrames) do
            hooksecurefunc(frame, "UpdateItems", UpdateItems)
        end
        hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", UpdateItems)

        -- blizzard bank bags
        hooksecurefunc("BankFrameItemButton_Update", function(button)
            if not button.isBag then
                UpdateButton(button, -1, button:GetID())
            end
        end)
    end
end)