local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = game.Workspace.CurrentCamera -- Hmm Workspace??

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SPTS : Whatever V3.14159", "DarkTheme")

local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Utilidades")

Section:NewKeybind("Toggle UI", "KeybindInfo", Enum.KeyCode.Y, function()
    Library:ToggleUI()
end)

Section:NewButton("Infinite Yield", "antiafk, spawn 30, diedtp, waypoints, autoclick, autokeypress, esp", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

Section:NewToggle("Auto Respawn", "Respawn automático ao morrer", function(state)
    getgenv().ar = state
end)

-- game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer({[1] = "EquipWeight_Request", [2] = 1}) NÃO APAGAR !!!

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

local function setupCharacter(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        local root = getRoot(Players.LocalPlayer.Character)
        if root then
            lastDeath = root.CFrame
        end
        if getgenv().ar then
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer({[1] = "Respawn"})
            task.wait(0.2)
            local newRoot = getRoot(Players.LocalPlayer.Character)
            if newRoot then
                newRoot.CFrame = lastDeath
            end
            Players.LocalPlayer.PlayerGui.ScreenGui.Enabled = true
            task.wait(3)
            Players.LocalPlayer.PlayerGui.IntroGui.Enabled = false; game.Lighting.Blur.Enabled = false
        end
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)
if Players.LocalPlayer.Character then
    setupCharacter(Players.LocalPlayer.Character)
end


Section:NewButton("Remove Nuvem", "Remove nuvens do mapa", function()
    Workspace.Map.RealCloud:Destroy()
end)

Section:NewToggle("Anti Mod", "Desconecta ao detectar moderadores", function(state)
    getgenv().antiMod = state
    if getgenv().antiMod then
        local rolesToKick = {"💎｜Special Member", "⚡｜Moderator", "✨｜Admin", "👾｜Dev", "👑｜Creator"}

        local function onPlayer(player)
            local success, role = pcall(function()
                return player:GetRoleInGroup(15762035)
            end)

            if success and (table.find(rolesToKick, role) or player:IsInGroup(16817874)) then
                Players.LocalPlayer:Kick(player.Name .. " joined.")
            end
        end

        game.Players.PlayerAdded:Connect(onPlayer)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                onPlayer(player)
            end
        end
    end
end)

Section:NewButton("Hide Name", "Remove nome visível do personagem", function(state)
    if getgenv().hn then
        pcall(function()
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart:FindFirstChild("SPTS_RK_BG"):Destroy()
                character.HumanoidRootPart:FindFirstChild("SPTS_PN_BG"):Destroy()
            end
        end)
    end
end)

local Tab1 = Window:NewTab("AutoFarm")
local Section = Tab1:NewSection("Auto Farms")

local autoFarmRequests = {
    FS = "Add_FS_Request",
    BT = "+BT1",
    MS = "Add_MS_Request",
    JF = "Add_JF_Request"
}

for name, request in pairs(autoFarmRequests) do
    Section:NewToggle("Auto " .. name, "Ativar " .. name, function(state)
        getgenv()[name:lower()] = state
        while getgenv()[name:lower()] do
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer({[1] = request})
            task.wait(0.1)
        end
    end)
end

Section:NewToggle("Auto MS and JF", "Ativar MS e JF simultaneamente", function(state)
    getgenv().both = state
    while getgenv().both do
        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer({[1] = "Add_MS_Request"})
        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer({[1] = "Add_JF_Request"})
        task.wait(0.2)
    end
end)

Section:NewToggle("Auto Meditar", "Meditar automaticamente", function(state)
    getgenv().am = state
    Players.LocalPlayer.CharacterAdded:Connect(function(Char)
        repeat task.wait() until Char:FindFirstChild("HumanoidRootPart")
        local meditateTool = Players.LocalPlayer.Backpack:FindFirstChild("Meditate")
        if meditateTool then
            meditateTool.Parent = Char
        end
    end)
end)

-- Teleports Section
local Tab2 = Window:NewTab("Teleports")

local function gatherLocations(folder)
    local locations = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") or child:FindFirstChildWhichIsA("BasePart") then
            table.insert(locations, child.Name)
        end
    end
    return locations
end

local function getLocationPosition(folder, locationName)
    local target = folder:FindFirstChild(locationName)
    if target then
        return target:IsA("BasePart") and target.Position or target:FindFirstChildWhichIsA("BasePart").Position
    end
    return nil
end

local map = Workspace:FindFirstChild("Map")
local trainingCollisions = map and map:FindFirstChild("Training_Collisions")
if trainingCollisions then
    for _, trainingType in ipairs({"FistStrength", "BodyToughness", "PsychicPower"}) do
        local folder = trainingCollisions:FindFirstChild(trainingType)
        if folder then
            local section = Tab2:NewSection(trainingType)
            local locations = gatherLocations(folder)

            section:NewDropdown("Escolha um local", "Selecione um local para teleporte", locations, function(selectedOption)
                local position = getLocationPosition(folder, selectedOption)
                if position then
                    Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                else
                    warn("Posição não encontrada para: " .. selectedOption)
                end
            end)
        end
    end
end
