config.load_autoconfig(False)

# ========== Appearance ==========
c.fonts.default_family = "Monocraft"
c.fonts.default_size = "12pt"

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.threshold.foreground = 150

c.tabs.position = "left"
c.tabs.width = 200
c.colors.tabs.bar.bg = '#111111'
c.tabs.show = 'always'

c.url.start_pages = ["https://start.duckduckgo.com/"]
c.url.default_page = "https://start.duckduckgo.com/"
c.tabs.last_close = 'startpage'

# ========== Input ==========
c.input.insert_mode.auto_load = False
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True

# ========== Scrolling ==========
c.scrolling.smooth = False
c.scrolling.bar = 'always'

# ========== Keybinds ==========
# Quick site launchers
config.bind('yt', 'open https://www.youtube.com/')
config.bind('ch', 'open https://chat.openai.com/')
config.bind('pe', 'open https://www.perplexity.ai/')
config.bind('m', 'open https://modrinth.com/')
config.bind('n', 'open -t https://start.duckduckgo.com/')  # background tab
config.bind('a', 'open https://archlinux.org/')
config.bind('au', 'open https://aur.archlinux.org/')

# Sidebar toggle
config.bind('s', 'config-cycle tabs.show always never')

# Disable hints
config.unbind('f')
config.unbind('F')
config.unbind('gf')

# Tab clone
config.bind('tc', 'tab-clone')

# Arrow scrolling
config.bind('<Left>', 'scroll left')
config.bind('<Right>', 'scroll right')
config.bind('<Up>', 'scroll up')
config.bind('<Down>', 'scroll down')

# Toggle between left and bottom tabs
config.bind('tt', 'config-cycle tabs.position left bottom')

# ========================================
# Search engines
# ========================================
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    '!aw': 'https://wiki.archlinux.org/?search={}',
    '!pkg': 'https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=',
    '!gh': 'https://github.com/search?o=desc&q={}&s=stars',
    '!yt': 'https://www.youtube.com/results?search_query={}',
}

c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem']

# ========================================
# Aliases (match behavior above)
# ========================================
c.aliases['!yt'] = 'open !yt {}'
c.aliases['!gh'] = 'open !gh {}'
c.aliases['!aw'] = 'open !aw {}'
c.aliases['!apkg'] = 'open !apkg {}'
c.aliases['!ddg'] = 'open -t {}'  # DuckDuckGo alias opens in background

# ========================================
# Optional: smart URL detection for :o
# ========================================
def is_url(text: str) -> str:
    if '.' in text or text.startswith('localhost'):
        if not text.startswith(('http://', 'https://')):
            text = 'https://' + text
        return f'open {text}'  # open in current tab
    return f'open -t https://duckduckgo.com/?q={text}'  # DuckDuckGo background

config.bind('o', 'prompt --tab "Open URL or search:" "python is_url({})"')


# -----------------
# additional stuff
# -----------------
c.content.tls.certificate_errors = "load-insecurely"
