Config = Config or {}
Config.Debug = true

Config.Target = "ox" -- only ox for now
Config.Framwork = "qbx" -- only qbx for now
Config.FuelSystem = "ox" -- only ox for now
Config.UseJob = false -- false for now

Config.TicketPrice = 1000
Config.MaxPersonEnterBus = 1

Config.AllowedVehicles = "bus"

Config.Location = vec4(462.22, -641.15, 28.45, 175.0)

Config.Ped = {
    model = 'a_m_m_hasjew_01',
    coords = vec4(451.5, -629.53, 28.54, 265.26),
    scenario = 'WORLD_HUMAN_STAND_MOBILE',
}

Config.Stations = {
    [1] = { "Halte 1", vec4(308.3, -768.78, 29.31, 349.57) },
    [2] = { "Halte 2", vec4(114.11, -785.43, 31.38, 63.64) },
}

-- TEMP
Config.Meter = {
    ["defaultPrice"] = 0, -- price per mile
    ["startingPrice"] = 0  -- static starting price
}