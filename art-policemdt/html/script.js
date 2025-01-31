// Örnek veri tabanı
const database = {
    persons: [
        {
            id: "12345678901",
            name: "Ahmet Yılmaz",
            birthDate: "01.01.1990",
            phone: "05551234567",
            address: "Atatürk Mah. 123. Sok. No:45 İstanbul",
            criminal: ["Hız İhlali (2022)", "Park İhlali (2023)"],
            img: "https://placekitten.com/100/100"
        },
        {
            id: "98765432109",
            name: "Ayşe Demir",
            birthDate: "15.05.1985",
            criminal: [],
            img: "https://placekitten.com/101/101"
        }
    ],
    vehicles: [
        {
            plate: "34 ABC 123",
            owner: "Ahmet Yılmaz",
            model: "Honda Civic",
            year: "2020",
            status: "Temiz"
        },
        {
            plate: "06 XYZ 789",
            owner: "Mehmet Kaya",
            model: "Toyota Corolla",
            year: "2019",
            status: "Temiz"
        }
    ],
    activeCalls: [
        {
            id: "1",
            location: "Atatürk Caddesi No:15",
            type: "Trafik Kazası",
            priority: "Yüksek",
            time: "14:30"
        },
        {
            id: "2",
            location: "İstiklal Sokak No:7",
            type: "Gürültü Şikayeti",
            priority: "Düşük",
            time: "14:45"
        }
    ],
    wanted: [
        {
            id: "12345678901",
            name: "Mehmet Yılmaz",
            reason: "Silahlı Soygun",
            dangerLevel: "Yüksek",
            addedDate: "01.03.2024",
            addedBy: "John Doe #12345",
            img: "https://placekitten.com/102/102"
        },
        {
            id: "98765432102",
            name: "Ali Kaya",
            reason: "Dolandırıcılık",
            dangerLevel: "Orta",
            addedDate: "28.02.2024",
            addedBy: "John Doe #12345",
            img: "https://placekitten.com/103/103"
        }
    ]
};

// DOM elementleri
const searchInput = document.getElementById('searchInput');
const searchButton = document.getElementById('searchButton');
const resultContainer = document.getElementById('resultContainer');
const menuButtons = document.querySelectorAll('.menu-btn');

// Event listener'ları güncelle
document.addEventListener('DOMContentLoaded', () => {
    // Menü butonları için event listener
    menuButtons.forEach(button => {
        button.addEventListener('click', () => {
            closeAllForms();
            const section = button.dataset.section;
            switch(section) {
                case 'person':
                    showPersonSearch();
                    break;
                case 'criminal':
                    showCriminalAdd();
                    break;
                case 'vehicle':
                    showVehicleSearch();
                    break;
                case 'wanted':
                    displayWanted();
                    break;
            }
        });
    });

    // Sabıka ekleme butonu
    document.getElementById('addCriminalBtn')?.addEventListener('click', addCriminal);

    // Kişi ekleme butonu
    document.getElementById('addPersonBtn')?.addEventListener('click', addPerson);

    // Aranan ekleme butonu
    document.getElementById('addWantedBtn')?.addEventListener('click', addWanted);
    
    // Resim URL'si değiştiğinde önizleme
    document.getElementById('personImg')?.addEventListener('input', (e) => {
        updateImagePreview(e.target.value);
    });

    // Aranan kişi resim URL'si değiştiğinde önizleme
    document.getElementById('wantedImg')?.addEventListener('input', (e) => {
        updateWantedImagePreview(e.target.value);
    });

    // Enter tuşu ile arama
    document.addEventListener('keyup', (e) => {
        if (e.target.id === 'personSearchInput' && e.key === 'Enter') {
            searchPerson();
        }
        if (e.target.id === 'vehicleSearchInput' && e.key === 'Enter') {
            searchVehicle();
        }
    });
});

// Event listener'ı güncelle
window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "show") {
        if (data.status) {
            document.body.style.display = "flex";
            document.querySelector('.user-info').innerHTML = `
                <span>Memur: ${data.officer}</span>
                <span>Rozet No: ${data.badge}</span>
            `;
        } else {
            document.body.style.display = "none";
        }
    }
});

