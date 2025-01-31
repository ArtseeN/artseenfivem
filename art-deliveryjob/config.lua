Config = {}

Config.MotorcycleModel = 'faggio' -- Spawn olacak motorsiklet modeli

Config.Locations = {
    ["Vinewood"] = {
        label = "Vinewood Bulvarı",
        points = {
            {x = 380.2, y = -827.4, z = 29.3, w = 180.0},
            {x = 472.7, y = -909.5, z = 27.5, w = 90.0},
            {x = 228.7, y = -784.8, z = 30.7, w = 250.0}
        }
    },
    ["Mirror"] = {
        label = "Mirror Park",
        points = {
            {x = 1127.4, y = -644.2, z = 56.8, w = 350.0},
            {x = 1163.8, y = -503.6, z = 65.5, w = 80.0},
            {x = 1260.2, y = -588.3, z = 69.0, w = 290.0}
        }
    },
    ["Vespucci"] = {
        label = "Vespucci Plajı",
        points = {
            {x = -1183.3, y = -1315.4, z = 5.1, w = 125.0},
            {x = -1039.8, y = -1396.7, z = 5.2, w = 120.0},
            {x = -931.5, y = -1284.3, z = 5.0, w = 180.0}
        }
    },
    ["Sandy"] = {
        label = "Sandy Shores",
        points = {
            {x = 1959.8, y = 3741.5, z = 32.3, w = 300.0},
            {x = 1932.6, y = 3727.7, z = 32.8, w = 120.0},
            {x = 1851.2, y = 3683.4, z = 34.2, w = 210.0}
        }
    },
    ["Paleto"] = {
        label = "Paleto Bay",
        points = {
            {x = -105.5, y = 6528.7, z = 30.1, w = 315.0},
            {x = -146.2, y = 6457.8, z = 31.4, w = 140.0},
            {x = -33.8, y = 6455.2, z = 31.4, w = 225.0}
        }
    }
}

Config.StartLocation = vector4(216.72, -1523.28, 29.29, 50.0) -- NPC konumu (heading 50.0 olarak ayarlandı)
Config.VehicleSpawnPoint = vector4(222.97, -1528.06, 29.17, 50.0) -- Motor spawn konumu (heading 50.0 olarak ayarlandı)

Config.PaymentMin = 50
Config.PaymentMax = 150

Config.DeliveryPedModels = {
    "a_m_y_business_03",
    "a_m_y_business_01",
    "a_f_y_business_01",
    "a_f_y_business_02"
}

-- Teslimat için süre sınırı (saniye cinsinden)
Config.DeliveryTimeLimit = 300 -- 5 dakika

-- Başarısız teslimat için para cezası (opsiyonel)
Config.FailurePenalty = 100 -- Başarısız teslimat için para cezası 