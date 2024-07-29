local DAI = select(2, ...)
--------------------------------------------------------------------------------
-- Durability strings
-- fyhcslb
--------------------------------------------------------------------------------

local slotFontStrings = {}
DAI.durFontStrings = slotFontStrings
local slotIDs = { -- http://wowprogramming.com/docs/api_types#inventoryID
    [1] = "HeadSlot",
    [3] = "ShoulderSlot",
    [5] = "ChestSlot",
    [6] = "WaistSlot",
    [7] = "LegsSlot",
    [8] = "FeetSlot",
    [9] = "WristSlot",
    [10] = "HandsSlot",
    [16] = "MainHandSlot",
    [17] = "SecondaryHandSlot"
}

local function GetSlotFontString(slotID)
    if not slotFontStrings[slotID] then
        local slot = _G["Character" .. slotIDs[slotID]]
        slotFontStrings[slotID] = slot:CreateFontString(nil, "OVERLAY")

        slotFontStrings[slotID]:SetFont(unpack(DAI.GetFont()))
        slotFontStrings[slotID]:SetPoint(unpack(DurabilityAndItemLevel["durPoint"]))
    end
    return slotFontStrings[slotID]
end

local function GetThresholdColor(percent)
    if percent < 0 then
        return 1, 0, 0
    elseif percent <= 0.5 then
        return 1, percent * 2, 0
    elseif percent >= 1 then
        return 0, 1, 0
    else
        return 2 - percent * 2, 1, 0
    end
end

local function UpdateDur(slotID)
    if not DurabilityAndItemLevel["showDur"] then
        if slotFontStrings[slotID] then
            slotFontStrings[slotID]:Hide()
        end
        return
    end

    local v1, v2 = GetInventoryItemDurability(slotID)

    local s = GetSlotFontString(slotID)
    if v1 and v2 then
        local percent = v1 / v2
        if DurabilityAndItemLevel["alwaysShowDur"] or percent < 1 then
            s:SetTextColor(GetThresholdColor(percent))
            s:SetText(math.floor(percent * 100) .. "%")
        else
            s:SetText("")
        end
    else
        s:SetText("")
    end
    s:Show()
end

function DAI.UpdateAllDur()
    for slotID, _ in pairs(slotIDs) do
        UpdateDur(slotID)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local timer

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")

        CharacterFrame:HookScript("OnShow", function()
            f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
            C_Timer.After(0.1, function()
                DAI.UpdateAllDur()
            end)
        end)

        CharacterFrame:HookScript("OnHide", function()
            f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
            f:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        end)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if timer then timer:Cancel() end
        if slotIDs[arg1] then -- has dur
            UpdateDur(arg1)
        end

    else -- UPDATE_INVENTORY_DURABILITY multi-fired
        if timer then timer:Cancel() end
        timer = C_Timer.NewTimer(0.1, function()
            DAI.UpdateAllDur()
        end)
    end
end)