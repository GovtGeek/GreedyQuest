local addonName, GreedyQuest = ...
local L = GreedyQuest.L

GQConfig = {
	["options"] = {
		["_debug"] = true
	},
	["ValueOverrides"] = {
	   ["Champion's Writ"] = 1,
		["Champion's Purse"] = 10
	}
}

local function ItemModifiedClickHook(self, button)
	local linkedItemName, linkedItemValue
	local itemID = C_Container.GetContainerItemInfo(self:GetParent():GetID(), self:GetID()).itemID
	if C_Item and C_ItemInfo then
		linkedItemName = C_Item.GetItemInfo(itemID)
		linkedItemValue = select(11, C_Item.GetItemInfo(itemID))
	else
		linkedItemName = GetItemInfo(itemID)
		linkedItemValue = select(11, GetItemInfo(itemID))
	end
	GreedyQuestOptionsFrameEntryPanelItemNameEditBox:SetText(linkedItemName)
	GreedyQuestOptionsFrameEntryPanelItemValueEditBox:SetText(tostring(linkedItemValue))
end
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", ItemModifiedClickHook)

function GreedyQuest:AddOverride(itemName, itemValue)
   if not itemName then return end
   itemName = strtrim(itemName, " \t\r\n")
   if itemName ~= "" then
      dataProvider = GreedyQuest.OptionsPanel.OverrideScrollList:GetDataProvider()
      -- Check to see if we already have this item
      if GQConfig.ValueOverrides[itemName] then
         -- Get the current value, find in the dataprovider and update it
     		found = dataProvider:FindIndexByPredicate(function(data) return data.ItemName == itemName end)
         dataProvider:RemoveIndex(found)
      end

      if itemValue then
         itemValue = tonumber(itemValue) or 0 -- Force a number for itemValue
     		dataProvider:Insert({["ItemName"] = itemName, ["ItemValue"] = itemValue})
         GQConfig.ValueOverrides[itemName] = itemValue
      else
         GQConfig.ValueOverrides[itemName] = nil
      end
   else
      print("Can't add an empty item name.")
   end
end

function GreedyQuest:AddOverrideButtonClick()
   GreedyQuest:AddOverride(GreedyQuestOptionsFrameEntryPanelItemNameEditBox:GetText(), GreedyQuestOptionsFrameEntryPanelItemValueEditBox:GetText())
end

function GreedyQuest:GetItemInfoByName(itemName)
   _, itemLink = GetItemInfo(itemName)
   if itemLink == nil then
      --print("GetItemInfo: "..itemName.." not loaded")
      GreedyQuest.GreedyQuestFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
      C_Item.RequestLoadItemDataByID(itemLink)
      if GreedyQuest.Timer and GreedyQuest.Timer:IsCancelled() then
         -- Remove the timer
         GreedyQuest.Timer = nil
      end
      --print("Creating timer")
      GreedyQuest.itemTimer = C_Timer.NewTimer(.25, function()
         --print(GetItemInfo(itemLink))
         if GreedyQuest:GetItemInfo(itemLink) ~= nil then
            GreedyQuest.itemTimer:Cancel()
            GreedyQuest.GreedyQuestFrame:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
         end
      end,
      4) -- Limit the attempts to 4, just in case
   end

end

function GreedyQuest:GetItemInfo(itemLink)
   if not itemLink then return end
   local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
   itemName = GetItemInfo(itemLink)
   if itemName == nil then
      GreedyQuest.GreedyQuestFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
      C_Item.RequestLoadItemDataByID(itemLink)
      if GreedyQuest.Timer and GreedyQuest.Timer:IsCancelled() then
         -- Remove the timer
         GreedyQuest.Timer = nil
      end
      GreedyQuest.itemTimer = C_Timer.NewTimer(.25, function()
         --print("Waiting for item data to load for "..tostring(itemName))
         if GreedyQuest:GetItemInfo(itemLink) ~= nil then
            GreedyQuest.itemTimer:Cancel()
            GreedyQuest.GreedyQuestFrame:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
         end
      end,
      4) -- Limit the attempts to 4, just in case
   end
   return GetItemInfo(itemLink)
end

--[[-- THIS IS THE MAIN PART OF THIS ADDON --]]--
local function SelectMostExpensive()
   local bestSellPrice = 0
   local mostValuableIndex = 0
   for i = 1, GetNumQuestChoices() do
      itemName = GetQuestItemInfo("choice", i)
      itemLink = GetQuestItemLink("choice", i)
      if not itemLink then
         print("GetItemInfo: "..itemName.." not loaded. Can't select most valuable option.")
         return false
      end
      sellPrice = select(11, GreedyQuest:GetItemInfo(itemLink))

      -- Here is where we override the value of an item like "Champion's Purse" that has 10 gold in it
      sellPrice = GQConfig.ValueOverrides[itemName] or sellPrice
      if sellPrice > bestSellPrice then
         mostValuableIndex = i
         bestSellPrice = sellPrice
      end
   end
   GreedyQuest:HighlightReward(mostValuableIndex)
   return mostValuableIndex
end

function GreedyQuest:HighlightReward(index)
	if index <= 0 then return end
   QuestInfoFrame.itemChoice = index;
   QuestInfoItemHighlight:ClearAllPoints();
   QuestInfoItemHighlight:SetPoint("TOPLEFT",_G["QuestInfoRewardsFrameQuestInfoItem"..index],"TOPLEFT",-8,7);
   QuestInfoItemHighlight:Show();
end

QuestFrameRewardPanel:HookScript("OnShow", SelectMostExpensive)
--[[-- THIS ENDS THE MAIN PART OF THE ADDON --]]--


local f = CreateFrame("Frame", "GreedyQuestFrame", UIParent)
--f:RegisterEvent("ITEM_DATA_LOAD_RESULT")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function(this, event, ...)
   if event == "ITEM_DATA_LOAD_RESULT" then
      itemID = ...
   elseif event == "PLAYER_ENTERING_WORLD" then
      GreedyQuest:CreateOptionsFrame()
   end
end);
GreedyQuest.GreedyQuestFrame = f

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end