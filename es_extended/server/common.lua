ESX = {}
ESX.Players = {}
ESX.Jobs = {}
ESX.Orgs = {}
ESX.Items = {}
Core = {}
Core.UsableItemsCallbacks = {}
Core.ServerCallbacks = {}
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

exports('getSharedObject', function()
	return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
	SetConvarReplicated('inventory:framework', 'esx')
	SetConvarReplicated('inventory:weight', Config.MaxWeight * 1000)
end

local function StartDBSync()
	CreateThread(function()
		while true do
			Wait(10 * 60 * 1000)
			Core.SavePlayers()
		end
	end)
end

MySQL.ready(function()
	if not Config.OxInventory then
		local items = MySQL.query.await('SELECT * FROM items')
		for k, v in ipairs(items) do
			ESX.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
	else
		TriggerEvent('__cfx_export_ox_inventory_Items', function(ref)
			if ref then
				ESX.Items = ref()
			end
		end)

		AddEventHandler('ox_inventory:itemList', function(items)
			ESX.Items = items
		end)

		while not next(ESX.Items) do Wait(0) end
	end

	local Jobs = {}
	local jobs = MySQL.query.await('SELECT * FROM jobs')

	for _, v in ipairs(jobs) do
		Jobs[v.name] = v
		Jobs[v.name].grades = {}
	end

	local jobGrades = MySQL.query.await('SELECT * FROM job_grades')

	for _, v in ipairs(jobGrades) do
		if Jobs[v.job_name] then
			Jobs[v.job_name].grades[tostring(v.grade)] = v
		else
			print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
		end
	end

	for _, v in pairs(Jobs) do
		if ESX.Table.SizeOf(v.grades) == 0 then
			Jobs[v.name] = nil
			print(('[^3WARNING^7] Ignoring job ^5"%s"^0due to no job grades found'):format(v.name))
		end
	end

	if not Jobs then
		-- Fallback data, if no jobs exist
		ESX.Jobs['unemployed'] = {
			label = 'Unemployed',
			grades = {
				['0'] = {
					grade = 0,
					label = 'Unemployed',
					salary = 200,
					skin_male = {},
					skin_female = {}
				}
			}
		}
	else
		ESX.Jobs = Jobs
	end

	local Orgs = {}
	local orgs = MySQL.query.await('SELECT * FROM orgs')

	for _, v in ipairs(orgs) do
		Orgs[v.name] = v
		Orgs[v.name].grades = {}
	end

	local orgGrades = MySQL.query.await('SELECT * FROM org_grades')

	for _, v in ipairs(orgGrades) do
		if Orgs[v.org_name] then
			Orgs[v.org_name].grades[tostring(v.grade)] = v
		else
			print(('[^3WARNING^7] Ignoring org grades for ^5"%s"^0 due to missing org'):format(v.org_name))
		end
	end

	for _, v in pairs(Orgs) do
		if ESX.Table.SizeOf(v.grades) == 0 then
			Orgs[v.name] = nil
			print(('[^3WARNING^7] Ignoring org ^5"%s"^0due to no org grades found'):format(v.name))
		end
	end

	if not Orgs then
		-- Fallback data, if no orgs exist
		ESX.Orgs['unemployed2'] = {
			label = 'Unemployed2',
			grades = {
				['0'] = {
					grade = 0,
					label = 'Unemployed2',
					salary = 0,
					skin_male = {},
					skin_female = {}
				}
			}
		}
	else
		ESX.Orgs = Orgs
	end

	print('[^2INFO^7] ESX ^5Legacy^0 initialized')
	StartDBSync()
	StartPayCheck()
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
