from pathlib import Path
import re
import shutil

root = Path(r"d:\Labib\Coding\Projects\Cyber Security Roadmap Hub").resolve()
index_path = root / "index.html"
text = index_path.read_text(encoding="utf-8")

# Create directories
for rel in [
    "assets/css",
    "assets/js",
    "assets/images",
    "assets/data",
    "pages",
    "components",
]:
    (root / rel).mkdir(parents=True, exist_ok=True)

# Copy logo if present
logo_src = root / "shadow_01.png"
logo_dst = root / "assets/images/shadow_01.png"
if logo_src.exists() and not logo_dst.exists():
    shutil.copy2(logo_src, logo_dst)

# Extract stylesheet
style_match = re.search(r"<style>(.*?)</style>", text, re.S)
if style_match:
    css = style_match.group(1)
    (root / "assets/css/main.css").write_text(css, encoding="utf-8")

    # Split by major sections
    def save_css(name, start_marker, end_marker=None):
        start = css.find(start_marker)
        if start == -1:
            return
        if end_marker is None:
            end = len(css)
        else:
            end = css.find(end_marker, start)
            if end == -1:
                end = len(css)
        content = css[start:end].strip()
        (root / "assets/css" / name).write_text(content, encoding="utf-8")

    save_css("variables.css", "/* ─── RESET & BASE ─── */", "/* ─── HEADER ─── */")
    save_css("header.css", "/* ─── HEADER ─── */", "/* ─── PAGES (SPA) ─── */")
    save_css("home.css", "/* ─── SECTION CARDS (Home) ─── */", "/* ─── CAREER PATHS ─── */")
    save_css("detail.css", "/* ─── DETAIL PAGE ─── */", "/* ─── RESPONSIVE ─── */")
    save_css("responsive.css", "/* ─── RESPONSIVE ─── */")
else:
    (root / "assets/css/main.css").write_text("/* styles moved */\n", encoding="utf-8")

# Extract markup pieces
header_match = re.search(r"<header class=\"main-header\" role=\"banner\">.*?</header>", text, re.S)
if header_match:
    (root / "components/header.html").write_text(header_match.group(0), encoding="utf-8")
else:
    (root / "components/header.html").write_text("<header class=\"main-header\" role=\"banner\"></header>", encoding="utf-8")

footer_match = re.search(r"<footer class=\"footer\" role=\"contentinfo\">.*?</footer>", text, re.S)
if footer_match:
    (root / "components/footer.html").write_text(footer_match.group(0), encoding="utf-8")
else:
    (root / "components/footer.html").write_text("<footer class=\"footer\" role=\"contentinfo\"></footer>", encoding="utf-8")

(root / "components/card.html").write_text("<article class=\"section-card\"></article>", encoding="utf-8")
(root / "components/resource.html").write_text("<a href=\"#\" class=\"chip\"></a>", encoding="utf-8")

# Extract page blocks robustly
page_ids = [
    "page-home",
    "page-section1",
    "page-section2",
    "page-section3",
    "page-section4",
    "page-section5",
    "page-section6",
    "page-section7",
    "page-section8",
    "page-section9",
    "page-section10",
    "page-section11",
    "page-section12",
    "page-section13",
    "page-section14",
    "page-section15",
    "page-section16",
]
page_names = {
    "page-home": "home.html",
    "page-section1": "section1.html",
    "page-section2": "section2.html",
    "page-section3": "section3.html",
    "page-section4": "section4.html",
    "page-section5": "section5.html",
    "page-section6": "section6.html",
    "page-section7": "section7.html",
    "page-section8": "section8.html",
    "page-section9": "section9.html",
    "page-section10": "section10.html",
    "page-section11": "section11.html",
    "page-section12": "section12.html",
    "page-section13": "section13.html",
    "page-section14": "section14.html",
    "page-section15": "section15.html",
    "page-section16": "section16.html",
}

for page_id in page_ids:
    start_marker = f'<div id="{page_id}" class="page'
    start_index = text.find(start_marker)
    if start_index == -1:
        continue
    open_tag_end = text.find('>', start_index)
    if open_tag_end == -1:
        continue
    depth = 0
    cursor = start_index
    while cursor < len(text):
        next_open = text.find('<div', cursor)
        next_close = text.find('</div>', cursor)
        if next_open == -1 and next_close == -1:
            break
        if next_open != -1 and (next_close == -1 or next_open < next_close):
            if text.startswith('<!--', next_open):
                cursor = text.find('-->', next_open) + 3
                continue
            depth += 1
            cursor = next_open + 4
        else:
            depth -= 1
            cursor = next_close + 6
            if depth == 0:
                end_index = next_close + 6
                break
    else:
        end_index = len(text)

    if 'depth' in locals() and depth == 0:
        block = text[start_index:end_index]
        (root / 'pages' / page_names[page_id]).write_text(block, encoding='utf-8')

# Write data file
(root / 'assets/data/sections.json').write_text('''{
  "sections": [
    {"id": "section1", "title": "Computer Basics", "level": "Beginner"},
    {"id": "section2", "title": "Networking", "level": "Beginner"},
    {"id": "section3", "title": "Linux", "level": "Beginner"},
    {"id": "section4", "title": "Programming", "level": "Beginner"},
    {"id": "section5", "title": "Web Basics", "level": "Beginner"},
    {"id": "section6", "title": "Security Basics", "level": "Beginner"},
    {"id": "section7", "title": "Penetration Testing", "level": "Intermediate"},
    {"id": "section8", "title": "Bug Bounty", "level": "Intermediate"},
    {"id": "section9", "title": "Blue Team", "level": "Intermediate"},
    {"id": "section10", "title": "Red Team", "level": "Intermediate"},
    {"id": "section11", "title": "Cloud Security", "level": "Intermediate"},
    {"id": "section12", "title": "Modern Security", "level": "Intermediate"},
    {"id": "section13", "title": "Malware Analysis", "level": "Advanced"},
    {"id": "section14", "title": "Reverse Engineering", "level": "Advanced"},
    {"id": "section15", "title": "Digital Forensics", "level": "Advanced"},
    {"id": "section16", "title": "Social Engineering", "level": "Advanced"}
  ]
}
''', encoding='utf-8')

