ChatStarted = false
MaxInitRetries = 10
TeamsPlayers = {}

ChatCmdConvarValue = string.lower(GetConvar('chat-hook-teams_createChatCommands', 'false'))

-- Only expose net events if we're creating commands
if (ChatCmdConvarValue == 'true' or ChatCmdConvarValue == '"true"') then
    RegisterNetEvent('chat-hook-teams:joinTeam')
    RegisterNetEvent('chat-hook-teams:unjoinTeam')
end

AddEventHandler('chat-hook-teams:joinTeam', function(team, player)
    local playerId = player
    if playerId == nil then
        playerId = source
    end
    print(GetPlayerName(playerId) .. " joining team " .. tostring(team))
    AddTeamPlayer(team, playerId)
end)

AddEventHandler('chat-hook-teams:unjoinTeam', function(team, player)
    local playerId = player
    if playerId == nil then
        playerId = source
    end
    print(GetPlayerName(playerId) .. " leaving team " .. tostring(team))
    RemoveTeamPlayer(team, playerId)
end)

AddEventHandler('chat-hook-teams:resetTeams', function()
    print('Resetting teams')
    ResetTeams()
end)

function AddTeamPlayer(team, player)
    if TeamsPlayers[team] == nil then
        TeamsPlayers[team] = {}
    end

    local teamArr = TeamsPlayers[team]
    for i = 1, #teamArr do
        if teamArr[i] == player and type(teamArr[i]) == "number" then
            return
        end
    end

    table.insert(teamArr, player)
end

function RemoveTeamPlayer(team, player)
    if TeamsPlayers[team] ~= nil then
        local teamArr = TeamsPlayers[team]
        local index = -1
        for i = 1, #teamArr do
            if teamArr[i] == player and type(teamArr[i]) == "number" then
                index = i
                break
            end
        end

        if index ~= -1 then
            table.remove(teamArr, index)
        end

        local teamPlayerCount = #teamArr
        if teamPlayerCount == 0 then
            TeamsPlayers[team] = nil
        end
    end
end

function ResetTeams()
    for key, _ in pairs(TeamsPlayers) do
        TeamsPlayers[key] = nil
    end
end

function ChatMessageHook(src, msg, hookRef)
    -- do actual filtering here
    local matchingTeams = {}
    for team, players in pairs(TeamsPlayers) do
        if players ~= nil then
            for _, playerId in ipairs(players) do
                if playerId == src then
                    table.insert(matchingTeams, players)
                    break
                end
            end
        end
    end

    local matchingPlayers = {}
    for _, players in ipairs(matchingTeams) do
        for index, playerToAdd in ipairs(players) do
            local exists = false
            for i, player in ipairs(matchingPlayers) do
                if player == playerToAdd then
                    exists = true
                end
            end

            if exists == false then
                table.insert(matchingPlayers, playerToAdd)
            end
        end
    end

    if #matchingPlayers ~= 0 then
        hookRef.setRouting(matchingPlayers)
        --print('message arrived from player ' ..
        --GetPlayerName(src) ..
        --', is being forwarded to ' .. tostring(#matchingPlayers) .. ' players')
    end
end

function InitTeamChatHook()
    if ChatStarted ~= true then
        print("[chat-hook-teams] could not detect 'chat' resource starting, but attempting init anyway")
    else
        print("[chat-hook-teams] 'chat' resource has started, attempting init")
    end
    if exports.chat ~= nil then
        print("[chat-hook-teams] found 'chat' resource exports")

        print("type " .. type(ChatMessageHook))
        exports.chat.registerMessageHook(nil, ChatMessageHook)
    end
end

AddEventHandler('onServerResourceStart', function(resource)
    if resource == 'chat' then
        ChatStarted = true
    end

    if resource == 'chat-hook-teams' then
        if ChatStarted ~= true then
            local retries = 0
            retry = function()
                if ChatStarted or retries >= MaxInitRetries then
                    InitTeamChatHook()
                else
                    retries = retries + 1
                    Citizen.SetTimeout(200, retry)
                end
            end
            Citizen.SetTimeout(2000, retry)
        else
            InitTeamChatHook()
        end
    end
end)
