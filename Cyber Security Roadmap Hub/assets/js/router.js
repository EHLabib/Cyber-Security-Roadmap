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