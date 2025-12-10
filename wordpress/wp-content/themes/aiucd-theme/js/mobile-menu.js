/**
 * Mobile Menu Toggle with JS-controlled display
 * Forza display:none/flex con JavaScript per risolvere problemi CSS
 */

document.addEventListener('DOMContentLoaded', function() {
	const menuContainers = document.querySelectorAll('.menu-menu-it-container, .menu-menu-en-container');
	
	// Funzione per aggiornare visibilità in base a viewport
	function updateMenuVisibility() {
		const isMobile = window.innerWidth <= 768;
		
		menuContainers.forEach(function(container) {
			const menu = container.querySelector('ul');
			const button = container.querySelector('.mobile-menu-toggle');
			
			if (!menu) return;
			
			if (isMobile) {
				// Mobile: mostra pulsante, nascondi menu a meno che non sia aperto
				if (button) button.style.display = 'block';
				const isOpen = menu.classList.contains('is-open');
				menu.style.display = isOpen ? 'flex' : 'none';
				menu.style.flexDirection = isOpen ? 'column' : '';
			} else {
				// Desktop: nascondi pulsante, mostra sempre menu orizzontale
				if (button) button.style.display = 'none';
				menu.style.display = 'flex';
				menu.style.flexDirection = 'row';
				menu.classList.remove('is-open'); // Reset stato mobile
			}
		});
	}
	
	menuContainers.forEach(function(container) {
		if (container.querySelector('.mobile-menu-toggle')) {
			return;
		}
		
		const toggleButton = document.createElement('button');
		toggleButton.className = 'mobile-menu-toggle';
		toggleButton.setAttribute('aria-label', 'Toggle menu');
		toggleButton.setAttribute('aria-expanded', 'false');
		toggleButton.innerHTML = `
			<span class="hamburger-line"></span>
			<span class="hamburger-line"></span>
			<span class="hamburger-line"></span>
		`;
		
		container.insertBefore(toggleButton, container.firstChild);
		
		const menu = container.querySelector('ul');
		
		toggleButton.addEventListener('click', function(e) {
			e.preventDefault();
			e.stopPropagation();
			
			const isOpen = menu.classList.contains('is-open');
			
			if (isOpen) {
				menu.classList.remove('is-open');
				toggleButton.classList.remove('is-active');
				toggleButton.setAttribute('aria-expanded', 'false');
			} else {
				// Chiudi altri menu
				document.querySelectorAll('ul.menu.is-open').forEach(function(otherMenu) {
					otherMenu.classList.remove('is-open');
					otherMenu.style.display = 'none';
				});
				document.querySelectorAll('.mobile-menu-toggle.is-active').forEach(function(otherButton) {
					otherButton.classList.remove('is-active');
					otherButton.setAttribute('aria-expanded', 'false');
				});
				
				menu.classList.add('is-open');
				toggleButton.classList.add('is-active');
				toggleButton.setAttribute('aria-expanded', 'true');
			}
			
			updateMenuVisibility();
		});
	});
	
	// Chiudi menu quando si clicca fuori
	document.addEventListener('click', function(e) {
		if (!e.target.closest('.menu-menu-it-container') && !e.target.closest('.menu-menu-en-container')) {
			document.querySelectorAll('ul.menu.is-open').forEach(function(menu) {
				menu.classList.remove('is-open');
			});
			document.querySelectorAll('.mobile-menu-toggle.is-active').forEach(function(button) {
				button.classList.remove('is-active');
				button.setAttribute('aria-expanded', 'false');
			});
			updateMenuVisibility();
		}
	});
	
	// Aggiorna al resize della finestra
	window.addEventListener('resize', updateMenuVisibility);
	
	// Inizializza visibilità
	updateMenuVisibility();
});
