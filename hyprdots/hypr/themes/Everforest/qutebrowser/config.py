config.load_autoconfig(False)

# ========================================
# General Appearance
# ========================================
c.fonts.default_family = "Monocraft"
c.fonts.default_size = "12pt"

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.threshold.foreground = 150
c.colors.webpage.bg = "#323d43"

c.tabs.position = "left"
c.tabs.width = 200
c.tabs.show = "always"
c.tabs.last_close = "startpage"

c.url.start_pages = ["https://start.duckduckgo.com/"]
c.url.default_page = "https://start.duckduckgo.com/"

# ========================================
# Input
# ========================================
c.input.insert_mode.auto_load = False
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True

# ========================================
# Scrolling
# ========================================
c.scrolling.smooth = False
c.scrolling.bar = "always"

# ========================================
# Keybinds
# ========================================
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
c.completion.open_categories = [
    'searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem'
]

# ========================================
# Aliases
# ========================================
c.aliases['!yt'] = 'open !yt {}'
c.aliases['!gh'] = 'open !gh {}'
c.aliases['!aw'] = 'open !aw {}'
c.aliases['!apkg'] = 'open !apkg {}'
c.aliases['!ddg'] = 'open -t {}'

# ========================================
# Smart URL detection for :o
# ========================================
def is_url(text: str) -> str:
    if '.' in text or text.startswith('localhost'):
        if not text.startswith(('http://', 'https://')):
            text = 'https://' + text
        return f'open {text}'
    return f'open -t https://duckduckgo.com/?q={text}'

config.bind('o', 'prompt --tab "Open URL or search:" "python is_url({})"')

# ========================================
# Security / TLS
# ========================================
c.content.tls.certificate_errors = "load-insecurely"

# ========================================
# Everforest (Soft Green) Theme 🌲
# ========================================
everforest = {
    "bg0": "#323d43",
    "bg1": "#3a464c",
    "bg2": "#434f55",
    "fg":  "#d3c6aa",
    "fg_dim": "#a7c080",
    "red": "#e67e80",
    "green": "#a7c080",
    "yellow": "#dbbc7f",
    "blue": "#7fbbb3",
    "magenta": "#d699b6",
    "cyan": "#83c092",
    "gray": "#475258",
}

# Tabs
c.colors.tabs.bar.bg = everforest["bg0"]
c.colors.tabs.even.bg = everforest["bg1"]
c.colors.tabs.odd.bg = everforest["bg1"]
c.colors.tabs.selected.even.bg = everforest["bg2"]
c.colors.tabs.selected.odd.bg = everforest["bg2"]
c.colors.tabs.even.fg = everforest["fg"]
c.colors.tabs.odd.fg = everforest["fg"]
c.colors.tabs.selected.even.fg = everforest["fg"]
c.colors.tabs.selected.odd.fg = everforest["fg"]

# Statusbar
c.colors.statusbar.normal.bg = everforest["bg0"]
c.colors.statusbar.normal.fg = everforest["fg"]
c.colors.statusbar.insert.bg = everforest["green"]
c.colors.statusbar.insert.fg = everforest["bg0"]
c.colors.statusbar.command.bg = everforest["bg1"]
c.colors.statusbar.command.fg = everforest["fg"]
c.colors.statusbar.url.success.http.fg = everforest["blue"]
c.colors.statusbar.url.success.https.fg = everforest["green"]
c.colors.statusbar.url.error.fg = everforest["red"]

# Completion
c.colors.completion.fg = everforest["fg"]
c.colors.completion.odd.bg = everforest["bg1"]
c.colors.completion.even.bg = everforest["bg0"]
c.colors.completion.category.bg = everforest["bg2"]
c.colors.completion.category.fg = everforest["yellow"]
c.colors.completion.item.selected.bg = everforest["bg2"]
c.colors.completion.item.selected.fg = everforest["fg"]
c.colors.completion.match.fg = everforest["green"]

# Prompts
c.colors.prompts.bg = everforest["bg1"]
c.colors.prompts.fg = everforest["fg"]
c.colors.prompts.border = f"1px solid {everforest['bg2']}"

# Downloads
c.colors.downloads.bar.bg = everforest["bg0"]
c.colors.downloads.start.bg = everforest["blue"]
c.colors.downloads.stop.bg = everforest["green"]
c.colors.downloads.error.bg = everforest["red"]

# Hints
c.colors.hints.bg = everforest["yellow"]
c.colors.hints.fg = everforest["bg0"]
c.colors.hints.match.fg = everforest["red"]

# Messages
c.colors.messages.error.bg = everforest["red"]
c.colors.messages.error.fg = everforest["bg0"]
c.colors.messages.info.bg = everforest["bg1"]
c.colors.messages.info.fg = everforest["fg"]
c.colors.messages.warning.bg = everforest["yellow"]
c.colors.messages.warning.fg = everforest["bg0"]

# Context menu
c.colors.contextmenu.menu.bg = everforest["bg0"]
c.colors.contextmenu.menu.fg = everforest["fg"]
c.colors.contextmenu.selected.bg = everforest["bg2"]
c.colors.contextmenu.selected.fg = everforest["fg"]

# Progress / downloads
c.colors.downloads.system.bg = "none"

