-- [[ 1. CONFIG ]]
local WhitelistURL = "https://raw.githubusercontent.com/dezqpal/PRM/refs/heads/main/Whitelist.text" 
local MainScript = "https://raw.githubusercontent.com/dezqpal/PRM/refs/heads/main/PRM.PRVT.LUA"
local WebhookURL = "https://discord.com/api/webhooks/1502166760516882493/4qJ3WukYRvdATkabhW8-IFRc_pHheUdq57dZhHAm8aYuBGm2np2fwajci-cTYnTJ2VA1"

-- [[ 2. FORMATTER FUNCTION ]]
local function FormatNumber(value)
    if not value or value == "N/A" then return "0" end
    value = tonumber(value) or 0
    local suffixes = {"", "K", "M", "B", "T", "QA", "QI", "SX", "SP", "O", "N", "D"}
    local index = 1
    while value >= 1000 and index < #suffixes do
        value = value / 1000
        index = index + 1
    end
    return string.format("%.2f%s", value, suffixes[index]):gsub("%.00", "")
end

-- [[ 3. SERVICES ]]
local Player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ 4. WEBHOOK ]]
local function SendEnhancedWebhook(status)
    local leaderstats = Player:FindFirstChild("leaderstats")
    local strengthRaw = leaderstats and leaderstats:FindFirstChild("Strength") and leaderstats.Strength.Value or 0
    local rebirthsRaw = leaderstats and leaderstats:FindFirstChild("Rebirths") and leaderstats.Rebirths.Value or 0
    local agilityRaw = Player:FindFirstChild("Agility") and Player.Agility.Value or (leaderstats and leaderstats:FindFirstChild("Agility") and leaderstats.Agility.Value or 0)
    local durabilityRaw = Player:FindFirstChild("Durability") and Player.Durability.Value or (leaderstats and leaderstats:FindFirstChild("Durability") and leaderstats.Durability.Value or 0)

    local executor = (identifyexecutor or getexecutorname or function() return "Unknown" end)()
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name

    local data = {
        ["embeds"] = {{
            ["title"] = "📩 PRM||WEBHOOK",
            ["color"] = (status == "ACCESS GRANTED" and 3066993 or 15158332),
            ["fields"] = {
                {["name"] = "👤 User", ["value"] = Player.Name .. " (" .. Player.DisplayName .. ")", ["inline"] = true},
                {["name"] = "🆔 ID", ["value"] = tostring(Player.UserId), ["inline"] = true},
                {["name"] = "📊 Status", ["value"] = status, ["inline"] = false},
                {["name"] = "💪 Strength", ["value"] = FormatNumber(strengthRaw), ["inline"] = true},
                {["name"] = "♻️ Rebirths", ["value"] = FormatNumber(rebirthsRaw), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = gameName, ["inline"] = false},
                {["name"] = "⚙️ Executor", ["value"] = executor, ["inline"] = true}
                
            },
            ["footer"] = {["text"] = "PRM • " .. os.date("%Y-%m-%d %H:%M:%S")},
            ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"}
        }}
    }
    
    pcall(function()
        local request = http_request or request or (syn and syn.request)
        if request then
            request({
                Url = WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

-- [[ 5. GITHUB VERIFICATION ]]
local function CheckWhitelist()
    local success, result = pcall(function()
        return game:HttpGet(WhitelistURL)
    end)

    if success then
        -- Split the text file by new lines and check for player name
        for name in string.gmatch(result, "[^\r\n]+") do
            if Player.Name:lower() == name:lower():gsub("%s+", "") then
                return true
            end
        end
    end
    return false
end

-- Execution
if CheckWhitelist() then
    SendEnhancedWebhook("ACCESS GRANTED")
    task.wait(0.5)
    loadstring(game:HttpGet(MainScript))()
else
    SendEnhancedWebhook("FAILED ATTEMPT")
    Player:Kick("KUMAG!!!")
end