// ESC tuşu ile kapatma
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

// Genel arama fonksiyonu
function performSearch(searchTerm) {
    // Kişi araması
    const person = database.persons.find(p => 
        p.id === searchTerm || 
        p.name.toLowerCase() === searchTerm.toLowerCase()
    );

    if (person) {
        displayPersonInfo(person);
        return;
    }

    // Araç araması
    const vehicle = database.vehicles.find(v => 
        v.plate.replace(/\s/g, '').toLowerCase() === searchTerm.replace(/\s/g, '').toLowerCase()
    );
    
    if (vehicle) {
        displayVehicleInfo(vehicle);
        return;
    }

    // Sonuç bulunamadı
    resultContainer.innerHTML = '<p class="error">Sonuç bulunamadı.</p>';
}

// Kişi bilgilerini detaylı görüntüleme
function displayPersonInfo(person) {
    resultContainer.innerHTML = `
        <div class="result-card">
            <div class="person-info">
                <img src="${person.img}" alt="Profil" class="profile-img">
                <div class="info-details">
                    <p><strong>Ad Soyad:</strong> <span>${person.name}</span></p>
                    <p><strong>CitizenID No:</strong> <span>${person.id}</span></p>
                    <p><strong>Doğum Tarihi:</strong> <span>${person.birthDate}</span></p>
                    <p><strong>Telefon:</strong> <span>${person.phone || 'Belirtilmemiş'}</span></p>
                    <p><strong>Adres:</strong> <span>${person.address || 'Belirtilmemiş'}</span></p>
                    <p><strong>Sabıka Kaydı:</strong> <span>${person.criminal.length ? person.criminal.join(', ') : 'Temiz'}</span></p>
                </div>
            </div>
            <button onclick="togglePersonForm('${person.id}')" class="edit-btn">Bilgileri Güncelle</button>
        </div>
    `;
}

// Araç bilgilerini görüntüleme
function displayVehicleInfo(vehicle) {
    resultContainer.innerHTML = `
        <div class="result-card">
            <div class="vehicle-info">
                <p><strong>Plaka:</strong> <span>${vehicle.plate}</span></p>
                <p><strong>Sahibi:</strong> <span>${vehicle.owner}</span></p>
                <p><strong>Model:</strong> <span>${vehicle.model}</span></p>
                <p><strong>Yıl:</strong> <span>${vehicle.year}</span></p>
                <p><strong>Durum:</strong> <span>${vehicle.status}</span></p>
            </div>
        </div>
    `;
}

// Tüm sabıkalıları görüntüleme
function displayAllCriminals() {
    const criminals = database.persons.filter(p => p.criminal.length > 0);
    const resultsDiv = document.getElementById('criminalResults') || resultContainer;
    
    if (criminals.length === 0) {
        resultsDiv.innerHTML = '<p class="info-message">Kayıtlı sabıka bulunmamaktadır.</p>';
        return;
    }

    resultsDiv.innerHTML = criminals.map(person => `
        <div class="result-card">
            <div class="person-info">
                <img src="${person.img}" alt="Profil" class="profile-img">
                <div class="info-details">
                    <p><strong>Ad Soyad:</strong> <span>${person.name}</span></p>
                    <p><strong>CitizenIDNo:</strong> <span>${person.id}</span></p>
                    <p><strong>Sabıka Kayıtları:</strong></p>
                    <ul class="criminal-list">
                        ${person.criminal.map(crime => `<li>${crime}</li>`).join('')}
                    </ul>
                </div>
            </div>
            <button onclick="toggleCriminalForm('${person.id}')" class="add-btn">Yeni Sabıka Ekle</button>
        </div>
    `).join('');
}

// Tüm araçları görüntüleme
function displayAllVehicles() {
    resultContainer.innerHTML = `
        <h3>Araç Kayıtları</h3>
        ${database.vehicles.map(vehicle => `
            <div class="result-card">
                <div class="vehicle-info">
                    <p><strong>Plaka:</strong> <span>${vehicle.plate}</span></p>
                    <p><strong>Sahibi:</strong> <span>${vehicle.owner}</span></p>
                    <p><strong>Model:</strong> <span>${vehicle.model} (${vehicle.year})</span></p>
                    <p><strong>Durum:</strong> <span>${vehicle.status}</span></p>
                </div>
            </div>
        `).join('')}
    `;
}

