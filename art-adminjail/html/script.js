let jailTimer = null;  

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === "showJailTimer") {
        if (jailTimer) {
            clearInterval(jailTimer);
        }

        document.getElementById("jail-ui").style.display = "block";


        document.getElementById("jail-timer").innerText = formatTime(data.time);
        document.getElementById("jail-reason").innerText = "Reason: " + data.reason;

      
        jailTimer = setInterval(() => {
            data.time -= 1; 
            document.getElementById("jail-timer").innerText = formatTime(data.time);

            if (data.time <= 0) {
                clearInterval(jailTimer);  
                SendNUIMessage({ type: "hideJailTimer" });  
            }
        }, 1000);  
    }

    if (data.type === "updateJailTimer") {
       
        document.getElementById("jail-timer").innerText = formatTime(data.time);
    }

    if (data.type === "hideJailTimer") {
       
        document.getElementById("jail-ui").style.display = "none";
        clearInterval(jailTimer);
    }
});


function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs < 10 ? "0" + secs : secs}`;
}
