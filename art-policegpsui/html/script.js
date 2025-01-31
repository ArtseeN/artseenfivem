let isGPSOpen = false;

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type === 'openGPS') {
            $('#gps-container').fadeIn();
            isGPSOpen = true;
        } else if (event.data.type === 'updateGPSList') {
            updateGPSList(event.data.list);
        }
    });

    // Ana menü butonları
    $('#close-button').click(closeGPS);
    $('#activate-gps').click(activateGPS);
    $('#check-gps').click(openGPSList);
    $('#remove-gps').click(openRemoveGPS);

    // Modal kapatma butonları
    $('.close-modal').click(function() {
        $(this).closest('.modal').fadeOut();
    });

    // GPS Kaldır onaylama
    $('#confirm-remove').click(removeGPS);

    // ESC tuşu ile kapatma
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('.modal:visible').length) {
                $('.modal').fadeOut();
            } else if (isGPSOpen) {
                closeGPS();
            }
        }
    });
});

function activateGPS() {
    const code = $('#gps-code').val();
    if (code.trim() === '') {
        return;
    }
    $.post(`https://${GetParentResourceName()}/activateGPS`, JSON.stringify({
        code: code
    }));
    closeGPS();
}

function openGPSList() {
    $.post(`https://${GetParentResourceName()}/requestGPSList`);
    $('#gps-list-modal').fadeIn();
}

function updateGPSList(list) {
    const container = $('#gps-list');
    container.empty();
    
    Object.entries(list).forEach(([code, data]) => {
        container.append(`
            <div class="gps-item">
                <strong>Kod:</strong> ${code}<br>
                <strong>Model:</strong> ${data.model}<br>
                <strong>Plaka:</strong> ${data.plate}<br>
                <strong>Memur:</strong> ${data.officerName}<br>
                <strong>Departman:</strong> ${data.job}
            </div>
        `);
    });
}

function openRemoveGPS() {
    $('#remove-gps-modal').fadeIn();
}

function removeGPS() {
    const code = $('#remove-code').val();
    if (code.trim() === '') {
        return;
    }
    $.post(`https://${GetParentResourceName()}/removeGPS`, JSON.stringify({
        code: code
    }));
    $('#remove-code').val('');
    $('#remove-gps-modal').fadeOut();
}

function closeGPS() {
    $('#gps-container').fadeOut();
    $('.modal').fadeOut();
    isGPSOpen = false;
    $.post(`https://${GetParentResourceName()}/closeGPS`, JSON.stringify({}));
} 