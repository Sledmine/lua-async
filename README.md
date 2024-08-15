# lua-async
A simple async/await module for Lua using Lanes and coroutines.

# Usage
```lua
local async = require "async".async
local dispatch = require "async".dispatch

local first = async(function (await)
    local time = os.time()
    local request = await(curl.get, "https://hub.dummyapis.com/delay?seconds=5", {allowRedirects = true, verify = false})
    if not request.ok then
        print("First request failed: ", request.error)
        return
    end
    print("First request took: ", string.format("%d seconds", os.time() - time))
end)

local second = async(function (await)
    local time = os.time()
    local request = await(curl.get, "https://hub.dummyapis.com/delay?seconds=2", {allowRedirects = true, verify = false})
    if not request.ok then
        print("Second request failed: ", request.error)
        return
    end
    print("Second request took: ", string.format("%d seconds", os.time() - time))
end)

first()
second()

--- Dispatch pending async calls
while dispatch() > 0 do
end
```
Previous code will output:
```
Second request took:  2 seconds
First request took:  5 seconds
```
Each async function will be executed in a separate thread, so they will run concurrently even if
they are called sequentially.

# How it works
Trough the use of Lanes async calls will be executed in separate threads, so they will run
concurrently and not block the main thread, with coroutines being used to wait for the results in
the same block of code to keep the code clean and easy to read, by also gimicking the async/await
syntax from other languages.

The `async` function creates a new coroutine that will run the given input function. The `await`
function is passed as the first argument to the function, and it is used to wait for the result of
async calls.

The `dispatch` function will run all pending async calls, and it will return the number of pending
async calls so this can be used to loop and resolve all async calls before the main thread finishes.
