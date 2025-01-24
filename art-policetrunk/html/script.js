window.addEventListener('message', function (event) {
    if (event.data.action === "openUI") {
        document.getElementById("trunk-ui").style.display = "block"; // UI'yi aç
    } else if (event.data.action === "closeUI") {
        document.getElementById("trunk-ui").style.display = "none"; // UI'yi kapat
    }
});

function closeUI() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
    });
}

function takeWeapon(weapon) {
    fetch(`https://${GetParentResourceName()}/takeWeapon`, {
        method: 'POST',
        body: JSON.stringify({ weapon: weapon }),
    });
}

function dropWeapon(weapon) {
    fetch(`https://${GetParentResourceName()}/dropWeapon`, {
        method: 'POST',
        body: JSON.stringify({ weapon: weapon }),
    });
}
