let isWorking = false;
let currentDelivery = null;
let totalEarnings = 0; // Toplam kazanç
let isDelivering = false; // Siparişin teslim aşamasını takip etmek için
let locations = {};
let deliveryTimer = null; // Teslimat zamanlayıcısı
let timeLeft = 0; // Kalan süre


fetch(`https://${GetParentResourceName()}/getLocations`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
}).then(resp => resp.json()).then(data => {
    locations = data;
});

document.addEventListener('DOMContentLoaded', function() {
    document.querySelector('.container').style.display = 'none';
    
    const startJobBtn = document.getElementById('startJob');
    const endJobBtn = document.getElementById('endJob');
    const ordersList = document.getElementById('ordersList');
    const completeDeliveryBtn = document.getElementById('completeDelivery');

    startJobBtn.addEventListener('click', () => {
        isWorking = true;
        startJobBtn.disabled = true;
        endJobBtn.disabled = false;
        document.getElementById('earnings').textContent = '0';
        generateOrders();
        fetch(`https://${GetParentResourceName()}/startJob`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    });

    endJobBtn.addEventListener('click', () => {
        isWorking = false;
        startJobBtn.disabled = false;
        endJobBtn.disabled = true;
        ordersList.innerHTML = '';
        document.querySelector('.active-delivery').style.display = 'none';
        
       
        if (deliveryTimer) {
            clearInterval(deliveryTimer);
            deliveryTimer = null;
        }
        
        
        fetch(`https://${GetParentResourceName()}/stopTimer`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });

        
        currentDelivery = null;
        isDelivering = false;
        
        
        document.getElementById('earnings').textContent = totalEarnings;
        
        
        fetch(`https://${GetParentResourceName()}/endJob`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({totalEarnings: totalEarnings})
        });
        
        
        totalEarnings = 0;
    });

    completeDeliveryBtn.addEventListener('click', () => {
        if (currentDelivery && !isDelivering) {
            deliverOrder(currentDelivery);
        } else if (currentDelivery && isDelivering) {
            completeDelivery(currentDelivery);
        }
    });
});

function generateOrders() {
    if (!isWorking) return; // Meslek aktif değilse sipariş oluşturma
    if (currentDelivery) return; // Aktif sipariş varsa yeni sipariş oluşturma
    
    const locationNames = Object.keys(locations);
    const selectedLocationKey = locationNames[Math.floor(Math.random() * locationNames.length)];
    const selectedLocation = locations[selectedLocationKey];
    
    const locationPoints = selectedLocation.points;
    const selectedPoint = locationPoints[Math.floor(Math.random() * locationPoints.length)];

    const order = {
        id: Math.floor(Math.random() * 1000),
        customer: `Müşteri #${Math.floor(Math.random() * 100)}`,
        locationKey: selectedLocationKey,
        location: selectedLocation.label,
        coordinates: selectedPoint,
        price: Math.floor(Math.random() * 100) + 50
    };

    addOrderToList(order);
}

function addOrderToList(order) {
    const ordersList = document.getElementById('ordersList');
    const orderElement = document.createElement('div');
    orderElement.className = 'order-item';
    orderElement.innerHTML = `
        <div class="order-info">
            <div>${order.customer}</div>
            <div><i class="fas fa-map-marker-alt"></i> ${order.location}</div>
            <div><i class="fas fa-money-bill-wave"></i> ${order.price}₺</div>
        </div>
        <div class="order-actions">
            <button onclick="acceptOrder('${order.locationKey}', ${order.id})">Siparişi Al</button>
        </div>
    `;
    ordersList.appendChild(orderElement);
}

