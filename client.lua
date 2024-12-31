ChatCmdConvarValue = string.lower(GetConvar('chat-hook-teams_createChatCommands', 'false'))

if (ChatCmdConvarValue == 'true' or ChatCmdConvarValue == '"true"') then
    RegisterCommand('join', function(source, args)
        print('source: ' .. tostring(source))
        for index, value in ipairs(args) do
            print('arg ' .. tostring(index) .. ': ' .. tostring(value))
        end
        local teamId = tonumber(args[1])
        if type(teamId) == 'number' then
            TriggerServerEvent('chat-hook-teams:joinTeam', teamId)
        end
    end, false)

    RegisterCommand('unjoin', function(source, args)
        local teamId = tonumber(args[1])
        if type(teamId) == 'number' then
            TriggerServerEvent('chat-hook-teams:unjoinTeam', teamId)
        end
    end, false)
end
