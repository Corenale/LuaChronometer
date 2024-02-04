--[[
       _                                          _
   ___| |__  _ __ ___  _ __   ___  _ __ ___   ___| |_ ___ _ __
  / __| '_ \| '__/ _ \| '_ \ / _ \| '_ ` _ \ / _ \ __/ _ \ '__|
 | (__| | | | | | (_) | | | | (_) | | | | | |  __/ ||  __/ |
  \___|_| |_|_|  \___/|_| |_|\___/|_| |_| |_|\___|\__\___|_|

 *wow this is ascii text art*

	chronometer library for getting time and measuring time intervals
	Lib author: Corenale
	For: Everyone | kekwait.su

	Credits:
		scopeset - for pushing me to learn about metatables :)
		chatgpt - for explaining how metatables work, xd
		kirov - for sitting in the voice channel and listening to my whining about metatables (yes, about them again)
		Everyone - Thank you for being you, I love you all <3

]]
local os = jit.os
assert(os == "Windows" or os == "Linux", "This library uses WinAPI or Linux functions.") -- I will probably add support for OSX, but does it make sense?
local ffi = require "ffi"
local chronometer, stopWatch = {}, {__index = {}, __metatable = {}}

ffi.cdef([[
	void GetSystemTimePreciseAsFileTime(uint64_t*);
	void GetSystemTimeAsFileTime(uint64_t*);
	void QueryPerformanceFrequency(uint64_t*);
	void QueryPerformanceCounter(uint64_t*);
	void GetProcessTimes(uint32_t, uint64_t*, uint64_t*, uint64_t*, uint64_t*);
	int32_t GetCurrentProcess(void);
	
    int clock_gettime(uint32_t, uint32_t*);
    uint64_t clock(void);
]])

if os == "Windows" then
    local GetSystemTimePreciseAsFileTime = ffi.C.GetSystemTimePreciseAsFileTime
    local GetSystemTimeAsFileTime = ffi.C.GetSystemTimeAsFileTime
    local QueryPerformanceCounter = ffi.C.QueryPerformanceCounter
    local hProcess = ffi.C.GetCurrentProcess()
    local tempValue = ffi.new("uint64_t[1]")
    ffi.C.QueryPerformanceFrequency(tempValue); local frequency = 1/tonumber(tempValue[0])
    local creationTime = ffi.new("uint64_t[1]"); ffi.C.GetProcessTimes(hProcess, creationTime, tempValue, tempValue, tempValue)
        
    local function getSystemCounter()
    	QueryPerformanceCounter(tempValue)
    	tempValue[0] = tempValue[0] * (frequency * 1e7)
    end
    
    
    function chronometer.stopwatch(bool)
	
    	local getclock = bool and getSystemCounter or GetSystemTimeAsFileTime
    	getclock(tempValue)
    	
    	return setmetatable({
    	
    		getclock = getclock,
    		startValue = tempValue[0],
    		pausedValue = 0,
    		isPaused = false,
    	
    	}, stopWatch)
    	
    end
    
    function stopWatch.__index:elapsed()
    	
    	if self.isPaused then return tonumber(self.pausedValue)/1e4 end
    	self.getclock(tempValue)
    	return tonumber(tempValue[0] - self.startValue)/1e4
    	
    end
    
    function stopWatch.__index:reset()
    	
    	self.getclock(tempValue)
    	self.startValue = tempValue[0]
    	self.pausedValue = 0
    	return true
    	
    end
    
    function stopWatch.__index:pause()
    	
    	if not self.isPaused then 
    		self.getclock(tempValue)
    		self.pausedValue = tempValue[0] - self.startValue
    		self.isPaused = true
    		return true
    	else
    		return false
    	end
    	
    end
    
    function stopWatch.__index:resume()
    	
    	if self.isPaused then 
    		self.getclock(tempValue)
    		self.startValue = tempValue[0] - self.pausedValue
    		self.pausedValue = 0
    		self.isPaused = false
    		return true
    	else
    		return false
    	end
    	
    end
    
    function chronometer.gettime(bool)
    
    	if bool then
    		GetSystemTimePreciseAsFileTime(tempValue)
    		return tonumber(tempValue[0] - 0x19DB1DED53E8000) / 1e7
    	else
    		GetSystemTimeAsFileTime(tempValue)
    		return tonumber(tempValue[0] - 0x19DB1DED53E8000) / 1e7
    	end
    
    end
    
    function chronometer.getsysclock()
    
    	QueryPerformanceCounter(tempValue)
    	return tonumber(tempValue[0]) * frequency
    
    end
    
    function chronometer.getclock(bool)
    
    	if bool then
    		GetSystemTimePreciseAsFileTime(tempValue)
    		return tonumber(tempValue[0] - creationTime[0]) / 1e7
    	else
    		GetSystemTimeAsFileTime(tempValue)
    		return tonumber(tempValue[0] - creationTime[0]) / 1e7
    	end
    
    end
    
    function chronometer.getrawtime(bool)
    
    	if bool then
    		GetSystemTimePreciseAsFileTime(tempValue)
    		return tempValue[0] - 0x19DB1DED53E8000
    	else
    		GetSystemTimeAsFileTime(tempValue)
    		return tempValue[0] - 0x19DB1DED53E8000
    	end
    
    end
    
    function chronometer.getrawsysclock()
    
    	QueryPerformanceCounter(tempValue)
    	return tempValue[0] * (frequency * 1e7)
    
    end
    
    function chronometer.getrawclock(bool)
    
    	if bool then
    		GetSystemTimePreciseAsFileTime(tempValue)
    		return tempValue[0] - creationTime[0]
    	else
    		GetSystemTimeAsFileTime(tempValue)
    		return tempValue[0] - creationTime[0]
    	end
    
    end

elseif os == "Linux" then
    local getclock = ffi.C.clock_gettime
    local tempValue = ffi.new("uint32_t[2]")
    local function structToULL()
        return (tempValue[0]+0ull)*1e9+tempValue[1]
    end
    
    function chronometer.stopwatch()
	
    	getclock(1, tempValue)
    	
    	return setmetatable({
    	
    	    getclock = getclock;
    		startValue = structToULL(),
    		pausedValue = 0,
    		isPaused = false,
    	
    	}, stopWatch)
    	
    end
    
    function stopWatch.__index:elapsed()
    	
    	if self.isPaused then return tonumber(self.pausedValue)/1e6 end
    	self.getclock(1, tempValue)
    	return tonumber(structToULL() - self.startValue)/1e6
    	
    end
    
    function stopWatch.__index:reset()
    	
    	self.getclock(1, tempValue)
    	self.startValue = structToULL()
    	self.pausedValue = 0
    	return true
    	
    end
    
    function stopWatch.__index:pause()
    	
    	if not self.isPaused then 
    		self.getclock(1, tempValue)
    		self.pausedValue = structToULL() - self.startValue
    		self.isPaused = true
    		return true
    	else
    		return false
    	end
    	
    end
    
    function stopWatch.__index:resume()
    	
    	if self.isPaused then 
    		self.getclock(1, tempValue)
    		self.startValue = structToULL() - self.pausedValue
    		self.pausedValue = 0
    		self.isPaused = false
    		return true
    	else
    		return false
    	end
    	
    end
    
    function chronometer.gettime()
        
    	getclock(0, tempValue)
    	return tonumber(structToULL()) / 1e9
        
    end
    
    function chronometer.getsysclock()
    
    	getclock(1, tempValue)
    	return tonumber(structToULL()) / 1e9
    
    end
    
    function chronometer.getclock()

        getclock(2, tempValue)
    	return tonumber(structToULL()) / 1e9
    	    
    end
    
    function chronometer.getrawtime()
    
    	getclock(0, tempValue)
    	return structToULL()
    
    end
    
    function chronometer.getrawsysclock()
    
    	getclock(1, tempValue)
    	return structToULL()
    
    end
    
    function chronometer.getrawclock()
    
    	getclock(2, tempValue)
    	return structToULL()
    
    end

    
end


return chronometer