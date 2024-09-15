local util = require("common.util")
Coroutines = {}
local _toinform = {}

function Coroutines.create(func)
	local co = coroutine.create(func)
	table.insert(Coroutines, co)
	return co
end

function Coroutines.inform(co, ...)
	_toinform[co] = ...
end

function Coroutines.update(informs)
	informs = informs or _toinform
	for i = 0, #Coroutines, 1 do
		local co = Coroutines[i]
		local data = informs[co]
		if coroutine.status(co) ~= "dead" then
			coroutine.resume(co, data)
		else
			table.remove(Coroutines, i)
			i = i - 1
		end
		_toinform[co] = nil
	end
end

function Coroutines.animate(fn, count, framedelay, startdelay)
	framedelay = framedelay or 1
	startdelay = startdelay or 0
	local _func = function()
		for _ = 1, startdelay, 1 do
			coroutine.yield()
		end
		for i = 1, count, 1 do
			local progress = i / count
			fn(i, progress)
			for _ = 1, framedelay, 1 do
				coroutine.yield()
			end
		end
	end
	Coroutines.create(_func)
	return _func
end

function SetTimeout(fn, frames)
	Coroutines.create(function()
		for _ in util.irange(frames) do
			coroutine.yield()
		end
		fn()
	end)
end
