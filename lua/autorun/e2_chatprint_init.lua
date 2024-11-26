if SERVER then
	AddCSLuaFile()
else
	net.Receive("Expression2_ChatPrint", function()
		local args = {}

		for _ = 1, net.ReadUInt(8) do
			if net.ReadBool() then
				local col = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
				print(col)
				table.insert(args, col)
			else
				table.insert(args, net.ReadString())
			end
		end

		chat.AddText(unpack(args))
	end)
end