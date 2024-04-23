local addonName, GreedyQuest = ...
local L = GreedyQuest.L

GREEDYQUEST_OVERRIDE_ENTRY_8_8_2222 = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = "true", tileSize = 8, edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local spacing = 6

if not GQConfig.ValueOverrides then
	GQConfig.ValueOverrides = GreedyQuest.ValueOverrides
end


local function OverrideListInitializer(rowFrame, data)
	local itemName = data.ItemName
	local itemValue = data.ItemValue
	rowFrame.ItemName:SetText(itemName)
	--rowFrame.ItemValue:SetText(itemValue)
	rowFrame.ItemValue:SetText(GetMoneyString(itemValue))
	--print(rowFrame.ItemValue:GetText())
	buttonDelete = rowFrame:GetChildren()
	--print(dump(buttonDelete:GetName()))
	buttonDelete:SetScript("OnClick", function(self)
		local row = self:GetParent()
		data = row:GetData()
		--print("Deleting "..data.ItemName.."("..data.ItemValue..")")
		dataProvider = GreedyQuest.OptionsPanel.OverrideScrollList:GetDataProvider()
		dataProvider:RemoveIndex(dataProvider:FindIndex(row:GetData()))
		GQConfig.ValueOverrides[data.ItemName] = nil
		end)
end

-- The interface options panel
function GreedyQuest:CreateOptionsFrame()

	if not self.OptionsPanel then
		-- Create the container panel
		--local panel = CreateFrame("Frame", "GreedyQuestOptionsFrame", nil, BackdropTemplateMixin and "BackdropTemplate")
		self.OptionsPanel = GreedyQuestOptionsFrame
		self.OptionsPanel.name = L.GreedyQuestTitle
		self.OptionsPanel:HookScript("OnShow", function() GreedyQuest:FillScrollWithCurrentOverrides() end)

		GreedyQuestOptionsFrameOverrideContainer:SetSize(SettingsPanel.Container.SettingsCanvas:GetWidth()-20, 300)

		----[[--
		local DataProvider = CreateDataProvider()
		local ScrollView = CreateScrollBoxListLinearView()
		ScrollView:SetDataProvider(DataProvider)

		ScrollUtil.InitScrollBoxListWithScrollBar(GreedyQuestOptionsFrameOverrideContainerOverrideScrollList, GreedyQuestOptionsFrameOverrideContainerOverrideScrollBar, ScrollView)
		ScrollView:SetElementInitializer("GreedyQuestOverrideEntryTemplate", OverrideListInitializer)

		self.OptionsPanel.OverrideScrollList = ScrollView

		DataProvider:SetSortComparator(function(a,b) return (a and a.ItemName or "") < ((b and b.ItemName) or "") end)
		--]]--

		GreedyQuest:FillScrollWithCurrentOverrides()

		-- Make sure this is in the if statement so we don't add it multiple times
		InterfaceOptions_AddCategory(self.OptionsPanel)
	end

	--GreedyQuest:FillScrollWithCurrentOverrides()

	----[[-- Open to the option panel while testing
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
	--]]--
	return self.OptionsPanel
end

