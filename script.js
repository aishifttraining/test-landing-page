/* ============================================================
   Breakthrough Author Live — page behaviour
   1. Light / dark switch
   2. Video play button
   ============================================================ */

/* ------------------------------------------------------------
   1. LIGHT / DARK SWITCH
   ------------------------------------------------------------ */

var STORAGE_KEY = 'bal-theme';
var root = document.documentElement;
var toggle = document.getElementById('themeToggle');
var toggleIcon = toggle.querySelector('.theme-toggle__icon');
var toggleText = toggle.querySelector('.theme-toggle__text');

function applyTheme(theme) {
  var dark = theme === 'dark';
  root.setAttribute('data-theme', dark ? 'dark' : 'light');
  toggleIcon.textContent = dark ? '☀️' : '🌙';
  toggleText.textContent = dark ? 'Light' : 'Dark';
  toggle.setAttribute('aria-pressed', dark ? 'true' : 'false');
  toggle.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
}

/* Work out the starting theme:
   1. what the visitor chose last time, or
   2. what their phone or computer asks for. */
function startingTheme() {
  var saved = null;
  try {
    saved = localStorage.getItem(STORAGE_KEY);
  } catch (e) {
    saved = null;
  }
  if (saved === 'dark' || saved === 'light') return saved;

  var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  return prefersDark ? 'dark' : 'light';
}

applyTheme(startingTheme());

toggle.addEventListener('click', function () {
  var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  applyTheme(next);
  try {
    localStorage.setItem(STORAGE_KEY, next);
  } catch (e) {
    /* Private mode: the switch still works, it just will not be remembered. */
  }
});

/* ------------------------------------------------------------
   2. VIDEO
   Paste your video link between the quotes below.
   YouTube example:  'https://www.youtube.com/embed/XXXXXXXXXXX'
   Vimeo example:    'https://player.vimeo.com/video/123456789'
   Leave it empty and the button shows a short note instead.
   ------------------------------------------------------------ */

var VIDEO_URL = '';

var videoBox = document.getElementById('videoBox');
var videoPlay = document.getElementById('videoPlay');
var videoNote = document.getElementById('videoNote');

videoPlay.addEventListener('click', function () {
  if (!VIDEO_URL) {
    videoNote.hidden = false;
    return;
  }
  var frame = document.createElement('iframe');
  frame.src = VIDEO_URL + (VIDEO_URL.indexOf('?') > -1 ? '&' : '?') + 'autoplay=1';
  frame.title = 'Breakthrough Author Live — how the 4-week challenge works';
  frame.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; picture-in-picture';
  frame.allowFullscreen = true;
  videoBox.innerHTML = '';
  videoBox.appendChild(frame);
});