// Arananlar listesini göster
function displayWanted() {
    resultContainer.innerHTML = `
        <div class="search-card">
            <h3>Arananlar Listesi</h3>
            <button onclick="toggleWantedForm()" class="add-new-btn">
                <span>+</span> Yeni Aranan Ekle
            </button>
        </div>
        <div id="wantedResults"></div>
    `;

    // Arananlar listesini getir
    fetch(`https://${GetParentResourceName()}/getWantedList`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(resp => resp.json())
    .then(wanted => {
        const wantedResults = document.getElementById('wantedResults');
        
        if (!wanted || wanted.length === 0) {
            wantedResults.innerHTML = '<p class="info-message">Aranan kişi bulunmuyor.</p>';
            return;
        }

        wantedResults.innerHTML = wanted.map(person => `
            <div class="result-card wanted-person">
                <div class="person-info">
                    <img src="${person.img_url || "https://cdn.discordapp.com/attachments/1116791667584417894/1217422386715811850/unknown.png?ex=66033e6c&is=65f0c96c&hm=c3f18134d3d8b6b6d6c6dc3ea35e75d0d1f6acd6f4ed95e0e67a8cc6f0e1b6e4&"}" alt="Aranan" class="profile-img">
                    <div class="info-details">
                        <h3>${person.person_name || 'İsim Bilinmiyor'}</h3>
                        <p><strong>CitizenID:</strong> <span>${person.citizenid}</span></p>
                        <p><strong>Aranma Sebebi:</strong> <span>${person.reason}</span></p>
                        <p><strong>Tehlike Seviyesi:</strong> <span class="danger-level danger-level-${person.danger_level?.toLowerCase()}">${person.danger_level}</span></p>
                        <p><strong>Ekleyen:</strong> <span class="officer-info">${person.added_by}</span></p>
                        <p><strong>Eklenme Tarihi:</strong> <span>${formatDate(person.added_date)}</span></p>
                    </div>
                </div>
                <div class="action-buttons">
                    <button onclick="removeWanted('${person.citizenid}')" class="remove-btn">Arananlardan Kaldır</button>
                </div>
            </div>
        `).join('');
    })
    .catch(error => {
        console.error('Arananlar listesi alınırken hata:', error);
        document.getElementById('wantedResults').innerHTML = '<p class="error">Arananlar listesi alınırken bir hata oluştu.</p>';
    });
}

// Arananlar formunu göster/gizle
function toggleWantedForm() {
    const form = document.getElementById('wantedAddForm');
    form.style.display = form.style.display === 'none' ? 'block' : 'none';
}

// Yeni aranan ekle
function addWanted() {
    const citizenid = document.getElementById('wantedCitizenId').value;
    const reason = document.getElementById('wantedReason').value;
    const dangerLevel = document.getElementById('wantedDanger').value;
    const img = document.getElementById('wantedImg').value;

    if (!citizenid || !reason || !dangerLevel) {
        alert('Lütfen gerekli alanları doldurun!');
        return;
    }

    fetch(`https://${GetParentResourceName()}/addWanted`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            citizenid: citizenid,
            reason: reason,
            dangerLevel: dangerLevel,
            img: img || "https://cdn.discordapp.com/attachments/1116791667584417894/1217422386715811850/unknown.png?ex=66033e6c&is=65f0c96c&hm=c3f18134d3d8b6b6d6c6dc3ea35e75d0d1f6acd6f4ed95e0e67a8cc6f0e1b6e4&"
        })
    }).then(() => {
        toggleWantedForm();
        clearWantedForm();
        displayWanted(); // Listeyi güncelle
    });
}

