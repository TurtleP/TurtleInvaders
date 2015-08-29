HBD = {}

HBD.name = "HugoBDesigner's Screenshot and Video Recording Library™"
HBD.purpose = "Make screenshots and video recordings!"
HBD.version = 1.0
HBD.gametitle = love.window.getTitle()

HBD.recordingdata = {}
HBD.isRecording = false
HBD.timerecorded = 0 --Just so users can see how long they've been recording
HBD.framesrecorded = 0 --Just so users can see how long they've been recording
HBD.recordingtimer = 0
HBD.recordingmaxtimer = .25
HBD.resetTitle = false 

--[[LICENCE
	Creative Commons 3.0 by-sa
	Use it cause it's cool, but credit me cause it was hard
	Not REALLY hard, but it took some time...
]]

function HBD:keypressed(key)
	if key == "f3" then
		-- PART 1: Get the screenshot itself and make it as an image
		
		local number = 1
		local lnumber = "0001"

		if not love.filesystem.exists("screenshots") then --make one
			love.filesystem.createDirectory("screenshots")
		end

		local screenshot = love.graphics.newScreenshot()
		while love.filesystem.exists("screenshots/screenshot_" .. lnumber .. ".png") do
			number = number + 1
			if number >= 1 and number < 10 then
				lnumber = "000" .. tostring(number)
			elseif number >= 10 and number < 100 then
				lnumber = "00" .. tostring(number)
			elseif number >= 100 and number < 1000 then
				lnumber = "0" .. tostring(number)
			else
				lnumber = tostring(number)
			end
		end
		screenshot:encode("screenshots/screenshot_" .. lnumber .. ".png")
	end

	if key == "f9" then
		if HBD.isRecording then
			HBD:stopRecording()
		else
			HBD.gametitle = love.window.getTitle( )
			HBD:startRecording()
		end
	end
	
	if key == "f11" then
		if HBD.isRecording then
			HBD.recordingdata = {}
			love.window.setTitle(HBD.gametitle)
			HBD.framesrecorded = 0
			HBD.timerecorded = 0
			HBD.isRecording = false
		end
	end
end

function HBD:stopRecording()
	HBD.isRecording = false
	HBD.recordingtimer = 0
	if not love.filesystem.exists( "records" ) then
		love.filesystem.createDirectory( "records" )
	end
	local a = "0001"
	local n = 1
	if love.filesystem.exists("records/record_" .. a) then
		while love.filesystem.exists("records/record_" .. a) do
			local zeros = ""
			n = n + 1
			if n >= 1 and n < 10 then
				zeros = "000"
			elseif n >= 10 and n < 100 then
				zeros = "00"
			elseif n >= 100 and n < 1000 then
				zeros = "0"
			end
			a = zeros .. tostring(n)
		end
	end
	n = 0
	love.filesystem.createDirectory("records/record_" .. a)
	
	------------------
	
	for i = 1, #HBD.recordingdata do
		love.window.setTitle(HBD.gametitle .. " [SAVING RECORDING] - " .. tostring(i) .. "/" .. tostring(#HBD.recordingdata))
		local b = "0001"
		if love.filesystem.exists("records/record_" .. a .. "/" .. b .. ".png") then
			while love.filesystem.exists("records/record_" .. a .. "/" .. b .. ".png") do
				local zeros = ""
				n = n + 1
				if n >= 1 and n < 10 then
					zeros = "000"
				elseif n >= 10 and n < 100 then
					zeros = "00"
				elseif n >= 100 and n < 1000 then
					zeros = "0"
				end
				b = zeros .. tostring(n)
			end
		end
		
		HBD.recordingdata[i]:encode("records/record_" .. a .. "/" .. b .. ".png")
	end
	
	HBD.recordingdata = {}
	
	HBD.framesrecorded = 0
	HBD.timerecorded = 0
	
	love.window.setTitle(HBD.gametitle)
end

function HBD:startRecording()
	HBD.recordingdata = {}
	HBD.isRecording = true
end

function HBD:updateRecording(dt)
	if HBD.isRecording then
		HBD.resetTitle = false 
		if HBD.recordingtimer >= HBD.recordingmaxtimer then
			local a = love.graphics.newScreenshot()
			HBD.recordingdata[#HBD.recordingdata+1] = a
			HBD.framesrecorded = HBD.framesrecorded + dt
			HBD.timerecorded = round(HBD.framesrecorded)
			love.window.setTitle(HBD.gametitle .. " [RECORDING] - " .. tostring(HBD.timerecorded) .. " seconds - " .. tostring(#HBD.recordingdata) .. "frames")
			HBD.recordingtimer = 0
		else
			HBD.recordingtimer = HBD.recordingtimer + dt
		end
	else
		if not HBD.resetTitle then
			love.window.setTitle(HBD.gametitle)
			HBD.resetTitle = true
		end
	end
end