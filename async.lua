local lanes = require "lanes"

local async = {}

local asyncLibs = "*"
THREAD_LANES = {}

---Perform an async function
---@generic T, U
---@param inputFunction fun(await: fun(callback: fun(...:U): (T?), ...:U): T)
function async.async(inputFunction)
    local co
    local await = function(asyncCallback, ...)
        table.insert(THREAD_LANES, {
            thread = lanes.gen(asyncLibs, asyncCallback)(...),
            callback = function(ret)
                coroutine.resume(co, ret)
            end
        })
        return coroutine.yield()
    end
    ---@return boolean success Async function has finished successfully
    return function()
        co = coroutine.create(inputFunction)
        local ok = coroutine.resume(co, await)
        return ok
    end
end

---Configure the async module to use the specified libraries
---@param libs any
function async.configure(libs)
    asyncLibs = libs
end

---Dispatches the async functions and returns the number of async functions still running
function async.dispatch()
    for index, lane in ipairs(THREAD_LANES) do
        if lane.thread.status == "done" then
            table.remove(THREAD_LANES, index)
            lane.callback(lane.thread[1])
        elseif lane.thread.status == "error" then
            table.remove(THREAD_LANES, index)
            error(lane.thread[1])
        end
    end
    return #THREAD_LANES
end

return async