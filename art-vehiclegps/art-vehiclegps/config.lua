Config = {}

-- İzin verilen meslekler ve blip renkleri
Config.AllowedJobs = {
    ['police'] = {
        allowed = true,
        blipColor = 3  -- Mavi renk
    },
    ['sheriff'] = {
        allowed = true,
        blipColor = 5  -- Sarı renk
    }
}

-- Blip ayarları
Config.BlipSettings = {
    sprite = 326,  -- GPS ikonu
    scale = 0.8,   -- Boyut
    shortRange = false,
    heading = true
}

-- Mevcut Config ayarlarının sonuna ekleyin
Config.MenuSettings = {
    menuTitle = "GPS Kontrol Paneli",
    menuIcon = "📍",
    closeText = "Kapat",
    backText = "Geri"
} 