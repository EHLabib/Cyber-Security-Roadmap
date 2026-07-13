$root = Resolve-Path '.'
$indexPath = Join-Path $root 'index.html'
$text = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$dirs = @('assets/css','assets/js','assets/images','assets/data','pages','components')
foreach ($dir in $dirs) {
    $fullDir = Join-Path $root $dir
    if (-not (Test-Path $fullDir)) { New-Item -ItemType Directory -Path $fullDir -Force | Out-Null }
}

$logoSrc = Join-Path $root 'shadow_01.png'
$logoDst = Join-Path $root 'assets/images/shadow_01.png'
if ((Test-Path $logoSrc) -and -not (Test-Path $logoDst)) {
    Copy-Item $logoSrc $logoDst -Force
}

$styleMatch = [regex]::Match($text, '<style>(?<css>.*?)</style>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($styleMatch.Success) {
    $css = $styleMatch.Groups['css'].Value
    [System.IO.File]::WriteAllText((Join-Path $root 'assets/css/main.css'), $css, [System.Text.Encoding]::UTF8)

    function Save-CssFile($name, $startMarker, $endMarker) {
        $start = $css.IndexOf($startMarker)
        if ($start -lt 0) { return }
        $end = if ($endMarker) { $css.IndexOf($endMarker, $start) } else { $css.Length }
        if ($end -lt 0) { $end = $css.Length }
        $content = $css.Substring($start, $end - $start).Trim()
        [System.IO.File]::WriteAllText((Join-Path $root ("assets/css/$name")), $content, [System.Text.Encoding]::UTF8)
    }

    Save-CssFile 'variables.css' '/* ─── RESET & BASE ─── */' '/* ─── HEADER ─── */'
    Save-CssFile 'header.css' '/* ─── HEADER ─── */' '/* ─── PAGES (SPA) ─── */'
    Save-CssFile 'home.css' '/* ─── SECTION CARDS (Home) ─── */' '/* ─── CAREER PATHS ─── */'
    Save-CssFile 'detail.css' '/* ─── DETAIL PAGE ─── */' '/* ─── RESPONSIVE ─── */'
    Save-CssFile 'responsive.css' '/* ─── RESPONSIVE ─── */' $null
} else {
    [System.IO.File]::WriteAllText((Join-Path $root 'assets/css/main.css'), '/* styles moved */', [System.Text.Encoding]::UTF8)
}

$headerMatch = [regex]::Match($text, '<header class="main-header" role="banner">(?<body>.*?)</header>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($headerMatch.Success) {
    [System.IO.File]::WriteAllText((Join-Path $root 'components/header.html'), $headerMatch.Value, [System.Text.Encoding]::UTF8)
} else {
    [System.IO.File]::WriteAllText((Join-Path $root 'components/header.html'), '<header class="main-header" role="banner"></header>', [System.Text.Encoding]::UTF8)
}

$footerMatch = [regex]::Match($text, '<footer class="footer" role="contentinfo">(?<body>.*?)</footer>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($footerMatch.Success) {
    [System.IO.File]::WriteAllText((Join-Path $root 'components/footer.html'), $footerMatch.Value, [System.Text.Encoding]::UTF8)
} else {
    [System.IO.File]::WriteAllText((Join-Path $root 'components/footer.html'), '<footer class="footer" role="contentinfo"></footer>', [System.Text.Encoding]::UTF8)
}

[System.IO.File]::WriteAllText((Join-Path $root 'components/card.html'), '<article class="section-card"></article>', [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $root 'components/resource.html'), '<a href="#" class="chip"></a>', [System.Text.Encoding]::UTF8)

$pageIds = @(
    'page-home',
    'page-section1','page-section2','page-section3','page-section4','page-section5','page-section6',
    'page-section7','page-section8','page-section9','page-section10','page-section11','page-section12',
    'page-section13','page-section14','page-section15','page-section16'
)
$pageNames = @{
    'page-home'='home.html';
    'page-section1'='section1.html';
    'page-section2'='section2.html';
    'page-section3'='section3.html';
    'page-section4'='section4.html';
    'page-section5'='section5.html';
    'page-section6'='section6.html';
    'page-section7'='section7.html';
    'page-section8'='section8.html';
    'page-section9'='section9.html';
    'page-section10'='section10.html';
    'page-section11'='section11.html';
    'page-section12'='section12.html';
    'page-section13'='section13.html';
    'page-section14'='section14.html';
    'page-section15'='section15.html';
    'page-section16'='section16.html';
}

foreach ($pageId in $pageIds) {
    $startMarker = '<div id="' + $pageId + '" class="page'
    $startIndex = $text.IndexOf($startMarker)
    if ($startIndex -lt 0) { continue }

    $depth = 0
    $cursor = $startIndex
    $endIndex = -1
    while ($cursor -lt $text.Length) {
        $openIndex = $text.IndexOf('<div', $cursor)
        $closeIndex = $text.IndexOf('</div>', $cursor)

        if ($openIndex -lt 0 -and $closeIndex -lt 0) { break }

        if ($openIndex -ge 0 -and ($closeIndex -lt 0 -or $openIndex -lt $closeIndex)) {
            $depth += 1
            $cursor = $openIndex + 4
        } else {
            $depth -= 1
            $cursor = $closeIndex + 6
            if ($depth -eq 0) { $endIndex = $closeIndex + 6; break }
        }
    }

    if ($endIndex -gt 0) {
        $block = $text.Substring($startIndex, $endIndex - $startIndex)
        [System.IO.File]::WriteAllText((Join-Path $root ("pages/$($pageNames[$pageId])")), $block, [System.Text.Encoding]::UTF8)
    }
}

$sectionsJson = @'
{
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
'@
[System.IO.File]::WriteAllText((Join-Path $root 'assets/data/sections.json'), $sectionsJson, [System.Text.Encoding]::UTF8)

[System.IO.File]::WriteAllText((Join-Path $root 'assets/js/utils.js'), "window.scrollState = {};\n", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $root 'assets/js/router.js'), @'
window.router = {
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
'@, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $root 'assets/js/sections.js'), @'
window.sectionRoutes = {
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
'@, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $root 'assets/js/app.js'), @'
(function() {
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
'@, [System.Text.Encoding]::UTF8)

$indexShell = @'
<!DOCTYPE html>
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
'@
[System.IO.File]::WriteAllText($indexPath, $indexShell, [System.Text.Encoding]::UTF8)

Write-Output 'Project split complete'
