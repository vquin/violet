local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
    writefile(file, '')
end

local function downloadFile(path, func)
    if not isfile(path) then
        local suc,res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/vquin/'..readfile('violet/profiles/commit.txt')..'/'..select(1, path:gsub('violet/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        if path:find('.lua') then
            res = '-fuk\n'..res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _,file in listfiles(path) do
        if file:find('loader') then continue end
        if isfile(file) and select(1, readfile(file):find('-fuk')) == 1 then
            delfile(file)
        end
    end
end

for _,folder in {'violet', 'violet/games', 'violet/profiles', 'violet/assets', 'violet/libraries', 'violet/interface'} do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

if not shared.dev then
    local _,subbed = pcall(function()
        return game:HttpGet('https://github.com/vquin/violet')
    end)
    local commit = subbed:find('currentOid')
    commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
    if commit == "main" or (isfile('violet/profiles/commit.txt') and readfile('violet/profiles/commit.txt') or '') ~= commit then
        wipeFolder('violet')
        wipeFolder('violet/games')
        wipeFolder('violet/interface')
        wipeFolder('violet/libraries')
    end
    writefile('violet/profiles/commit.txt', commit)
end

return loadstring(downloadFile('violet/main.lua'), 'main')()