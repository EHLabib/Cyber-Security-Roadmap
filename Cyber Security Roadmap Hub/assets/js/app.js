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
    const shouldAnimate = target === pageShell || target === headerTarget || target === footerTarget;
    if (shouldAnimate) {
      target.classList.add('is-transitioning');
    }

    fetch(url)
      .then(function(response) {
        if (!response.ok) throw new Error('Failed');
        return response.text();
      })
      .then(function(html) {
        target.innerHTML = html;
        if (target === pageShell) {
          const pageContent = target.querySelector('.page');
          if (pageContent) {
            target.querySelectorAll('.page').forEach(function(page) {
              page.classList.remove('active');
            });
            pageContent.classList.add('active');
          }
        }
        if (shouldAnimate) {
          requestAnimationFrame(function() {
            target.classList.remove('is-transitioning');
          });
        }
        if (callback) callback();
      })
      .catch(function() {
        target.innerHTML = '<p>Content could not be loaded.</p>';
        if (shouldAnimate) {
          target.classList.remove('is-transitioning');
        }
      });
  }

  function bindNavigationLinks(root) {
    if (!root) return;
    root.querySelectorAll('a[href^="#"]').forEach(function(link) {
      link.removeEventListener('click', handleHashLinkClick);
      link.addEventListener('click', handleHashLinkClick);
    });
  }

  function bindExpandIcons(root) {
    if (!root) return;
    root.querySelectorAll('.expand-icon').forEach(function(el) {
      el.removeEventListener('click', handleExpandClick);
      el.addEventListener('click', handleExpandClick);
      el.setAttribute('tabindex', '0');
      el.removeEventListener('keydown', handleExpandKey);
      el.addEventListener('keydown', handleExpandKey);
    });
  }

  function handleExpandClick(e) {
    const el = e.currentTarget;
    const card = el.closest('a[href^="#"]');
    if (!card) return;
    const href = card.getAttribute('href');
    if (!href || href === '#') return;
    e.preventDefault();
    const next = href.replace(/^#/, '');
    if (window.location.hash !== '#' + next) {
      window.location.hash = next;
    }
  }

  function handleExpandKey(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleExpandClick(e);
    }
  }

  function handleHashLinkClick(event) {
    const link = event.currentTarget;
    const target = link.getAttribute('href');
    if (!target || target === '#' || target === '#!') return;

    const normalizedTarget = target.trim();
    const isInternalRoute = normalizedTarget === '#home' || normalizedTarget.startsWith('#section') || normalizedTarget === '#specializations';

    if (isInternalRoute) {
      event.preventDefault();
      const nextHash = normalizedTarget.substring(1);
      if (window.location.hash !== '#' + nextHash) {
        window.location.hash = nextHash;
      }
    }
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
      bindNavigationLinks(pageShell);
      bindExpandIcons(pageShell);
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