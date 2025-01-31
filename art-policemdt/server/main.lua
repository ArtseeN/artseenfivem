local QBCore = exports['qb-core']:GetCoreObject()

-- Kişi arama callback
QBCore.Functions.CreateCallback('police:mdt:searchPerson', function(source, cb, searchTerm)
    local result = {}
    if string.len(searchTerm) >= 3 then
        local players = exports.oxmysql:executeSync('SELECT citizenid, charinfo, metadata FROM players WHERE (LOWER(charinfo) LIKE ? OR citizenid LIKE ?)', {
            '%'..string.lower(searchTerm)..'%',
            '%'..searchTerm..'%'
        })

        for _, player in ipairs(players) do
            local charinfo = json.decode(player.charinfo)
            local metadata = json.decode(player.metadata)
            
            -- Profil fotoğrafını mdt_wanted tablosundan al
            local profilePic = exports.oxmysql:executeSync('SELECT img_url FROM mdt_wanted WHERE citizenid = ? AND is_profile_pic = 1 ORDER BY added_date DESC LIMIT 1', {
                player.citizenid
            })[1]
            
            -- Sabıka kayıtlarını al
            local criminalRecords = exports.oxmysql:executeSync('SELECT * FROM mdt_criminal_records WHERE citizenid = ? ORDER BY added_date DESC', {
                player.citizenid
            })
            
            table.insert(result, {
                id = player.citizenid,
                name = charinfo.firstname .. ' ' .. charinfo.lastname,
                birthDate = charinfo.birthdate,
                phone = charinfo.phone,
                address = metadata.address or 'Belirtilmemiş',
                criminal = criminalRecords,
                img = profilePic and profilePic.img_url or "https://cdn.discordapp.com/attachments/1116791667584417894/1217422386715811850/unknown.png?ex=66033e6c&is=65f0c96c&hm=c3f18134d3d8b6b6d6c6dc3ea35e75d0d1f6acd6f4ed95e0e67a8cc6f0e1b6e4&"
            })
        end
    end
    cb(result)
end)

-- Araç arama callback
QBCore.Functions.CreateCallback('police:mdt:searchVehicle', function(source, cb, searchTerm)
    local result = {}
    if string.len(searchTerm) >= 2 then -- En az 2 karakter için arama yap
        -- Hem plaka hem de sahip ismine göre arama yap
        local vehicles = exports.oxmysql:executeSync([[
            SELECT 
                pv.*, 
                p.charinfo,
                p.citizenid
            FROM 
                player_vehicles pv
            LEFT JOIN 
                players p ON p.citizenid = pv.citizenid
            WHERE 
                pv.plate LIKE ? 
                OR JSON_EXTRACT(p.charinfo, '$.firstname') LIKE ? 
                OR JSON_EXTRACT(p.charinfo, '$.lastname') LIKE ?
        ]], {
            '%'..searchTerm..'%',
            '%'..searchTerm..'%',
            '%'..searchTerm..'%'
        })

        for _, vehicle in ipairs(vehicles) do
            local charinfo = json.decode(vehicle.charinfo)
            -- QBCore'dan araç modelini al
            local vehicleData = QBCore.Shared.Vehicles[vehicle.vehicle] or {
                name = vehicle.vehicle,
                brand = "Bilinmiyor",
                model = "Bilinmiyor"
            }
            
            table.insert(result, {
                plate = vehicle.plate,
                owner = {
                    name = charinfo.firstname .. ' ' .. charinfo.lastname,
                    phone = charinfo.phone,
                    citizenid = vehicle.citizenid
                },
                vehicle = {
                    name = vehicleData.name,
                    brand = vehicleData.brand,
                    model = vehicleData.model,
                    state = vehicle.state -- Araç durumu (garajda, dışarıda vb.)
                }
            })
        end
    end
    cb(result)
end)

-- Kişi bilgisi güncelle (sadece fotoğraf)
RegisterNetEvent('police:mdt:updatePerson')
AddEventHandler('police:mdt:updatePerson', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        if data.type == 'image' then
            -- Önce eski profil fotoğrafını kaldır
            exports.oxmysql:execute('DELETE FROM mdt_wanted WHERE citizenid = ? AND is_profile_pic = 1', {data.citizenid})
            
            -- Yeni profil fotoğrafını ekle
            exports.oxmysql:insert('INSERT INTO mdt_wanted (citizenid, img_url, added_by, added_date, is_profile_pic) VALUES (?, ?, ?, ?, 1)', {
                data.citizenid,
                data.img,
                Player.PlayerData.citizenid,
                os.date('%Y-%m-%d %H:%M:%S')
            })
            
            TriggerClientEvent('QBCore:Notify', src, 'Fotoğraf güncellendi!', 'success')
        end
    end
end)

