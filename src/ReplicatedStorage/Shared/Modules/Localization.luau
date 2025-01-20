-- local Players = game:GetService("Players")
-- local HttpService = game:GetService("HttpService")
-- local LocalizationService = game:GetService("LocalizationService")
-- local Countries = {}

-- local success, result = pcall(function()
-- 	return HttpService:GetAsync("http://country.io/names.json")
-- end)

-- if success and result then
-- 	Countries = HttpService:JSONDecode(result)
-- end

-- Players.PlayerAdded:Connect(function(player)
-- 	local success, code = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, player)
-- 	if success and code then
-- 		print(Countries[code])
-- 	end
-- end)
