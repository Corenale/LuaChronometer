# Chronometer
Chronometer is a Lua library for precise time measurement and timestamps on Windows.

Features:
* Stopwatch for timing intervals up to microseconds precision
* Current time in seconds or microseconds precision
* Elapsed process time in seconds or microseconds
* Raw timestamps for time, system performance counter, process start

Usage:
```lua

local chronometer = require("chronometer")

-- Stopwatch with microsecond precision
local sw = chronometer.stopwatch(true) 
sw:elapsed() -- elapsed time in seconds
sw:pause()
sw:resume()

-- Current time 
chronometer.gettime(true) -- current time in seconds (microseconds precision)

-- Process current time
chronometer.getclock(true) -- current process time in seconds (microseconds precision)

-- Raw timestamps
chronometer.getrawsysclock() -- raw system performance counter value
chronometer.getrawtime(true) -- raw system time value (microseconds precision)
```
The library provides both high resolution and normal precision variants for stopwatches, current time, and process time.

Raw timestamp functions return the underlying Windows timestamp values, useful for precision timing.

The library uses the Win32 API and LuaJIT's FFI for high performance timing.
