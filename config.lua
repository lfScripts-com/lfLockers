Config = {}

-- Configuration de la langue (fr/en)
Config.Language = 'fr'

-- Configuration des casiers multiples
Config.Lockers = {
    {
        id = "police_locker",
        name = "Casiers Police",
        position = vector3(455.815368, -992.281312, 30.678344),
        jobRequired = 'police',
        adminGrade = 4,
        lockerWeight = 24000,
        markerType = 25,
        markerSize = {x = 0.5, y = 0.5, z = 0.5},
        markerColor = {r = 255, g = 255, b = 200, a = 100},
        drawDistance = 5.0
    },
    {
        id = "mechanic_locker",
        name = "Casiers Mécaniciens",
        position = vector3(-224.109894, -1321.186768, 30.880616),
        jobRequired = 'mechanic',
        adminGrade = 2,
        lockerWeight = 30000,
        markerType = 25,
        markerSize = {x = 0.5, y = 0.5, z = 0.5},
        markerColor = {r = 255, g = 200, b = 100, a = 100},
        drawDistance = 5.0
    }
}

-- Touches d'interaction
Config.Keys = {
    open = 38, -- E
    cancel = 177 -- BACKSPACE
}

-- Type d'inventaire à ouvrir (via ox_inventory)
Config.InventoryType = 'stash' 