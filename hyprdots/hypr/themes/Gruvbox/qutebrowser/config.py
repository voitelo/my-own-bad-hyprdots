# ==============================
# Qutebrowser Configuration File
# ==============================
# Auto-load config from autoconfig.yml
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
c.tabs.show = 'always'

c.url.start_pages = ["https://start.duckduckgo.com/"]
c.url.default_page = "https://start.duckduckgo.com/"
c.tabs.last_close = 'startpage'

# ========== Gruvbox Colors ==========
# Tabs
c.colors.tabs.bar.bg = '#282828'
c.colors.tabs.even.bg = '#282828'
c.colors.tabs.odd.bg = '#282828'
c.colors.tabs.selected.even.bg = '#458588'
c.colors.tabs.selected.odd.bg = '#458588'
c.colors.tabs.selected.even.fg = '#ebdbb2'
c.colors.tabs.selected.odd.fg = '#ebdbb2'
c.colors.tabs.even.fg = '#a89984'
c.colors.tabs.odd.fg = '#a89984'

# Status bar
c.colors.statusbar.normal.bg = '#282828'
c.colors.statusbar.normal.fg = '#ebdbb2'
c.colors.statusbar.insert.bg = '#689d6a'
c.colors.statusbar.insert.fg = '#282828'
c.colors.statusbar.command.bg = '#d79921'
c.colors.statusbar.command.fg = '#282828'
c.colors.statusbar.caret.bg = '#cc241d'
c.colors.statusbar.caret.fg = '#ebdbb2'
c.colors.statusbar.progress.bg = '#458588'

# Prompts and messages
c.colors.prompts.bg = '#282828'
c.colors.prompts.fg = '#ebdbb2'
c.colors.prompts.selected.bg = '#458588'
c.colors.prompts.selected.fg = '#ebdbb2'

# Completion widget
c.colors.completion.fg = '#ebdbb2'
# c.colors.completion.even.bg = '#282828'
c.colors.completion.item.selected.bg = '#458588'
c.colors.completion.item.selected.fg = '#ebdbb2'
c.colors.completion.category.fg = '#b16286'
c.colors.completion.category.bg = '#282828'

# Status hints
c.colors.hints.bg = '#b16286'
c.colors.hints.fg = '#282828'
c.colors.keyhint.fg = '#ebdbb2'
c.colors.keyhint.suffix.fg = '#b16286'
c.colors.keyhint.bg = '#282828'

# ========== Input ==========
c.input.insert_mode.auto_load = False
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True

# ========== Scrolling ==========
c.scrolling.smooth = False
c.scrolling.bar = 'always'

# ========== Keybinds ==========
config.bind('yt', 'open https://www.youtube.com/')
config.bind('ch', 'open https://chat.openai.com/')
config.bind('pe', 'open https://www.perplexity.ai/')
config.bind('m', 'open https://modrinth.com/')
config.bind('n', 'open -t https://start.duckduckgo.com/')
config.bind('a', 'open https://archlinux.org/')
config.bind('au', 'open https://aur.archlinux.org/')
config.bind('s', 'config-cycle tabs.show always never')
config.unbind('f')
config.unbind('F')
config.unbind('gf')
config.bind('tc', 'tab-clone')
config.bind('<Left>', 'scroll left')
config.bind('<Right>', 'scroll right')
config.bind('<Up>', 'scroll up')
config.bind('<Down>', 'scroll down')
config.bind('tt', 'config-cycle tabs.position left bottom')

# ========== Search engines ==========
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    '!aw': 'https://wiki.archlinux.org/?search={}',
    '!pkg': 'https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=',
    '!gh': 'https://github.com/search?o=desc&q={}&s=stars',
    '!yt': 'https://www.youtube.com/results?search_query={}',
}

c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem']

# ========== Aliases ==========
c.aliases['!yt'] = 'open !yt {}'
c.aliases['!gh'] = 'open !gh {}'
c.aliases['!aw'] = 'open !aw {}'
c.aliases['!apkg'] = 'open !apkg {}'
c.aliases['!ddg'] = 'open -t {}'

# ========== Smart URL detection ==========
def is_url(text: str) -> str:
    if '.' in text or text.startswith('localhost'):
        if not text.startswith(('http://', 'https://')):
            text = 'https://' + text
        return f'open {text}'
    return f'open -t https://duckduckgo.com/?q={text}'

config.bind('o', 'prompt --tab "Open URL or search:" "python is_url({})"')

# ========== Additional settings ==========
c.content.tls.certificate_errors = "load-insecurely"

