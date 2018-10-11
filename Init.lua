local addonName, DAI = ...
local LSM = LibStub("LibSharedMedia-3.0")

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if arg1 == addonName then
        if type(DurabilityAndItemLevel) ~= "table" then DurabilityAndItemLevel = {} end
        if type(DurabilityAndItemLevel["alwaysShowDur"]) ~= "boolean" then DurabilityAndItemLevel["alwaysShowDur"] = false end
        if type(DurabilityAndItemLevel["showInBags"]) ~= "boolean" then DurabilityAndItemLevel["showInBags"] = false end
        if type(DurabilityAndItemLevel["iThreshold"]) ~= "number" then DurabilityAndItemLevel["iThreshold"] = 0 end
        if type(DurabilityAndItemLevel["durPoint"]) ~= "table" then DurabilityAndItemLevel["durPoint"] = {"BOTTOMRIGHT", 3, 0} end
        if type(DurabilityAndItemLevel["ilvlPoint"]) ~= "table" then DurabilityAndItemLevel["ilvlPoint"] = {"TOPLEFT", 0, 0} end
        if type(DurabilityAndItemLevel["bagPoint"]) ~= "table" then DurabilityAndItemLevel["bagPoint"] = {"BOTTOMRIGHT", 0, 0} end
        if type(DurabilityAndItemLevel["font"]) ~= "table" then DurabilityAndItemLevel["font"] = {LSM:GetDefault("font"), 14, "OUTLINE"} end
    end
end)

function DAI:GetFont()
    if LSM:IsValid("font", DurabilityAndItemLevel["font"][1]) then
        return {LSM:Fetch("font", DurabilityAndItemLevel["font"][1]), DurabilityAndItemLevel["font"][2], DurabilityAndItemLevel["font"][3]}
    else
        return {LSM:Fetch("font", LSM:GetDefault("font")), DurabilityAndItemLevel["font"][2], DurabilityAndItemLevel["font"][3]}
    end
end
