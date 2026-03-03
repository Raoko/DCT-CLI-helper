// Password gate — SHA-256 hash comparison
async function checkPw() {
  const input = document.getElementById('pw-input').value;
  const enc = new TextEncoder().encode(input);
  const hash = await crypto.subtle.digest('SHA-256', enc);
  const hex = Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
  if (hex === 'edb42c54a083c167f944e0525b0ed423df2545366baab800432ecb397b04acff') {
    document.getElementById('pw-gate').style.display = 'none';
    document.getElementById('app-content').classList.add('unlocked');
    sessionStorage.setItem('cw-auth', '1');
  } else {
    document.getElementById('pw-err').classList.add('show');
    document.getElementById('pw-input').value = '';
    document.getElementById('pw-input').focus();
  }
}

// Auto-unlock if already authenticated this session
if (sessionStorage.getItem('cw-auth') === '1') {
  document.getElementById('pw-gate').style.display = 'none';
  document.getElementById('app-content').classList.add('unlocked');
}

// Nav scroll effect
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('scrolled', window.scrollY > 40);
}, { passive: true });

// Scroll-reveal observer
const reveals = document.querySelectorAll('.reveal');
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

reveals.forEach(el => observer.observe(el));

// Guide accordion toggle
function toggleGuide(header) {
  const card = header.parentElement;
  card.classList.toggle('open');
}
