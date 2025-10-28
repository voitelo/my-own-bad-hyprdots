config.load_autoconfig(False)

# ========== Appearance ==========
c.fonts.default_family = "Monocraft"
c.fonts.default_size = "12pt"

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.threshold.foreground = 150

# Tabs
c.tabs.position = "left"
c.tabs.width = 200
c.tabs.show = 'always'
c.colors.tabs.bar.bg = '#2E3440'
c.colors.tabs.selected.even.bg = '#3B4252'
c.colors.tabs.selected.even.fg = '#D8DEE9'
c.colors.tabs.selected.odd.bg = '#3B4252'
c.colors.tabs.selected.odd.fg = '#D8DEE9'
c.colors.tabs.indicator.error = '#BF616A'
c.colors.tabs.odd.bg = '#434C5E'
c.colors.tabs.odd.fg = '#ECEFF4'
c.colors.tabs.even.bg = '#434C5E'
c.colors.tabs.even.fg = '#ECEFF4'
c.colors.tabs.pinned.even.bg = '#81A1C1'
c.colors.tabs.pinned.odd.bg = '#81A1C1'
c.colors.tabs.pinned.selected.even.bg = '#88C0D0'
c.colors.tabs.pinned.selected.odd.bg = '#88C0D0'

# Start pages
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

def is_url(text: str) -> str:
    if '.' in text or text.startswith('localhost'):
        if not text.startswith(('http://', 'https://')):
            text = 'https://' + text
        return f'open {text}'
    return f'open -t https://duckduckgo.com/?q={text}'

config.bind('o', 'prompt --tab "Open URL or search:" "python is_url({})"')

# ========== TLS ==========
c.content.tls.certificate_errors = "load-insecurely"

# ========== Nord Colors (additional UI) ==========
c.colors.statusbar.normal.bg = '#2E3440'
c.colors.statusbar.normal.fg = '#D8DEE9'
c.colors.statusbar.command.bg = '#3B4252'
c.colors.statusbar.command.fg = '#D8DEE9'
c.colors.statusbar.insert.bg = '#88C0D0'
c.colors.statusbar.insert.fg = '#2E3440'
c.colors.statusbar.passthrough.bg = '#81A1C1'
c.colors.statusbar.passthrough.fg = '#2E3440'
c.colors.downloads.bar.bg = '#3B4252'
c.colors.downloads.start.bg = '#81A1C1'
c.colors.downloads.start.fg = '#2E3440'
c.colors.downloads.stop.bg = '#A3BE8C'
c.colors.downloads.stop.fg = '#2E3440'
c.colors.hints.bg = '#81A1C1'
c.colors.hints.fg = '#2E3440'
c.colors.prompts.bg = '#3B4252'
c.colors.prompts.fg = '#D8DEE9'
c.colors.messages.error.bg = '#BF616A'
c.colors.messages.error.fg = '#2E3440'
c.colors.messages.warning.bg = '#EBCB8B'
c.colors.messages.warning.fg = '#2E3440'
c.colors.messages.info.bg = '#81A1C1'
c.colors.messages.info.fg = '#2E3440'

