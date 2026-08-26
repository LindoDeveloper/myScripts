--!strict
local UIS = game:GetService("UserInputService")

local CancelModule = {}

function CancelModule.Listen(character: Model, myInventory: any, onCancel: ((() -> ()) -> ()) -> ())
	if not myInventory then return end

	local connections: {RBXScriptConnection} = {}

	table.insert(connections, UIS.InputBegan:Connect(function(input: InputObject, gp: boolean)
		if gp then return end
		local isCancelInput: boolean = input.KeyCode == Enum.KeyCode.Space 
			or input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch

		if isCancelInput then
			myInventory:ClearActive(character)
		end
	end))

	onCancel(function()
		for _, conn: RBXScriptConnection in ipairs(connections) do
			if conn then conn:Disconnect() end
		end
	end)
end

return CancelModule
