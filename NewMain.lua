repeat task.wait() until game:IsLoaded()
if shared.violet then shared.violet:Disconnect() end

local violet
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and violet then
        violet:notify('Violet', 'Failed to load: '..err, 30, 'alert')
    end
    return res
end

local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
    local suc,res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

local cloneref = cloneref or function(...)
    return ...
end

local players = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
    if not isfile(path) then
        local suc,res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/vquin/violet/'..readfile('violet/profiles/commit.txt')..'/'..select(1, path:gsub('violet/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        if path:find('.lua') then
            res = "-fuk\n"..res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function finishLoading()
    violet.Init = nil
    violet:Load()
    task.spawn(function()
        repeat
            violet:Save()
            task.wait(10)
        until not violet.Loaded
    end)

    local teleportedServers
    violet:Clean(players.LocalPlayer.OnTeleport:Connect(function()
        if (not teleportedServers) and (not violet.VioletIndependent) then
            teleportedServers = true
            local teleportScript = [[
                shared.violetreload = true
                if shared.dev then
                    loadstring(readfile('violet/loader.lua'), 'loader')()
                else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/vquin/violet/'..readfile('violet/profiles/commit.txt')..'/loader.lua', true), 'loader')()
                end
            ]]
            if shared.dev then
                teleportScript = 'shared.dev = true\n'..teleportScript
            end
            if shared.violetCustomProfile then
                teleportScript = 'shared.violetCustomProfile = "'..shared.violetCustomProfile..'"\n'..teleportScript
            end
            violet:Save()
            queue_on_teleport(teleportScript)
        end
    end))
end

if not isfile('violet/profiles/gui.txt') then
    writefile('violet/profiles/gui.txt', 'new')
end

local gui = readfile('violet/profiles/gui.txt')

if not isfolder('violet/assets/'..gui) then
    makefolder('violet/assets/'..gui)
end

violet = loadstring(downloadFile('violet/guis/'..gui..'.lua'), 'gui')()
shared.violet = violet

if not shared.VioletIndependent then
    loadstring(downloadFile('violet/games/universal.lua'), 'universal')()
    if isfile('violet/games/'..game.PlaceId..'.lua') then
        loadstring(readfile('violet/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
    else
        if not shared.dev then
            local suc, res = pcall(function()
                return game:HttpGet('https://raw.githubusercontent.com/vquin/violet/'..readfile('violet/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
            end)
            if suc and res ~= '404: Not Found' then
                loadstring(downloadFile('violet/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
            end
        end
        finishLoading()
    end
else
    violet.Init = finishLoading
    return violet
end