// Arananlardan kaldır
function removeWanted(citizenid) {
    showModal(
        'Arananlardan Kaldır',
        'Bu kişiyi arananlardan kaldırmak istediğinize emin misiniz?',
        (confirmed) => {
            if (confirmed) {
                fetch(`https://${GetParentResourceName()}/removeWanted`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        citizenid: citizenid
                    })
                }).then(() => {
                    displayWanted(); // Listeyi güncelle
                });
            }
        }
    );
}

// Aranan form temizle
function clearWantedForm() {
    document.getElementById('wantedCitizenId').value = '';
    document.getElementById('wantedReason').value = '';
    document.getElementById('wantedDanger').value = '';
    document.getElementById('wantedImg').value = '';
    document.getElementById('wantedImagePreview').innerHTML = '';
}

// Tarih formatla
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('tr-TR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Kişi bilgisi güncelleme formunu göster
function togglePersonForm(personId = null) {
    const form = document.getElementById('personAddForm');
    form.style.display = form.style.display === 'none' ? 'block' : 'none';

    if (personId) {
        const person = database.persons.find(p => p.id === personId);
        if (person) {
            // Sadece adres ve profil resmi güncellenebilir
            document.getElementById('personAddress').value = person.address || '';
            document.getElementById('personImg').value = person.img;
            document.getElementById('personCitizenId').value = person.id;
            document.getElementById('personCitizenId').disabled = true;
            
            // Diğer alanları gizle veya devre dışı bırak
            document.getElementById('personName').style.display = 'none';
            document.getElementById('personPhone').style.display = 'none';
            document.getElementById('personBirthDate').style.display = 'none';
            
            updateImagePreview(person.img);
        }
    }
}

// Kişi bilgisi güncelle
function updatePerson() {
    const citizenid = document.getElementById('personCitizenId').value;
    const address = document.getElementById('personAddress').value;
    const img = document.getElementById('personImg').value;

    fetch(`https://${GetParentResourceName()}/updatePerson`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            citizenid: citizenid,
            address: address,
            img: img
        })
    }).then(() => {
        togglePersonForm();
        // Kişiyi tekrar ara ve bilgileri güncelle
        searchPerson();
    });
}

// Resim önizleme
function updateImagePreview(url) {
    const preview = document.getElementById('imagePreview');
    if (url) {
        preview.innerHTML = `<img src="${url}" alt="Önizleme" class="preview-img">`;
    } else {
        preview.innerHTML = '';
    }
}

// Kişi bilgisi ekle/güncelle
function addPerson() {
    const name = document.getElementById('personName').value;
    const CitizenID= document.getElementById('personTc').value;
    const phone = document.getElementById('personPhone').value;
    const birthDate = document.getElementById('personBirthDate').value;
    const address = document.getElementById('personAddress').value;
    const img = document.getElementById('personImg').value;

    if (!name || !CitizenID|| !birthDate) {
        alert('Ad Soyad, CitizenIDNo ve Doğum Tarihi zorunludur!');
        return;
    }

    const existingPersonIndex = database.persons.findIndex(p => p.id === tc);
    const newPerson = {
        id: tc,
        name: name,
        birthDate: birthDate,
        phone: phone,
        address: address,
        img: img || "https://placekitten.com/100/100",
        criminal: existingPersonIndex >= 0 ? database.persons[existingPersonIndex].criminal : []
    };

    if (existingPersonIndex >= 0) {
        database.persons[existingPersonIndex] = newPerson;
    } else {
        database.persons.push(newPerson);
    }

    displayPersonInfo(newPerson);
    togglePersonForm();
    clearPersonForm();
}

// Sabıka ekleme arayüzünü göster
function showCriminalAdd() {
    resultContainer.innerHTML = `
        <div class="search-card">
            <h3>Sabıka İşlemleri</h3>
            <div class="search-options">
                <input type="text" id="criminalSearchInput" placeholder="CitizenID veya Ad Soyad ile ara">
                <button onclick="searchPersonForCriminal()" class="search-btn">Kişi Ara</button>
            </div>
        </div>
        <div id="criminalResults"></div>
    `;
}

