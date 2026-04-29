async function loadSection(sectionId) {
    const section = document.getElementById(sectionId);

    if (section.innerHTML.trim() === "") {
        try {
            const response = await fetch(`partials/${sectionId === 'contacts' ? 'contact' : sectionId}.html`);
            const data = await response.text();
            section.innerHTML = data;
        } catch (error) {
            console.error('Błąd ładowania sekcji:', error);
            section.innerHTML = "<p>Nie udało się załadować treści.</p>";
        }
    }
}

function showSection(event, sectionId, pushState = true) {
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => section.classList.remove('active'));

    const buttons = document.querySelectorAll('.nav-btn');
    buttons.forEach(btn => btn.classList.remove('active'));

    if (document.getElementById('game-container')) {
        closeGame(false);
    }

    loadSection(sectionId);

    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    }

    if (event && event.currentTarget) {
        event.currentTarget.classList.add('active');
    } else {
        const navBtn = document.querySelector(`.nav-btn[onclick*="${sectionId}"]`);
        if (navBtn) navBtn.classList.add('active');
    }

    if (pushState) {
        history.pushState({ sectionId: sectionId }, "", `?page=${sectionId}`);
    }
}

function openProject(fileRoute) {
    document.getElementById('projects-list').style.display = 'none';
    const container = document.getElementById('game-container');
    container.style.display = 'block';

    const gameFrame = document.getElementById('game-frame');

    const targetUrl = `partials/${fileRoute}`;
    if (gameFrame.contentWindow) {
        gameFrame.contentWindow.location.replace(targetUrl);
    } else {
        gameFrame.src = targetUrl;
    }

    history.pushState({ sectionId: 'projects', item: fileRoute }, "", `?page=projects&item=${fileRoute}`);
}

function closeGame(updateHistory = true) {
    const projectsList = document.getElementById('projects-list');
    const gameContainer = document.getElementById('game-container');

    if (projectsList && gameContainer) {
        projectsList.style.display = 'block';
        gameContainer.style.display = 'none';
        document.getElementById('game-frame').src = '';

        if (updateHistory) {
            history.pushState({ sectionId: 'projects' }, "", `?page=projects`);
        }
    }
}
window.addEventListener('load', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const page = urlParams.get('page');
    const item = urlParams.get('item');

    if (page) {
        showSection(null, page, false);

        if (page === 'projects' && item) {
            setTimeout(() => {
                openProject(item);
            }, 100);
        }
    } else {
        showSection(null, 'about', false);
    }
});

function fullscreenProject() {
    const frame = document.getElementById('game-frame');
    if (frame.requestFullscreen) {
        frame.requestFullscreen();
    } else if (frame.webkitRequestFullscreen) { /* Safari */
        frame.webkitRequestFullscreen();
    } else if (frame.msRequestFullscreen) { /* IE11 */
        frame.msRequestFullscreen();
    }
}

window.onpopstate = function(event) {
    if (document.getElementById('game-container').style.display === 'block') {
        closeGame(false);
    } else if (event.state && event.state.sectionId) {
        showSection(null, event.state.sectionId, false);
    } else {
        showSection(null, 'about', false);
    }
};


window.addEventListener('popstate', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const item = urlParams.get('item');

    if (event.state && event.state.sectionId) {
        showSection(null, event.state.sectionId, false);

        if (event.state.sectionId === 'projects' && item) {
            openProject(item);
        } else {
            closeGame(false);
        }
    } else {
        showSection(null, 'about', false);
    }
});


let currentIndex = 0;
let images = [];
document.addEventListener('DOMContentLoaded', () => {
    images = Array.from(document.querySelectorAll('.gallery img')).map(img => img.src);
});

function openLightbox(index) {
    currentIndex = index;
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');

    if (lightbox && lightboxImg) {
        lightbox.style.display = 'flex';
        lightboxImg.src = images[currentIndex];
        document.body.style.overflow = 'hidden'; // Blokuje scrollowanie strony pod spodem
    }
}

