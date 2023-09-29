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
		poe.com - for free access to chatgpt* | Sage - for explaining how metatables work, xd
		kirov - for sitting in the voice channel and listening to my whining about metatables (yes, about them again)
		Everyone - Thank you for being you, I love you all <3

]]
assert(jit.os == "Windows", "This library uses WinAPI functions.") -- I will probably add support for Linux and OSX, but does it make sense?
local ffi = require "ffi"
local chronometer, stopWatch = {}, {__index = {}, __metatable = {}}

ffi.cdef([[
	void GetSystemTimePreciseAsFileTime(uint64_t*);
	void GetSystemTimeAsFileTime(uint64_t*);
	void QueryPerformanceFrequency(uint64_t*);
	void QueryPerformanceCounter(uint64_t*);
	void GetProcessTimes(uint32_t, uint64_t*, uint64_t*, uint64_t*, uint64_t*);
	int32_t GetCurrentProcess(void);
]])

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

return chronometer