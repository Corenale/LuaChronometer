# Chronometer
Chronometer is a Lua library for precise time measurement and timestamps on Windows or Linux.

Features:
* Stopwatch for timing intervals
* Timestamps and raw timestamps for unix time, system start, process start
* 100ns precision for Windows and 1ns for Linux

Usage:
```lua

local chronometer = require("chronometer")

-- Stopwatch instance
local sw = chronometer.stopwatch(true) 
sw:elapsed() -- elapsed time in milliseconds
sw:pause()
sw:resume()
sw:reset()

-- Current unix time 
chronometer.gettime(true) -- current unix time in seconds

-- Process current time
chronometer.getclock(true) -- current process time in seconds

- System current system time
chronometer.getsysclock(true) -- current system time in seconds

-- Raw timestamps
chronometer.getrawclock() -- raw process time value
chronometer.getrawsysclock() -- raw system time value
chronometer.getrawtime(true) -- raw unix time value
```
The library provides both high resolution and normal precision variants for stopwatches, current time, and process time (Windows only).

Raw timestamp functions return the underlying timestamp values, useful for precision timing.

The library uses the Windows or Linux API and LuaJIT's FFI for high performance timing.