function closeLightbox() {
    const lightbox = document.getElementById('lightbox');
    if (lightbox) {
        lightbox.style.display = 'none';
        document.body.style.overflow = 'auto'; // Przywraca scrollowanie
    }
}

function changeImage(step) {
    if (images.length === 0) return;

    currentIndex += step;

    if (currentIndex >= images.length) currentIndex = 0;
    if (currentIndex < 0) currentIndex = images.length - 1;

    const lightboxImg = document.getElementById('lightbox-img');
    if (lightboxImg) {
        lightboxImg.src = images[currentIndex];
    }
}

document.addEventListener('keydown', (e) => {
    const lightbox = document.getElementById('lightbox');
    if (lightbox && lightbox.style.display === 'flex') {
        if (e.key === 'ArrowRight') changeImage(1);
        if (e.key === 'ArrowLeft') changeImage(-1);
        if (e.key === 'Escape') closeLightbox();
    }
});

function toggleFullscreen(containerId) {
    const container = document.getElementById(containerId);

    if (!document.fullscreenElement && !document.webkitFullscreenElement) {
        if (container.requestFullscreen) {
            container.requestFullscreen();
        } else if (container.webkitRequestFullscreen) {
            container.webkitRequestFullscreen();
        }
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
            document.webkitExitFullscreen();
        }
    }
}

function toggleLanguage() {
    const body = document.body;
    const btn = document.querySelector('.lang-toggle');

    body.classList.toggle('lang-en');

    if (body.classList.contains('lang-en')) {
        btn.innerText = 'PL';
        localStorage.setItem('selectedLang', 'en');
    } else {
        btn.innerText = 'EN';
        localStorage.setItem('selectedLang', 'pl');
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const savedLang = localStorage.getItem('selectedLang');
    const btn = document.querySelector('.lang-toggle');

    if (savedLang === 'en' && btn) {
        document.body.classList.add('lang-en');
        btn.innerText = 'PL';
    }
});

// ==========================================
// PRZYWRACANIE POZYCJI SCROLLA (UX)
// ==========================================

// 1. Zapisujemy pozycję scrolla w momencie kliknięcia w projekt
document.addEventListener('click', function(e) {
    // Sprawdzamy, czy kliknięty element znajduje się wewnątrz linku do projektu
    if (e.target.closest('.card-link')) {
        sessionStorage.setItem('scrollPosition', window.scrollY);
    }
});

window.addEventListener('load', function() {
    let savedScroll = sessionStorage.getItem('scrollPosition');

    if (savedScroll) {
        let checkProjects = setInterval(function() {
            if (document.querySelector('.card')) {
                clearInterval(checkProjects);


                window.scrollTo({
                    top: parseInt(savedScroll),
                    behavior: 'instant'
                });

                sessionStorage.removeItem('scrollPosition');
            }
        }, 50);
    }
});

document.addEventListener('contextmenu', function(e) {
    if (e.target.tagName === 'IMG') {
        e.preventDefault();
    }
});

document.addEventListener('dragstart', function(e) {
    if (e.target.tagName === 'IMG') {
        e.preventDefault();
    }
});

window.addEventListener('DOMContentLoaded', function() {

    let isSubpage = document.body.classList.contains('subpage');
    let imagePath = isSubpage ? '../../assets/favicon.png' : 'assets/favicon.png';

    let footerHTML = `
        <footer class="main-footer">
            <div class="footer-line"></div>
            <div class="footer-content">
                <!-- Lewa strona: Ostrzeżenie -->
                <p class="footer-warning">
                    <span class="pl">Wszelkie prawa zastrzeżone. Bezprawne kopiowanie i używanie projektów zabronione.</span>
                    <span class="en">All rights reserved. Unauthorized copying and use of projects is prohibited.</span>
                </p>
                
                <!-- Prawa strona: Logo i Imię -->
                <div class="footer-top">
                    <img src="${imagePath}" alt="Logo" class="footer-logo">
                    <p>© 2026 Emilia Szczerba.</p>
                </div>
            </div>
        </footer>
    `;

    document.body.insertAdjacentHTML('beforeend', footerHTML);
});