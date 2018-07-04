--[[
		             _                                  
	              (`  ).                   _           
	             (     ).              .:(`  )`.       
	)           _(       '`.          :(   .    )      
	        .=(`(      .   )     .--  `.  (    ) )      
	       ((    (..__.:'-'   .+(   )   ` _`  ) )                 
	`.     `(       ) )       (   .  )     (   )  ._   
	  )      ` __.:'   )     (   (   ))     `-'.-(`  ) 
	)  )  ( )       --'       `- __.'         :(      )) 
	.-'  (_.'          .')                    `(    )  ))
	                  (_  )                     ` __.:'          
	                                        
	--..,___.--,--'`,---..-.--+--.,,-,,..._.--..-._.-a:f--.

	HorizönNX
	Switch <-> PC Löve Bridge
--]]

Horizon =
{
	_VERSION = "1.0.0",
	RUNNING = (love.system.getOS() ~= "HorizonNX")
}

--SYSTEM CHECK
if not Horizon.RUNNING then
	return
end

Horizon.RUNNING = true

local path = ...

Enum = require(path .. ".enum")
CONFIG = require(path .. ".config")

require(path .. ".input")
require(path .. ".system")

love.window.setMode(1280, 720, {vsync = true})
love.window.setTitle(love.filesystem.getIdentity() .. " | HorizonNX " .. Horizon._VERSION)