# Write JS files
(root / 'assets/js/utils.js').write_text('''window.scrollState = {};
''', encoding='utf-8')

(root / 'assets/js/router.js').write_text('''window.router = {
  normalizeHash: function(hash) {
    const clean = (hash || '').replace(/^#/, '').trim();
    if (!clean || clean === 'specializations') return 'home';
    return clean;
  },
  toPageKey: function(hash) {
    const normalized = this.normalizeHash(hash);
    return normalized === 'home' ? 'home' : normalized;
  }
};
''', encoding='utf-8')

(root / 'assets/js/sections.js').write_text('''window.sectionRoutes = {
  home: 'pages/home.html',
  section1: 'pages/section1.html',
  section2: 'pages/section2.html',
  section3: 'pages/section3.html',
  section4: 'pages/section4.html',
  section5: 'pages/section5.html',
  section6: 'pages/section6.html',
  section7: 'pages/section7.html',
  section8: 'pages/section8.html',
  section9: 'pages/section9.html',
  section10: 'pages/section10.html',
  section11: 'pages/section11.html',
  section12: 'pages/section12.html',
  section13: 'pages/section13.html',
  section14: 'pages/section14.html',
  section15: 'pages/section15.html',
  section16: 'pages/section16.html'
};
''', encoding='utf-8')

(root / 'assets/js/app.js').write_text('''(function() {
  const pageShell = document.getElementById('page-shell');
  const headerTarget = document.getElementById('header-placeholder');
  const footerTarget = document.getElementById('footer-placeholder');
  let currentPageKey = 'home';
  const scrollPositions = {};

  function updateHash(pageKey) {
    const nextHash = pageKey === 'home' ? 'home' : pageKey;
    if (window.location.hash !== '#' + nextHash) {
      window.history.pushState(null, null, '#' + nextHash);
    }
  }

  function loadFragment(url, target, callback) {
    fetch(url)
      .then(function(response) {
        if (!response.ok) throw new Error('Failed');
        return response.text();
      })
      .then(function(html) {
        target.innerHTML = html;
        if (callback) callback();
      })
      .catch(function() {
        target.innerHTML = '<p>Content could not be loaded.</p>';
      });
  }

  function renderPage(pageKey) {
    if (!pageShell) return;
    const previousPageKey = currentPageKey;
    if (previousPageKey && previousPageKey !== pageKey) {
      scrollPositions[previousPageKey] = window.scrollY;
    }
    currentPageKey = pageKey;

    const pageFile = (window.sectionRoutes && window.sectionRoutes[pageKey]) || window.sectionRoutes.home;
    loadFragment(pageFile, pageShell, function() {
      updateHash(pageKey);
      const savedScroll = scrollPositions[pageKey];
      if (typeof savedScroll === 'number') {
        window.scrollTo({ top: savedScroll, behavior: 'auto' });
      } else {
        window.scrollTo({ top: 0, behavior: 'auto' });
      }
    });
  }

  function handleRoute() {
    const pageKey = window.router.toPageKey(window.location.hash);
    renderPage(pageKey);
  }

  document.addEventListener('click', function(event) {
    const link = event.target.closest('a[href^="#"]');
    if (!link) return;
    const target = link.getAttribute('href');
    if (target === '#home' || target.startsWith('#section') || target === '#specializations') {
      event.preventDefault();
      window.location.hash = target.substring(1);
    }
  });

  window.addEventListener('hashchange', handleRoute);
  window.addEventListener('load', function() {
    loadFragment('components/header.html', headerTarget);
    loadFragment('components/footer.html', footerTarget);
    if (!window.location.hash || window.location.hash === '#') {
      window.location.hash = 'home';
    } else {
      handleRoute();
    }
  });
})();
''', encoding='utf-8')

# Write new index shell
index_shell = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>sh@dowSec · Cybersecurity Roadmap</title>
    <meta name="description" content="Complete beginner-friendly cybersecurity roadmap covering fundamentals and specializations including Social Engineering." />
    <meta property="og:title" content="sh@dowSec · Cybersecurity Roadmap" />
    <meta property="og:description" content="Learn cybersecurity step by step with practical explanations and free resources." />
    <meta property="og:type" content="website" />
    <meta name="theme-color" content="#080b12" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" />
    <link rel="stylesheet" href="assets/css/variables.css" />
    <link rel="stylesheet" href="assets/css/header.css" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/home.css" />
    <link rel="stylesheet" href="assets/css/detail.css" />
    <link rel="stylesheet" href="assets/css/responsive.css" />
</head>
<body>
    <div class="container">
        <div id="header-placeholder"></div>
        <main id="page-shell" class="page active" role="main"></main>
        <div id="footer-placeholder"></div>
    </div>

    <script src="assets/js/utils.js"></script>
    <script src="assets/js/router.js"></script>
    <script src="assets/js/sections.js"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>
'''
index_path.write_text(index_shell, encoding='utf-8')

print('Project split complete')