// Sabıka için kişi arama
function searchPersonForCriminal() {
    const searchTerm = document.getElementById('criminalSearchInput').value.trim();
    if (searchTerm.length < 3) {
        document.getElementById('criminalResults').innerHTML = '<p class="error">En az 3 karakter girmelisiniz.</p>';
        return;
    }

    fetch(`https://${GetParentResourceName()}/searchPerson`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            searchTerm: searchTerm
        })
    })
    .then(resp => resp.json())
    .then(results => {
        const resultsContainer = document.getElementById('criminalResults');
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<p class="error">Sonuç bulunamadı.</p>';
            return;
        }

        resultsContainer.innerHTML = results.map(person => `
            <div class="result-card">
                <div class="person-info">
                    <img src="${person.img}" alt="Profil" class="profile-img">
                    <div class="info-details">
                        <p><strong>Ad Soyad:</strong> <span>${person.name}</span></p>
                        <p><strong>CitizenID:</strong> <span>${person.id}</span></p>
                        <p><strong>Sabıka Kaydı:</strong> <span>${person.criminal.length ? person.criminal.join(', ') : 'Temiz'}</span></p>
                    </div>
                </div>
                <div class="action-buttons">
                    <button onclick="toggleCriminalForm('${person.id}')" class="add-btn">Sabıka Ekle</button>
                </div>
            </div>
        `).join('');
    });
}

// Sabıka ekleme formunu göster/gizle
function toggleCriminalForm(citizenid = null) {
    const form = document.getElementById('criminalAddForm');
    if (!form) return; // Form yoksa işlemi durdur

    form.style.display = form.style.display === 'none' ? 'block' : 'none';

    if (citizenid) {
        fetch(`https://${GetParentResourceName()}/searchPerson`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ searchTerm: citizenid })
        })
        .then(resp => resp.json())
        .then(results => {
            if (results.length > 0) {
                const person = results[0];
                document.getElementById('criminalName').value = person.name;
                document.getElementById('criminalCitizenId').value = person.id;
                document.getElementById('criminalDate').value = new Date().toLocaleDateString('tr-TR');
            }
        });
    }
}

// Sabıka ekle
function addCriminal() {
    const name = document.getElementById('criminalName').value;
    const citizenid = document.getElementById('criminalCitizenId').value;
    const reason = document.getElementById('criminalReason').value;
    const date = document.getElementById('criminalDate').value;

    if (!citizenid || !reason || !date) {
        alert('Lütfen tüm alanları doldurun!');
        return;
    }

    fetch(`https://${GetParentResourceName()}/addCriminal`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            citizenid: citizenid,
            reason: reason,
            date: date
        })
    }).then(() => {
        toggleCriminalForm();
        clearCriminalForm();
        // Kişiyi tekrar ara ve bilgileri güncelle
        searchPerson();
    });
}

// Form temizleme fonksiyonları
function clearPersonForm() {
    document.getElementById('personName').value = '';
    document.getElementById('personTc').value = '';
    document.getElementById('personPhone').value = '';
    document.getElementById('personBirthDate').value = '';
    document.getElementById('personAddress').value = '';
    document.getElementById('personImg').value = '';
    document.getElementById('imagePreview').innerHTML = '';
}

function clearCriminalForm() {
    document.getElementById('criminalName').value = '';
    document.getElementById('criminalCitizenId').value = '';
    document.getElementById('criminalReason').value = '';
    document.getElementById('criminalDate').value = '';
}

// Kişi sorgulama arayüzünü göster
function showPersonSearch() {
    resultContainer.innerHTML = `
        <div class="search-card">
            <h3>Kişi Sorgula</h3>
            <div class="search-options">
                <input type="text" id="personSearchInput" placeholder="CitizenIDNo veya Ad Soyad ile ara">
                <button onclick="searchPerson()" class="search-btn">Ara</button>
            </div>
        </div>
        <div id="personSearchResults"></div>
    `;
}

