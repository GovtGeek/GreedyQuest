local addonName, GreedyQuest = ...
local L = GreedyQuest.L

GREEDYQUEST_OVERRIDE_ENTRY_8_8_2222 = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = "true", tileSize = 8, edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local spacing = 6

local function OverrideListInitializer(rowFrame, data)
	local itemName = data.ItemName
	local itemValue = data.ItemValue
	rowFrame.ItemName:SetText(itemName)
	rowFrame.ItemValue:SetText(GetMoneyString(itemValue))
	buttonDelete = rowFrame:GetChildren()
	buttonDelete:SetScript("OnClick", function(self)
		local row = self:GetParent()
		data = row:GetData()
		dataProvider = GreedyQuest.OptionsPanel.OverrideScrollList:GetDataProvider()
		dataProvider:RemoveIndex(dataProvider:FindIndex(row:GetData()))
		GQConfig.ValueOverrides[data.ItemName] = nil
		end)
end

-- The interface options panel
function GreedyQuest:CreateOptionsFrame()

	if not self.OptionsPanel then
		self.OptionsPanel = GreedyQuestOptionsFrame
		self.OptionsPanel.name = L.GreedyQuestTitle
		self.OptionsPanel:HookScript("OnShow", function() GreedyQuest:FillScrollWithCurrentOverrides() end)

		GreedyQuestOptionsFrameOverrideContainer:SetSize(SettingsPanel.Container.SettingsCanvas:GetWidth()-20, 300)

		local DataProvider = CreateDataProvider()
		local ScrollView = CreateScrollBoxListLinearView()

		ScrollUtil.InitScrollBoxListWithScrollBar(GreedyQuestOptionsFrameOverrideContainerOverrideScrollList, GreedyQuestOptionsFrameOverrideContainerOverrideScrollBar, ScrollView)
		ScrollView:SetElementInitializer("GreedyQuestOverrideEntryTemplate", OverrideListInitializer)
		ScrollView:SetDataProvider(DataProvider)


		self.OptionsPanel.OverrideScrollList = ScrollView

		DataProvider:SetSortComparator(function(a,b) return (a and a.ItemName or "") < ((b and b.ItemName) or "") end)

		GreedyQuest:FillScrollWithCurrentOverrides()

		-- Make sure this is in the if statement so we don't add it multiple times
		local category = Settings.RegisterCanvasLayoutCategory(self.OptionsPanel, addonName)
		Settings.RegisterAddOnCategory(category)
	end
	return self.OptionsPanel
end

function GreedyQuest:FillScrollWithCurrentOverrides()
	dataProvider = GreedyQuest.OptionsPanel.OverrideScrollList:GetDataProvider()
	dataProvider:Flush()
	for itemName, itemValue in pairs(GQConfig.ValueOverrides) do
		dataProvider:Insert({["ItemName"] = itemName, ["ItemValue"] = itemValue})
	end
end

GreedyQuestOptionsFrameEntryPanelAddItemButton:HookScript("OnClick", GreedyQuest.AddOverrideButtonClick)
