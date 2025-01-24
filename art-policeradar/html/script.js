window.addEventListener('message', (event) => {
    if (event.data.action === 'toggleRadar') {
        const radar = document.getElementById('radar-ui');
        radar.style.display = event.data.visible ? 'block' : 'none';
        if (event.data.visible) {
            radar.style.top = `${event.data.y * window.innerHeight}px`;
            radar.style.left = `${event.data.x * window.innerWidth}px`;
        }
    } else if (event.data.action === 'updateRadar') {
        document.getElementById('speed').textContent = `Hız: ${event.data.speed}`;
        document.getElementById('owner').textContent = `Sahip: ${event.data.owner}`;
        document.getElementById('plate').textContent = `Plaka: ${event.data.plate}`;
        document.getElementById('color').textContent = `Renk: ${event.data.color}`;
        document.getElementById('model').textContent = `Model: ${event.data.model}`;
    }
});
