-- Originally by Dr. Matt
-- https://github.com/MattJeanes/ChatPrint
-- Rewritten at https://github.com/CheezusChrust/ChatPrint

E2Lib.RegisterExtension("chatprint", true)

local adminOnly = CreateConVar("sbox_E2_ChatPrintAdminOnly", "1", FCVAR_ARCHIVE, "If set to 1, only admins can use chatPrint", 0, 1)
local burstMax = CreateConVar("sbox_E2_ChatPrintBurstMax", "8", FCVAR_ARCHIVE, "The maximum number of chatPrints that can be sent in a burst", 1)
local burstRechargeRate = CreateConVar("sbox_E2_ChatPrintBurstRate", "1", FCVAR_ARCHIVE, "The rate at which the message limit recharges up to BurstMax, in messages per second", 0.1)
local maxCharacters = CreateConVar("sbox_E2_ChatPrintMaxCharacters", "255", FCVAR_ARCHIVE, "The maximum number of characters that can be sent in a single chatPrint", 1)

util.AddNetworkString("Expression2_ChatPrint")

local function canPrint(ply)
	if adminOnly:GetBool() and not ply:IsAdmin() then return false end

	local burstMaxValue = burstMax:GetInt()
	local burstRateValue = burstRechargeRate:GetFloat()
	local lastPrintTime = ply.e2ChatPrintsLast or 0
	local time = CurTime()
	local recharge = math.floor(burstRateValue * (CurTime() - lastPrintTime))
	ply.e2ChatPrintsLeft = math.min((ply.e2ChatPrintsLeft or burstMaxValue) + recharge, burstMaxValue)

	if ply.e2ChatPrintsLeft <= 0 then return false end

	ply.e2ChatPrintsLeft = ply.e2ChatPrintsLeft - 1
	ply.e2ChatPrintsLast = time

	return true
end

local function chatPrint(sender, target, tbl, ...)
	if not canPrint(sender) then return end

	local args = {...}
	args = args[1]

	if tbl then args = tbl end

	if #args == 0 then return end

	-- Trim messages longer than the character limit
	local maxCharactersValue = maxCharacters:GetInt()
	local newArgs = {}
	local charCount = 0
	for k, v in ipairs(args) do
		if type(v) == "string" then
			local remaining = maxCharactersValue - charCount
			if charCount + #v <= maxCharactersValue then
				newArgs[#newArgs + 1] = v
				charCount = charCount + #v
			else
				if remaining > 0 then
					newArgs[#newArgs + 1] = string.sub(v, 1, remaining)
				end

				break
			end
		else
			if newArgs[#newArgs] and type(newArgs[#newArgs]) == "Vector" then -- No spamming vectors
				newArgs[#newArgs] = v
			else
				if k == #args then break end -- No point in keeping a vector without anything following
				newArgs[#newArgs + 1] = v
			end
		end
	end

	-- Console logging
	if not game.SinglePlayer() then
		local log = ""

		for _, v in ipairs(args) do
			if type(v) == "string" then
				log = log .. v
			end
		end

		if IsValid(target) and target:IsPlayer() then
			print("[ChatPrint] " .. sender:Nick() .. " to " .. target:Nick() .. ": " .. log)
		else
			print("[ChatPrint] " .. sender:Nick() .. ": " .. log)
		end
	end

	net.Start("Expression2_ChatPrint")

	net.WriteUInt(#newArgs, 8)
	for _, v in ipairs(newArgs) do
		if type(v) == "string" then
			net.WriteBool(false) -- Type identifier, false for strings
			net.WriteString(v)
		elseif type(v) == "Vector" then
			net.WriteBool(true)
			net.WriteUInt(v.x, 8)
			net.WriteUInt(v.y, 8)
			net.WriteUInt(v.z, 8)
		end
	end

	if IsValid(target) and target:IsPlayer() then
		net.Send(target)
	else
		net.Broadcast()
	end
end

__e2setcost(40)

e2function void chatPrint(...args)
	chatPrint(self.player, nil, nil, args)
end

e2function void chatPrint(entity target, ...args)
	chatPrint(self.player, target, nil, args)
end

e2function void chatPrint(array r)
	chatPrint(self.player, nil, r)
end

e2function void chatPrint(entity target, array r)
	chatPrint(self.player, target, r)
end