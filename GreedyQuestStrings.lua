local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end})
local _, GreedyQuest = ...
GreedyQuest.L = L

L.GreedyQuestTitle = "Greedy Quest"

-- Option strings
L.ValueOverrideTitle = "Value Override"
L.AddOverrideTitle = "Add value override"
L.OverrideInputNameTitle = "Name of item"
L.OverrideInputValueTitle = "New value"
L.OverrideListTitle = "Current value overrides"
L.AddOverrideButtonText = "Add"