Config = {}

-- MDT'yi kullanabilecek meslekler ve minimum grade'leri
Config.AllowedJobs = {
    ['police'] = 0,    -- Polis için minimum grade
    ['sheriff'] = 0    -- Şerif için minimum grade
}

-- MDT açma komutu
Config.Command = 'mdt'

-- MDT animasyonu ayarları
Config.Animation = {
    dict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
    anim = "idle_a",
    prop = {
        model = `prop_cs_tablet`,
        bone = 60309,
        pos = vector3(0.03, 0.002, -0.0),
        rot = vector3(10.0, 160.0, 0.0)
    }
} 