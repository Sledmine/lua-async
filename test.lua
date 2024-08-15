require "luna"
local async = require "async".async
local dispatch = require "async".dispatch

local first = async(function (await)
    local time = os.time()
    -- DO NOT DO, Always wrap async execution in a function
    --await(os.execute, "sleep 10")
    await(function () os.execute("sleep 10") end)
    print("First request took: ", string.format("%d seconds", os.time() - time))
end)

local second = async(function (await)
    local time = os.time()
    local request = await(curl.get, "https://hub.dummyapis.com/delay?seconds=1", {allowRedirects = true, verify = false})
    if not request.ok then
        print("Second request failed: ", request.error)
        return
    end
    print("Second request took: ", string.format("%d seconds", os.time() - time))
end)

first()
second()

while dispatch() > 0 do
end
