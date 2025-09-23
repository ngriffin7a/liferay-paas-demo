function initializeNavigation() {
	console.log("1");
	const sections = document.querySelectorAll('.page-section section');
	const sectionLinksDiv = document.getElementById('pageSectionNav');
	let navContent = '<nav><ul>';

	sections.forEach(section => {
		const sectionId = section.getAttribute('id');
	console.log("2 sectionId=" + sectionId);
		const heading = section.querySelector('h1, h2, h3, h4, h5, h6');
		const sectionTitle = heading ? heading.textContent : 'Untitled Section';
		navContent += `<li>&gt;&nbsp;<a href="#${sectionId}">${sectionTitle}</a></li>`;
	});

	navContent += '</ul></nav>';
	sectionLinksDiv.innerHTML = navContent;

	const navLinks = document.querySelectorAll('#pageSectionNav a');
	navLinks.forEach(link => {
		link.addEventListener('click', function(event) {
			event.preventDefault();
			const targetId = this.getAttribute('href').substring(1);
			const targetElement = document.getElementById(targetId);
			const targetPosition = targetElement.getBoundingClientRect().top + window.scrollY - 100;

			// Remove the "selected" class from any previously selected headings
			document.querySelectorAll('.selected').forEach(el => el.classList.remove('selected'));

			// Add the "selected" class to the target heading
			const targetHeading = targetElement.querySelector('.heading-container');
			if (targetHeading) {
				targetHeading.classList.add('selected');
			}
			
			window.scroll({
				top: targetPosition,
				behavior: 'smooth'
			});
	});
	});
}

document.addEventListener('DOMContentLoaded', initializeNavigation);
Liferay.on('endNavigate', initializeNavigation);