function GreedyQuest:CreateOptionsFrame_Original()
	if not self.OptionsPanel then
		local panel = CreateFrame("Frame", "GreedyQuestOptionsFrame", nil, BackdropTemplateMixin and "BackdropTemplate")
		self.OptionsPanel = panel

		-- Title of our options panel
		local GreedyQuestTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeftTop")
		GreedyQuestTitle:SetSize(290, 0)
		GreedyQuestTitle:SetJustifyV("MIDDLE")
		local _, fontHeight = GreedyQuestTitle:GetFont()
		GreedyQuestTitle:SetPoint("TOPLEFT", 0, 0)
		GreedyQuestTitle:SetText(L.GreedyQuestTitle)

		-- Name the override section
		local ValueOverrideTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		fontHeight = math.floor(fontHeight)
		ValueOverrideTitle:SetPoint("TOPLEFT", GreedyQuestTitle, "BOTTOMLEFT", 0, -12)
		ValueOverrideTitle:SetText(L.ValueOverrideTitle)

		-- "Add name of item" title
		local AddNameOfItemTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		AddNameOfItemTitle:SetPoint("TOPLEFT", ValueOverrideTitle, "BOTTOMLEFT", 0, -12)
		AddNameOfItemTitle:SetText(L.OverrideInputNameTitle)

		-- Box to add an item
		ebAddValueOverrideName = CreateFrame("EditBox", nil, self.OptionsPanel, "InputBoxTemplate")
		ebAddValueOverrideName:SetPoint("TOPLEFT", AddNameOfItemTitle, "BOTTOMLEFT", 6, -6)
		ebAddValueOverrideName:SetSize(300, 16)
		ebAddValueOverrideName:SetAutoFocus(false)
		self.OptionsPanel.ebAddValueOverrideName = ebAddValueOverrideName

		-- Box to add the value of an item
		ebAddValueOverrideValue = CreateFrame("EditBox", nil, self.OptionsPanel, "InputBoxTemplate")
		ebAddValueOverrideValue:SetPoint("TOPLEFT", ebAddValueOverrideName, "TOPRIGHT", 16, 0)
		ebAddValueOverrideValue:SetSize(100, 16)
		ebAddValueOverrideValue:SetAutoFocus(false)
		self.OptionsPanel.ebAddValueOverrideName = ebAddValueOverrideName

		-- "Set value" title
		local AddValueOfItemTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		AddValueOfItemTitle:SetPoint("BOTTOMLEFT", ebAddValueOverrideValue, "TOPLEFT", -6, 6)
		AddValueOfItemTitle:SetText(L.OverrideInputValueTitle)

		-- "Add" button
		bAddOverride = CreateFrame("Button", nil, self.OptionsPanel, "UIPanelButtonTemplate")
		bAddOverride:SetPoint("TOPLEFT", ebAddValueOverrideValue, "TOPRIGHT", 10, 3)
		bAddOverride:SetText(L.AddOverrideButtonText)
		bAddOverride:HookScript("OnClick", function(_, btn, down)
			-- Save the name/price combo (this way will override rather than forcing delete/add)
			local newValue = tonumber(ebAddValueOverrideValue:GetText()) or 0
			addItemName = ebAddValueOverrideName:GetText()
			print(tostring(ebAddValueOverrideName:GetText()).." - "..tostring(ebAddValueOverrideValue:GetText()).." ("..tostring(newValue)..")")
			GQConfig.ValueOverrides = GQConfig.ValueOverrides or GreedyQuest.ValueOverrides
			if newValue < 0 then -- Delete the override if the value is negative
				GQConfig.ValueOverrides[addItemName] = nil
			else
				GQConfig.ValueOverrides[addItemName] = newValue
			end
			print(dump(GQConfig.ValueOverrides))
		end)
		self.OptionsPanel.bAddOverride = bAddOverride

		-- Add list title
		local OverrideListTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		OverrideListTitle:SetPoint("TOPLEFT", ebAddValueOverrideName, "BOTTOMLEFT", -6, -12)
		OverrideListTitle:SetText(L.OverrideListTitle)

		-- Add the list of current items
		-- Create the scrolling parent frame and size it to fit inside the texture
		----[[--
		local ScrollBox = CreateFrame("Frame", nil, GreedyQuestOptionsFrame, "WowScrollBoxList")
		ScrollBox:SetPoint("LEFT")

		--print(SettingsPanel.Container.SettingsCanvas:GetWidth())
		--print(SettingsPanel.Container.SettingsCanvas:GetHeight())
		--print(OverrideListTitle:GetPoint())
		ScrollBox:SetSize(SettingsPanel.Container.SettingsCanvas:GetWidth()-20, 300)
		--ScrollBox:SetSize(300, 300)

		local ScrollBar = CreateFrame("EventFrame", nil, GreedyQuestOptionsFrame, "MinimalScrollBar")
		ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT")
		ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT")

		local DataProvider = CreateDataProvider()
		local ScrollView = CreateScrollBoxListLinearView()
		ScrollView:SetDataProvider(DataProvider)

		ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)
		ScrollView:SetElementInitializer("GreedyQuestOverrideEntryTemplate", Initializer)
		self.OptionsPanel.OverrideScrollList = ScrollView
		--]]--

		-- Add widgets to the scrolling child frame as desired
		--DataProvider:Insert({["ItemName"] = "Test first row", ["ItemValue"] = 3245234})
		GreedyQuest:FillScrollWithCurrentOverrides()
	end


	-- Add the panel to the interface options
	InterfaceOptions_AddCategory(self.OptionsPanel)

	----[[-- Open to the option panel while testing
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
	--]]--
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

function GreedyQuest:CreateOverrideRow(itemName, itemValue)
	-- How are we naming the rows?
	--rowFrame = CreateFrame("Frame", "OverrideRow_1", UIParent, "BackdropTemplate")
	rowFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	rowFrame:SetSize(500, 24)
	--rowFrame:SetPoint("CENTER", 0, 200)
	rowFrame:SetPoint("CENTER", 0, 200)
	rowFrame.backdropInfo = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = "true",
		tileSize = 8,
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	}
	rowFrame:ApplyBackdrop()

	rowFrame:HookScript("OnEnter", function(self)
		self.backdropInfo.bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"
		self:ApplyBackdrop()
		self:SetBackdropBorderColor(1, .84, 0)
	end)
	rowFrame:HookScript("OnLeave", function(self)
		self.backdropInfo.bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"
		self:ApplyBackdrop()
		self:SetBackdropBorderColor(1, 1, 1)
	end)

	----[[--
	deleteButton = CreateFrame("Button", nil, rowFrame, "OptionsButtonTemplate")
	deleteButton:SetSize(16, 16)
	deleteButton:SetPoint("RIGHT", rowFrame, "RIGHT", -2, 0)
	deleteButton:SetText("x")
	deleteButton:SetPushedTextOffset(0, 0)
	deleteButton:HookScript("OnEnter", function(self)
		self:GetParent().backdropInfo.bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"
		self:GetParent():ApplyBackdrop()
		self:GetParent():SetBackdropBorderColor(1, .84, 0)
	end)
	deleteButton:HookScript("OnLeave", function(self)
		self:GetParent().backdropInfo.bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"
		self:GetParent():ApplyBackdrop()
		self:GetParent():SetBackdropBorderColor(1, 1, 1)
	end)
	--]]--

	-- Item Name
	local itemNameText = rowFrame:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
	itemNameText:SetPoint("LEFT", rowFrame, "LEFT", 6, 0)
	itemNameText:SetText(itemName)

	-- Override value
	local overrideValueText = rowFrame:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
	overrideValueText:SetPoint("RIGHT", deleteButton, "RIGHT", -20, 0)
	overrideValueText:SetText(GetMoneyString(itemValue, true))
	return rowFrame
end
