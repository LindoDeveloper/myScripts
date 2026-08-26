local EmoteRegistry = {}
local Registry: { [number]: any } = {}

local EmotesFolder = script.Parent:WaitForChild("Emotes")

for _, child in EmotesFolder:GetChildren() do
	if child:IsA("ModuleScript") then
		local emoteId = tonumber(child.Name)
		if emoteId then
			Registry[emoteId] = require(child)
		end
	end
end

function EmoteRegistry.GetRegistry()
	return Registry
end

return EmoteRegistry