function acceptOrder(locationKey, orderId) {
    const orderElement = document.querySelector(`[onclick="acceptOrder('${locationKey}', ${orderId})"]`).parentNode.parentNode;
    
    if (!locations[locationKey]) {
        console.error('Location not found:', locationKey);
        return;
    }

    const points = locations[locationKey].points;
    const selectedPoint = points[Math.floor(Math.random() * points.length)];

    const orderInfo = {
        id: orderId,
        customer: orderElement.querySelector('.order-info div').textContent,
        location: locations[locationKey].label,
        coordinates: selectedPoint,
        price: parseInt(orderElement.querySelector('.order-info div:nth-child(3)').textContent.replace('₺', '')),
        startTime: Date.now()
    };

    currentDelivery = orderInfo;
    orderElement.remove();
    showActiveDelivery(orderInfo);
    startDeliveryTimer();

    fetch(`https://${GetParentResourceName()}/acceptOrder`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(orderInfo)
    });
}

function showActiveDelivery(order) {
    const activeDelivery = document.querySelector('.active-delivery');
    activeDelivery.style.display = 'block';
    document.getElementById('customerName').textContent = order.customer;
    document.getElementById('deliveryAddress').textContent = order.location;
    document.getElementById('orderPrice').textContent = `${order.price}₺`;
    
    
    const completeBtn = document.getElementById('completeDelivery');
    completeBtn.textContent = 'Siparişi Ver';
    completeBtn.className = 'complete-btn disabled';
    completeBtn.disabled = true;
}

function deliverOrder(order) {
    isDelivering = true;
    const completeBtn = document.getElementById('completeDelivery');
    completeBtn.textContent = 'Siparişi Tamamla';
    completeBtn.className = 'complete-btn delivered';

    
    fetch(`https://${GetParentResourceName()}/deliverOrder`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(order)
    });
}

function startDeliveryTimer() {
    if (deliveryTimer) clearInterval(deliveryTimer);
    
    timeLeft = 300; // 5 dakika (Config'den alınacak)
    updateTimerDisplay();

    
    fetch(`https://${GetParentResourceName()}/startTimer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });

    deliveryTimer = setInterval(() => {
        timeLeft--;
        updateTimerDisplay();

        if (timeLeft <= 0) {
            clearInterval(deliveryTimer);
            failDelivery();
        }
    }, 1000);
}

function updateTimerDisplay() {
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    const timeString = `${minutes}:${seconds.toString().padStart(2, '0')}`;
    
    
    document.getElementById('deliveryTimer').textContent = timeString;
    
    
    fetch(`https://${GetParentResourceName()}/updateTimer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ time: timeString })
    });

   
    if (timeLeft <= 30) {
        document.getElementById('deliveryTimer').classList.add('warning');
    }
}

function failDelivery() {
    clearInterval(deliveryTimer);
    
    
    fetch(`https://${GetParentResourceName()}/stopTimer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    
    
    document.querySelector('.active-delivery').style.display = 'none';
    currentDelivery = null;
    isDelivering = false;

    
    fetch(`https://${GetParentResourceName()}/failDelivery`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });

    
    setTimeout(generateOrders, 2000);
}

function completeDelivery(order) {
    clearInterval(deliveryTimer);
    
    
    fetch(`https://${GetParentResourceName()}/stopTimer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    
    const earnings = document.getElementById('earnings');
    const currentEarnings = parseInt(earnings.textContent);
    earnings.textContent = currentEarnings + order.price;
    
    totalEarnings += order.price;

    document.querySelector('.active-delivery').style.display = 'none';
    currentDelivery = null;
    isDelivering = false;

    setTimeout(generateOrders, 2000);

    fetch(`https://${GetParentResourceName()}/completeDelivery`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(order)
    });
}


function onDeliveredToNPC() {
    if (currentDelivery) {
        isDelivering = true;
        const completeBtn = document.getElementById('completeDelivery');
        completeBtn.textContent = 'Siparişi Tamamla';
        completeBtn.className = 'complete-btn delivered';
        completeBtn.disabled = false;
    }
}


window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'showUI') {
        document.querySelector('.container').style.display = 'flex';
    } else if (data.type === 'hideUI') {
        document.querySelector('.container').style.display = 'none';
    } else if (data.type === 'deliveredToNPC') {
        onDeliveredToNPC();
    }
});


document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        }).then(() => {
            document.querySelector('.container').style.display = 'none';
        });
    }
}); 