--SERVER OR CLIENT FUNCS WE NEED

shared = {}

function shared:fixChat(tofixtext)
	local text = {""}
	local i1 = 1
	local font = font4
	
	for i = 1, string.len(tofixtext) do
		local v = string.sub(tofixtext, i, i)
		
		if font:getWidth( string.sub(tofixtext, i1, i) ) >= 406*scale then
			i1 = i
			table.insert(text, v)
		else
			text[#text] = text[#text] .. v
		end
	end

	return text
end

function shared:timeEvent(delay, func)
	util.simpleTimer(delay, func)
end

function shared:getIPType(ip)
    -- must pass in a string value
    if ip == nil or type(ip) ~= "string" then
        return 0
    end

    -- check for format 1.11.111.111 for ipv4
    local chunks = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
    if (#chunks == 4) then
        for _,v in pairs(chunks) do
            if (tonumber(v) < 0 or tonumber(v) > 255) then
                return 0
            end
        end
        return "IPv4"
    else
        return "Invalid"
    end

    -- check for ipv6 format, should be 8 'chunks' of numbers/letters
    local _, chunks = ip:gsub("[%a%d]+%:?", "")
    if chunks == 8 then
        return "IPv6"
    end

    -- if we get here, assume we've been given a random string
    return "String"
end