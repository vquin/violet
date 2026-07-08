local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/vquin/violet/main/'..select(1, path:gsub('violet/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

print('[violet] main reached, bouncing to trail')
return loadstring(downloadFile('violet/trail.lua'), 'trail')()