// Kişi arama fonksiyonu
function searchPerson() {
    const searchTerm = document.getElementById('personSearchInput').value.trim();
    if (searchTerm.length < 3) {
        const resultsContainer = document.getElementById('personSearchResults');
        resultsContainer.innerHTML = '<p class="error">En az 3 karakter girmelisiniz.</p>';
        return;
    }

    fetch(`https://${GetParentResourceName()}/searchPerson`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            searchTerm: searchTerm
        })
    })
    .then(resp => resp.json())
    .then(results => {
        const resultsContainer = document.getElementById('personSearchResults');
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<p class="error">Sonuç bulunamadı.</p>';
            return;
        }

        resultsContainer.innerHTML = results.map(person => `
            <div class="result-card">
                <div class="person-info">
                    <img src="${person.img}" alt="Profil" class="profile-img">
                    <div class="info-details">
                        <p><strong>Ad Soyad:</strong> <span>${person.name}</span></p>
                        <p><strong>CitizenID:</strong> <span>${person.id}</span></p>
                        <p><strong>Doğum Tarihi:</strong> <span>${person.birthDate}</span></p>
                        <p><strong>Telefon:</strong> <span>${person.phone || 'Belirtilmemiş'}</span></p>
                        <p><strong>Adres:</strong> <span>${person.address || 'Belirtilmemiş'}</span></p>
                        <p><strong>Sabıka Kaydı:</strong></p>
                        <div class="criminal-records">
                            ${displayCriminalRecords(person.criminal)}
                        </div>
                    </div>
                </div>
                <div class="action-buttons">
                    <button onclick="editPersonImage('${person.id}')" class="edit-btn">Fotoğraf Güncelle</button>
                    <button onclick="toggleCriminalForm('${person.id}')" class="add-btn">Sabıka Ekle</button>
                </div>
            </div>
        `).join('');
    });
}

// Kişi fotoğrafını güncelle
function editPersonImage(id) {
    showModal(
        'Fotoğraf URL Güncelle',
        'Yeni fotoğraf URL\'sini girin',
        (newImg) => {
            if (newImg.trim() !== '') {
                fetch(`https://${GetParentResourceName()}/updatePerson`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        citizenid: id,
                        img: newImg,
                        type: 'image' // Sadece fotoğraf güncellemesi olduğunu belirt
                    })
                }).then(() => {
                    // Kişiyi tekrar ara ve bilgileri güncelle
                    const searchTerm = document.getElementById('personSearchInput').value.trim();
                    if (searchTerm) {
                        searchPerson(); // Aramayı yenile
                    }
                });
            }
        }
    );
}

// Aranan kişi fotoğrafını güncelle
function editWantedImage(id) {
    showModal(
        'Fotoğraf URL Güncelle',
        'Yeni fotoğraf URL\'sini girin',
        (newImg) => {
            if (newImg.trim() !== '') {
                const person = database.wanted.find(p => p.id === id);
                if (person) {
                    person.img = newImg;
                    displayWanted();
                }
            }
        }
    );
}

// Tüm formları kapat
function closeAllForms() {
    const forms = [
        'criminalAddForm',
        'personAddForm',
        'wantedAddForm'
    ];
    
    forms.forEach(formId => {
        const form = document.getElementById(formId);
        if (form) {
            form.style.display = 'none';
        }
    });

    // Sonuç containerını temizle
    const resultContainer = document.getElementById('resultContainer');
    if (resultContainer) {
        resultContainer.innerHTML = '';
    }
}

