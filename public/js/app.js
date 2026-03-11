/* ── Theme ─────────────────────────────────────────────────────────────────
   Apply saved theme immediately, before DOM paint, to avoid flash.
─────────────────────────────────────────────────────────────────────────── */
(function () {
  var t = localStorage.getItem('bt-theme') || 'light';
  document.documentElement.setAttribute('data-theme', t);
})();

function toggleTheme() {
  var cur  = document.documentElement.getAttribute('data-theme');
  var next = cur === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('bt-theme', next);
  updateThemeIcon(next);
}

function updateThemeIcon(theme) {
  var icon = document.getElementById('themeIcon');
  if (!icon) return;
  icon.classList.toggle('fa-moon', theme !== 'dark');
  icon.classList.toggle('fa-sun',  theme === 'dark');
}

/* Sync icon with current theme on page load */
document.addEventListener('DOMContentLoaded', function () {
  var t = document.documentElement.getAttribute('data-theme') || 'light';
  updateThemeIcon(t);
});

/* ── Mobile nav ─────────────────────────────────────────────────────────── */
function toggleMenu() {
  var nav = document.getElementById('mobileNav');
  if (nav) nav.classList.toggle('open');
}

/* ── Auto-dismiss toast (3.5 s) ─────────────────────────────────────────── */
setTimeout(function () {
  document.querySelectorAll('.toast').forEach(function (el) {
    el.style.transition = 'opacity .4s';
    el.style.opacity    = '0';
    setTimeout(function () { el.remove(); }, 400);
  });
}, 3500);

/* ── Interactive star rating widget ─────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.star-widget').forEach(function (widget) {
    var buttons = widget.querySelectorAll('.star-btn');
    var input   = widget.querySelector('input[name="rating"]');
    var label   = widget.querySelector('.rlabel');
    var current = parseInt(widget.dataset.value, 10) || 0;

    function applyHighlight(val) {
      buttons.forEach(function (btn) {
        var v    = parseInt(btn.dataset.value, 10);
        var fill = v <= val;
        btn.classList.toggle('filled', fill);
        var icon = btn.querySelector('i');
        if (icon) {
          icon.classList.toggle('fa-solid',  fill);
          icon.classList.toggle('fa-regular', !fill);
        }
      });
    }

    function updateLabel(val) {
      if (label) label.textContent = val > 0 ? val + ' / 5 stars' : 'Not rated';
    }

    /* Init */
    applyHighlight(current);
    updateLabel(current);

    buttons.forEach(function (btn) {
      var v = parseInt(btn.dataset.value, 10);

      btn.addEventListener('mouseenter', function () { applyHighlight(v); });
      btn.addEventListener('mouseleave', function () { applyHighlight(current); });

      btn.addEventListener('click', function () {
        /* Clicking the active rating a second time clears it */
        current = (current === v) ? 0 : v;
        if (input) input.value = current;
        widget.dataset.value = current;
        applyHighlight(current);
        updateLabel(current);
      });
    });
  });
});
