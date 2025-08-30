$(function() {
    let isAdmin = false;
    
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === 'openUI') {
            isAdmin = data.isAdmin;
            $('body').show().css('display', 'flex');
            
            if (data.lockerName) {
                $('#locker-title').text(data.lockerName);
            }
            
            if (isAdmin) {
                $('#officers-locker-btn').show();
            } else {
                $('#officers-locker-btn').hide();
            }
            
            resetUI();
        } else if (data.action === 'closeUI') {
            $('body').hide();
            resetUI();
        } else if (data.action === 'setOfficers') {
            displayOfficers(data.officers);
        }
    });
    
    $(document).on('click', '#close-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        closeUI();
    });
    
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            closeUI();
        }
    });
    
    $(document).on('click', '#personal-locker-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        $('.option-btn').removeClass('active');
        $(this).addClass('active');
        $('#officers-list').hide();
        
        $.post('https://lfLockers/openPersonalLocker', JSON.stringify({}));
    });
    
    $(document).on('click', '#officers-locker-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        if (!isAdmin) return;
        
        $('.option-btn').removeClass('active');
        $(this).addClass('active');
        $('#officers-list').show();
        
        $.post('https://lfLockers/getJobOfficers', JSON.stringify({}));
    });
    
    function displayOfficers(officers) {
        const container = $('#officers-container');
        container.empty();
        
        if (officers.length === 0) {
            container.html('<div class="empty-message">Aucun employé trouvé.</div>');
            return;
        }
        
        officers.sort((a, b) => {
            if (a.online && !b.online) return -1;
            if (!a.online && b.online) return 1;
            return 0;
        });
        
        officers.forEach(officer => {
            const statusClass = officer.online ? 'online' : 'offline';
            const statusIcon = officer.online ? 
                '<i class="fas fa-circle status-icon online"></i>' : 
                '<i class="fas fa-circle status-icon offline"></i>';
            
            const officerElement = `
                <div class="officer-item ${statusClass}" data-id="${officer.id}" data-online="${officer.online}">
                    <div class="officer-info">
                        <span class="officer-name">${statusIcon} ${officer.name}</span>
                        <span class="officer-grade">${officer.grade}</span>
                    </div>
                    <div class="officer-actions">
                        <button class="open-locker-btn"><i class="fas fa-unlock"></i> Ouvrir</button>
                    </div>
                </div>
            `;
            
            container.append(officerElement);
        });
        
        $(document).on('click', '.open-locker-btn', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const officerElement = $(this).closest('.officer-item');
            const officerId = officerElement.data('id');
            
            $.post('https://lfLockers/showNotification', JSON.stringify({
                message: 'Vous consultez un casier'
            }));
            
            openOfficerLocker(officerId);
        });
    }
    
    function openOfficerLocker(officerId) {
        $.post('https://lfLockers/openOfficerLocker', JSON.stringify({
            officerId: officerId
        }));
    }
    
    function closeUI() {
        $.post('https://lfLockers/closeUI', JSON.stringify({}));
        resetUI();
    }
    
    function resetUI() {
        $('.option-btn').removeClass('active');
        $('#personal-locker-btn').addClass('active');
        $('#officers-list').hide();
        $('#officers-container').empty();
        $('#locker-title').text('Casiers');
    }
    
    $('#locker-container').css('opacity', 0).animate({
        opacity: 1
    }, 300);
}); 
