Config = {}

-- İzin verilen meslekler
Config.AllowedJobs = {
    'police',
    'sheriff',
    'fbi',  -- örnek olarak
    'ranger' -- örnek olarak
}

-- Meslek renklerini özelleştirme (blip renkleri)
Config.JobColors = {
    ['police'] = 38,  -- Mavi
    ['sheriff'] = 5,  -- Sarı
    ['fbi'] = 1,      -- Kırmızı
    ['ranger'] = 25   -- Mor
}

-- Meslek isimleri (menüde görünecek isimler)
Config.JobLabels = {
    ['police'] = 'Polis',
    ['sheriff'] = 'Şerif',
    ['fbi'] = 'FBI',
    ['ranger'] = 'Park Polisi'
} 