-- Sabıka ekle
RegisterNetEvent('police:mdt:addCriminal')
AddEventHandler('police:mdt:addCriminal', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        -- Sabıka kaydını direkt tabloya ekle
        exports.oxmysql:insert('INSERT INTO mdt_criminal_records (citizenid, offense, date, officer) VALUES (?, ?, ?, ?)', {
            data.citizenid,
            data.reason,
            data.date,
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        })

        TriggerClientEvent('QBCore:Notify', src, 'Sabıka kaydı eklendi!', 'success')
    end
end)

-- Sabıka kayıtlarını getir
QBCore.Functions.CreateCallback('police:mdt:getCriminalRecords', function(source, cb, citizenid)
    local records = exports.oxmysql:executeSync('SELECT * FROM mdt_criminal_records WHERE citizenid = ? ORDER BY added_date DESC', {citizenid})
    cb(records)
end)

-- Arananlar listesini getir
QBCore.Functions.CreateCallback('police:mdt:getWantedList', function(source, cb)
    local wanted = exports.oxmysql:executeSync([[
        SELECT 
            w.*,
            CONCAT(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')), ''), ' ', 
                  COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname')), '')) as person_name
        FROM 
            mdt_wanted w
        LEFT JOIN 
            players p ON p.citizenid = w.citizenid
        WHERE 
            w.is_profile_pic = 0
        ORDER BY 
            w.added_date DESC
    ]])

    -- Eğer wanted nil ise boş array dön
    if not wanted then
        wanted = {}
    end

    -- Her kayıt için null kontrolleri yap
    for i, record in ipairs(wanted) do
        record.person_name = record.person_name or 'İsim Bilinmiyor'
        record.img_url = record.img_url or "https://cdn.discordapp.com/attachments/1116791667584417894/1217422386715811850/unknown.png?ex=66033e6c&is=65f0c96c&hm=c3f18134d3d8b6b6d6c6dc3ea35e75d0d1f6acd6f4ed95e0e67a8cc6f0e1b6e4&"
        record.danger_level = record.danger_level or 'Bilinmiyor'
        record.reason = record.reason or 'Belirtilmemiş'
        record.added_by = record.added_by or 'Sistem'
    end

    cb(wanted)
end)

-- Aranan ekle
RegisterNetEvent('police:mdt:addWanted')
AddEventHandler('police:mdt:addWanted', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        exports.oxmysql:insert('INSERT INTO mdt_wanted (citizenid, reason, added_by, added_date, danger_level, img_url) VALUES (?, ?, ?, ?, ?, ?)', {
            data.citizenid,
            data.reason,
            Player.PlayerData.citizenid,
            os.date('%Y-%m-%d %H:%M:%S'),
            data.dangerLevel,
            data.img or "https://cdn.discordapp.com/attachments/1116791667584417894/1217422386715811850/unknown.png?ex=66033e6c&is=65f0c96c&hm=c3f18134d3d8b6b6d6c6dc3ea35e75d0d1f6acd6f4ed95e0e67a8cc6f0e1b6e4&"
        })
    end
end)

-- Arananı kaldır
RegisterNetEvent('police:mdt:removeWanted')
AddEventHandler('police:mdt:removeWanted', function(citizenid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        exports.oxmysql:execute('DELETE FROM mdt_wanted WHERE citizenid = ?', {citizenid})
    end
end)

-- Sabıka sil
RegisterNetEvent('police:mdt:removeCriminal')
AddEventHandler('police:mdt:removeCriminal', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        exports.oxmysql:execute('DELETE FROM mdt_criminal_records WHERE id = ? AND citizenid = ?', {
            data.recordId,
            data.citizenid
        })

        TriggerClientEvent('QBCore:Notify', src, 'Sabıka kaydı silindi!', 'success')
    end
end)

-- SQL tablosu oluştur
CreateThread(function()
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS mdt_wanted (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50),
            reason TEXT,
            added_by VARCHAR(50),
            added_date DATETIME,
            danger_level VARCHAR(20),
            img_url TEXT,
            is_profile_pic BOOLEAN DEFAULT FALSE,
            INDEX idx_citizenid (citizenid),
            INDEX idx_profile_pic (is_profile_pic)
        )
    ]])

    -- Eğer tablo varsa ve is_profile_pic kolonu yoksa ekle
    exports.oxmysql:execute([[
        ALTER TABLE mdt_wanted 
        ADD COLUMN IF NOT EXISTS is_profile_pic BOOLEAN DEFAULT FALSE,
        ADD INDEX IF NOT EXISTS idx_citizenid (citizenid),
        ADD INDEX IF NOT EXISTS idx_profile_pic (is_profile_pic)
    ]])

    -- Sabıka kayıtları tablosu
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS mdt_criminal_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50),
            offense TEXT,
            date VARCHAR(50),
            officer VARCHAR(100),
            added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_citizenid (citizenid)
        )
    ]])
end) 