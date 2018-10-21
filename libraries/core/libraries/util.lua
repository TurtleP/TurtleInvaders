local util = {}

function util.round(num, idp) --Not by me
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function string:split(delimiter) --Not by me
    local result = {}
    local from   = 1
    local delim_from, delim_to = string.find( self, delimiter, from   )
    while delim_from do
        table.insert( result, string.sub( self, from , delim_from-1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( self, delimiter, from   )
    end
    table.insert( result, string.sub( self, from   ) )
    return result
end

-- A function in Lua similar to PHP's print_r, from http://luanet.net/lua/function/print_r

function util.print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

return util