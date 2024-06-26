local QBCore = exports['qb-core']:GetCoreObject()
local entryCoords = Config.Locations.shopEntranceCoords
local exitCoords = Config.Locations.shopExitCoords

DiscordWebHook = 'https://discord.com/api/webhooks/1229080532764065913/rSTb_CHvlKp8eIzmD5EzEO4eZwXpVx8Oc4aj6gQQ_rMTk59_sIQiE8Y607MQZ9k6bRuf'

local function webHookBook(data, playerName)
    

    contents = ""
    for i = 1, #data.pages do
        if string.sub(data.pages[i], 1,1) == "\"" and string.sub(data.pages[i], -1, -1) == "\"" then
            data.pages[i] = string.sub(data.pages[i], 2, -2)
        end
        contents = contents .. data.pages[i] .. '\n'
    end
    local payload = json.encode({
        username = data.name .. " by " .. playerName,
        content = contents,
    })
    PerformHttpRequest(DiscordWebHook, function() end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

local function webHookCard(data, playerName)

    contents = data.url
    local payload = json.encode({
        username = data.name .. " by " .. playerName,
        content = contents,
    })
    PerformHttpRequest(DiscordWebHook, function() end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

local function createBusinessCard(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local item = data.type
    local amount = tonumber(data.amount)

    local info = {}
    info.name = data.business
    info.business = data.business
    info.url = data.url
    info.cardType = data.type
    info.author = playerName

	if Config.Inv == 'qb' then
		if Player.Functions.RemoveMoney("cash", amount * Config.PrintCost[item]) then
            Player.Functions.AddItem(item, amount, nil, info)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
            webHookCard(info, playerName)
        else
            QBCore.Functions.Notify(source, "プリンターを利用するためのお金が足りない", "error")
        end
	elseif Config.Inv == 'ox' then
        if amount < exports.ox_inventory:CanCarryAmount(source, item) then
            if exports.ox_inventory:RemoveItem(source, "cash", amount * Config.PrintCost[item]) then
                exports.ox_inventory:AddItem(source, item, amount, info)
            else
                QBCore.Functions.Notify(source, "Not Enough Money", "error")
            end
        else
            QBCore.Functions.Notify(source, "Cannot carry amount", "error")
        end
	end

end

for i, type in pairs(Config.Items) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        TriggerClientEvent("cw-prints:client:businessCard", source, Item)
    end)
end

local function createBook(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname 
    local item = data.type

    local info = {}
    info.name = data.name
    info.pages = data.pages
    info.bookType = data.type
    info.author = playerName
    local amount = tonumber(data.amount)

	if Config.Inv == 'qb' then
		if Player.Functions.RemoveMoney("cash", amount * Config.PrintCost[item]) then
            Player.Functions.AddItem(item, amount, nil, info)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
            webHookBook(info, playerName)
        else
            QBCore.Functions.Notify(source, "プリンターを利用するためのお金が足りない", "error")
        end
	elseif Config.Inv == 'ox' then
        if amount < exports.ox_inventory:CanCarryAmount(source, item) then
            if exports.ox_inventory:RemoveItem(source, "cash", amount * Config.PrintCost[item]) then
                exports.ox_inventory:AddItem(source, item, amount, info)
            else
                QBCore.Functions.Notify(source, "Not Enough Money", "error")
            end
        else
            QBCore.Functions.Notify(source, "Cannot carry amount", "error")
        end
	end
end


for i, type in pairs(Config.BookItems) do
    QBCore.Functions.CreateUseableItem(type.value, function(source, Item)
        TriggerClientEvent("cw-prints:client:openBook", source, Item)
    end)
end

RegisterNetEvent("cw-prints:server:GiveItem", function(playerId, toPlayer, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(type)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(playerId))

    if item ~= nil then
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
            if OtherPlayer.Functions.AddItem(item.name, 1, false, item.info) then
                TriggerClientEvent('inventory:client:ItemBox', playerId, QBCore.Shared.Items[item.name], "add")
                TriggerClientEvent('QBCore:Notify', playerId,
                    Lang:t("info.itemReceived",
                        {
                            value_amount = 1,
                            value_lable = item.label,
                            value_firstname = Player.PlayerData.charinfo.firstname,
                            value_lastname = Player.PlayerData.charinfo.lastname
                        }
                    )
                )
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, true)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove")
                TriggerClientEvent('QBCore:Notify', src,
                    Lang:t("info.gaveItem",
                        {
                            value_amount = 1,
                            value_lable = item.label,
                            value_firstname = OtherPlayer.PlayerData.charinfo.firstname,
                            value_lastname = OtherPlayer.PlayerData.charinfo.lastname
                        }
                    )
                )
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('qb-inventory:client:giveAnim', src)
                TriggerClientEvent('qb-inventory:client:giveAnim', playerId)
            else
                Player.Functions.AddItem(item.name, 1, item.slot, item.info)
                TriggerClientEvent('QBCore:Notify', src,
                    Lang:t("error.otherInventoryFull"), "error")
                TriggerClientEvent('QBCore:Notify', playerId, Lang:t("error.inventoryFull"), "error")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", playerId, false)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.notEnoughItems"), "error")
        end
    end

end)


RegisterNetEvent("cw-prints:server:createCard", function(data)
    createBusinessCard(source, data)
end)

RegisterNetEvent("cw-prints:server:createBook", function(data)
    createBook(source, data)
end)


QBCore.Commands.Add('makecard', Lang:t("command.makecardAdmin"),
    { { name = 'business', help = Lang:t("command.business") }, { name = 'link', help = Lang:t("command.link") },
        { name = "amount", help = Lang:t("command.amount") }, { name = 'type', help = Lang:t("command.type") } }, true,
    function(source, args)
        local data = { args[1], args[2], args[3], args[4] }
        createBusinessCard(source, data)
    end, "dev")