// Modal fonksiyonları
function showModal(title, inputPlaceholder = '', confirmCallback) {
    const modal = document.getElementById('customModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalInput = document.getElementById('modalInput');
    const confirmBtn = document.getElementById('modalConfirm');
    const cancelBtn = document.getElementById('modalCancel');

    modalTitle.textContent = title;
    if (inputPlaceholder) {
        modalInput.style.display = 'block';
        modalInput.placeholder = inputPlaceholder;
        modalInput.value = '';
    } else {
        modalInput.style.display = 'none';
    }

    modal.style.display = 'flex';

    // Event listeners
    const handleConfirm = () => {
        const value = inputPlaceholder ? modalInput.value : true;
        confirmCallback(value);
        closeModal();
    };

    const handleCancel = () => {
        closeModal();
    };

    confirmBtn.onclick = handleConfirm;
    cancelBtn.onclick = handleCancel;

    // Enter tuşu ile onaylama
    modalInput.onkeypress = (e) => {
        if (e.key === 'Enter') handleConfirm();
    };
}

function closeModal() {
    const modal = document.getElementById('customModal');
    modal.style.display = 'none';
}

// Araç arama arayüzünü göster
function showVehicleSearch() {
    resultContainer.innerHTML = `
        <div class="search-card">
            <h3>Araç Sorgula</h3>
            <div class="search-options">
                <input type="text" id="vehicleSearchInput" placeholder="Plaka veya Sahip Adı ile ara">
                <button onclick="searchVehicle()" class="search-btn">Ara</button>
            </div>
        </div>
        <div id="vehicleSearchResults"></div>
    `;
}

// Araç arama fonksiyonu
function searchVehicle() {
    const searchTerm = document.getElementById('vehicleSearchInput').value.trim();
    if (searchTerm.length < 2) {
        const resultsContainer = document.getElementById('vehicleSearchResults');
        resultsContainer.innerHTML = '<p class="error">En az 2 karakter girmelisiniz.</p>';
        return;
    }

    fetch(`https://${GetParentResourceName()}/searchVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            searchTerm: searchTerm
        })
    })
    .then(resp => resp.json())
    .then(results => {
        const resultsContainer = document.getElementById('vehicleSearchResults');
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<p class="error">Sonuç bulunamadı.</p>';
            return;
        }

        resultsContainer.innerHTML = results.map(vehicle => `
            <div class="result-card">
                <div class="vehicle-info">
                    <div class="info-details">
                        <h3>${vehicle.vehicle.brand} ${vehicle.vehicle.name}</h3>
                        <p><strong>Plaka:</strong> <span>${vehicle.plate}</span></p>
                        <p><strong>Model:</strong> <span>${vehicle.vehicle.model}</span></p>
                        <p><strong>Durum:</strong> <span>${getVehicleState(vehicle.vehicle.state)}</span></p>
                        <div class="owner-info">
                            <h4>Araç Sahibi Bilgileri:</h4>
                            <p><strong>Ad Soyad:</strong> <span>${vehicle.owner.name}</span></p>
                            <p><strong>Telefon:</strong> <span>${vehicle.owner.phone}</span></p>
                            <p><strong>CitizenID:</strong> <span>${vehicle.owner.citizenid}</span></p>
                        </div>
                    </div>
                </div>
            </div>
        `).join('');
    });
}

// Araç durumunu Türkçe olarak göster
function getVehicleState(state) {
    const states = {
        'garage': 'Garajda',
        'out': 'Dışarıda',
        'impound': 'Çekilmiş',
        'unknown': 'Bilinmiyor'
    };
    return states[state] || 'Bilinmiyor';
}

// Sabıka kayıtlarını göster
function displayCriminalRecords(records) {
    if (!records || records.length === 0) return 'Temiz';
    
    return records.map(record => `
        <div class="criminal-record">
            <div class="criminal-record-content">
                <p><strong>Suç:</strong> ${record.offense}</p>
                <p><strong>Tarih:</strong> ${record.date}</p>
                <p><strong>Memur:</strong> ${record.officer}</p>
            </div>
            <div class="criminal-record-actions">
                <button onclick="removeCriminalRecord('${record.id}', '${record.citizenid}')" class="remove-btn">Sabıkayı Sil</button>
            </div>
        </div>
    `).join('');
}

// Sabıka kaydını sil
function removeCriminalRecord(recordId, citizenid) {
    showModal(
        'Sabıka Kaydını Sil',
        'Bu sabıka kaydını silmek istediğinize emin misiniz?',
        (confirmed) => {
            if (confirmed) {
                fetch(`https://${GetParentResourceName()}/removeCriminal`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        recordId: recordId,
                        citizenid: citizenid
                    })
                }).then(() => {
                    // Kişiyi tekrar ara ve bilgileri güncelle
                    const searchTerm = document.getElementById('personSearchInput')?.value.trim() || 
                                     document.getElementById('criminalSearchInput')?.value.trim();
                    if (searchTerm) {
                        if (document.getElementById('personSearchInput')) {
                            searchPerson();
                        } else {
                            searchPersonForCriminal();
                        }
                    }
                });
            }
        }
    );
} 