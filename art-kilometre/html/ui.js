window.addEventListener('message', function(event) {
    if (event.data.type === "updateMileage") {
        document.getElementById("vehicleMileage").textContent = "Mileage: " + event.data.mileage;
    }

    // UI'yi göster veya gizle
    if (event.data.type === "showUI") {
        document.getElementById("mileageBox").style.display = "block";
    } else if (event.data.type === "hideUI") {
        document.getElementById("mileageBox").style.display = "none";
    }
});
