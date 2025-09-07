import gi, json, configparser, os
gi.require_version('Gtk','3.0')
gi.require_version('WebKit2','4.0')
from gi.repository import Gtk, WebKit2, Gdk, GObject

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# --- Config ---
config_path = os.path.join(BASE_DIR, "config.ini")
config = configparser.ConfigParser()
if not os.path.exists(config_path):
    config['general'] = {
        'theme': 'dark',
        'zen_mode': 'yes',
        'zen_opacity': '0.85',
        'sidebar_position': 'left',
        'tab_layout': 'vertical',
        'default_search_engine': 'ecosia',
        'homepage': 'about:blank',
        'new_tab_behavior': 'blank',
        'max_tabs': '20',
        'floating_url': 'yes',
        'show_toolbar_buttons':'yes',
        'show_tab_titles':'yes',
        'enable_custom_macros':'yes'
    }
    config['privacy'] = {
        'cookies_enabled':'yes',
        'javascript_enabled':'yes',
        'plugins_enabled':'yes',
        'media_autoplay':'yes',
        'tracking_protection':'no',
        'fingerprint_protection':'no'
    }
    config['plugins'] = {'adblock':'enabled','dark_mode':'disabled','youtube_unhook':'disabled'}
    config['macros'] = {}
    with open(config_path,'w') as f:
        config.write(f)
else:
    config.read(config_path)

macros = []
if 'macros' in config:
    for k,v in config['macros'].items():
        macros.append(json.loads(v))

# --- CSS ---
css_path = os.path.join(BASE_DIR, "style.css")
css_provider = Gtk.CssProvider()
if os.path.exists(css_path):
    css_provider.load_from_path(css_path)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(),
        css_provider,
        Gtk.STYLE_PROVIDER_PRIORITY_USER
    )

# --- ConfigAgent ---
class ConfigAgent(Gtk.Window):
    def __init__(self, browser=None):
        super().__init__(title="ZenPlus Configuration")
        self.set_default_size(700,600)
        self.browser = browser
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        notebook = Gtk.Notebook()
        vbox.pack_start(notebook, True, True, 0)

        # --- Appearance Tab ---
        appearance = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        appearance.pack_start(Gtk.Label(label="Theme (dark/light):"), False, False, 2)
        self.theme_entry = Gtk.Entry()
        self.theme_entry.set_text(config['general'].get('theme','dark'))
        appearance.pack_start(self.theme_entry, False, False,2)

        appearance.pack_start(Gtk.Label(label="Zen opacity (0-1):"), False, False,2)
        self.opacity_entry = Gtk.Entry()
        self.opacity_entry.set_text(config['general'].get('zen_opacity','0.85'))
        appearance.pack_start(self.opacity_entry, False, False,2)

        appearance.pack_start(Gtk.Label(label="Sidebar position (left/right):"), False, False,2)
        self.sidebar_entry = Gtk.Entry()
        self.sidebar_entry.set_text(config['general'].get('sidebar_position','left'))
        appearance.pack_start(self.sidebar_entry, False, False,2)

        appearance.pack_start(Gtk.Label(label="Tab layout (vertical/horizontal):"), False, False,2)
        self.tablayout_entry = Gtk.Entry()
        self.tablayout_entry.set_text(config['general'].get('tab_layout','vertical'))
        appearance.pack_start(self.tablayout_entry, False, False,2)

        appearance.pack_start(Gtk.Label(label="Show Toolbar Buttons:"), False, False,2)
        self.toolbar_toggle = Gtk.CheckButton(label="Show Min/Max/Close buttons")
        self.toolbar_toggle.set_active(config['general'].get('show_toolbar_buttons','yes')=='yes')
        appearance.pack_start(self.toolbar_toggle, False, False,2)

        appearance.pack_start(Gtk.Label(label="Show Tab Titles:"), False, False,2)
        self.tabtitle_toggle = Gtk.CheckButton(label="Show Titles on Tabs")
        self.tabtitle_toggle.set_active(config['general'].get('show_tab_titles','yes')=='yes')
        appearance.pack_start(self.tabtitle_toggle, False, False,2)

        notebook.append_page(appearance, Gtk.Label(label="Appearance"))

        # --- Privacy Tab ---
        privacy_tab = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        self.cookies_toggle = Gtk.CheckButton(label="Enable Cookies")
        self.cookies_toggle.set_active(config['privacy'].get('cookies_enabled','yes')=='yes')
        privacy_tab.pack_start(self.cookies_toggle, False, False,2)

        self.js_toggle = Gtk.CheckButton(label="Enable JavaScript")
        self.js_toggle.set_active(config['privacy'].get('javascript_enabled','yes')=='yes')
        privacy_tab.pack_start(self.js_toggle, False, False,2)

        self.plugins_toggle = Gtk.CheckButton(label="Enable Plugins")
        self.plugins_toggle.set_active(config['privacy'].get('plugins_enabled','yes')=='yes')
        privacy_tab.pack_start(self.plugins_toggle, False, False,2)

        self.autoplay_toggle = Gtk.CheckButton(label="Media Autoplay")
        self.autoplay_toggle.set_active(config['privacy'].get('media_autoplay','yes')=='yes')
        privacy_tab.pack_start(self.autoplay_toggle, False, False,2)

        self.track_toggle = Gtk.CheckButton(label="Tracking Protection")
        self.track_toggle.set_active(config['privacy'].get('tracking_protection','no')=='yes')
        privacy_tab.pack_start(self.track_toggle, False, False,2)

        self.fingerprint_toggle = Gtk.CheckButton(label="Fingerprint Protection")
        self.fingerprint_toggle.set_active(config['privacy'].get('fingerprint_protection','no')=='yes')
        privacy_tab.pack_start(self.fingerprint_toggle, False, False,2)

        notebook.append_page(privacy_tab, Gtk.Label(label="Privacy"))

        # --- Search/Home Tab ---
        search_tab = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        search_tab.pack_start(Gtk.Label(label="Default Search Engine:"), False, False,2)
        self.search_entry = Gtk.Entry()
        self.search_entry.set_text(config['general'].get('default_search_engine','ecosia'))
        search_tab.pack_start(self.search_entry, False, False,2)

        search_tab.pack_start(Gtk.Label(label="Homepage URL:"), False, False,2)
        self.home_entry = Gtk.Entry()
        self.home_entry.set_text(config['general'].get('homepage','about:blank'))
        search_tab.pack_start(self.home_entry, False, False,2)

        search_tab.pack_start(Gtk.Label(label="New tab behavior (blank/homepage/last):"), False, False,2)
        self.newtab_entry = Gtk.Entry()
        self.newtab_entry.set_text(config['general'].get('new_tab_behavior','blank'))
        search_tab.pack_start(self.newtab_entry, False, False,2)

        notebook.append_page(search_tab, Gtk.Label(label="Search/Home"))

        # --- Plugins Tab ---
        plugin_tab = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        self.adblock_toggle = Gtk.CheckButton(label="Adblock")
        self.adblock_toggle.set_active(config['plugins'].get('adblock','enabled')=='enabled')
        plugin_tab.pack_start(self.adblock_toggle, False, False,2)

        self.darkmode_toggle = Gtk.CheckButton(label="Dark Mode")
        self.darkmode_toggle.set_active(config['plugins'].get('dark_mode','disabled')=='enabled')
        plugin_tab.pack_start(self.darkmode_toggle, False, False,2)

        self.youtube_toggle = Gtk.CheckButton(label="YouTube Unhook")
        self.youtube_toggle.set_active(config['plugins'].get('youtube_unhook','disabled')=='enabled')
        plugin_tab.pack_start(self.youtube_toggle, False, False,2)

        notebook.append_page(plugin_tab, Gtk.Label(label="Plugins"))

        # --- Macros Tab ---
        macro_tab = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        macro_tab.pack_start(Gtk.Label(label="Add macro: label,url"), False, False,2)
        self.macro_entry = Gtk.Entry()
        macro_tab.pack_start(self.macro_entry, False, False,2)
        add_btn = Gtk.Button(label="Add Macro")
        add_btn.connect("clicked", self.add_macro)
        macro_tab.pack_start(add_btn, False, False,2)
        notebook.append_page(macro_tab, Gtk.Label(label="Macros"))

        # --- Save Button ---
        save_btn = Gtk.Button(label="Save Settings")
        save_btn.connect("clicked", self.save_settings)
        vbox.pack_end(save_btn, False, False,5)
        self.show_all()

    def add_macro(self, btn):
        text = self.macro_entry.get_text()
        if ',' in text:
            label,url = text.split(',',1)
            key = f"macro{len(config['macros'])+1}"
            config['macros'][key] = json.dumps({'label':label.strip(),'action':f"open_url('{url.strip()}')"})
            with open(config_path,'w') as f:
                config.write(f)
            if self.browser:
                self.browser.update_macros()
            self.macro_entry.set_text("")

    def save_settings(self, btn):
        config['general']['theme'] = self.theme_entry.get_text()
        config['general']['zen_opacity'] = self.opacity_entry.get_text()
        config['general']['sidebar_position'] = self.sidebar_entry.get_text()
        config['general']['tab_layout'] = self.tablayout_entry.get_text()
        config['general']['default_search_engine'] = self.search_entry.get_text()
        config['general']['homepage'] = self.home_entry.get_text()
        config['general']['new_tab_behavior'] = self.newtab_entry.get_text()
        config['general']['show_toolbar_buttons'] = 'yes' if self.toolbar_toggle.get_active() else 'no'
        config['general']['show_tab_titles'] = 'yes' if self.tabtitle_toggle.get_active() else 'no'
        config['privacy']['cookies_enabled'] = 'yes' if self.cookies_toggle.get_active() else 'no'
        config['privacy']['javascript_enabled'] = 'yes' if self.js_toggle.get_active() else 'no'
        config['privacy']['plugins_enabled'] = 'yes' if self.plugins_toggle.get_active() else 'no'
        config['privacy']['media_autoplay'] = 'yes' if self.autoplay_toggle.get_active() else 'no'
        config['privacy']['tracking_protection'] = 'yes' if self.track_toggle.get_active() else 'no'
        config['privacy']['fingerprint_protection'] = 'yes' if self.fingerprint_toggle.get_active() else 'no'
        config['plugins']['adblock'] = 'enabled' if self.adblock_toggle.get_active() else 'disabled'
        config['plugins']['dark_mode'] = 'enabled' if self.darkmode_toggle.get_active() else 'disabled'
        config['plugins']['youtube_unhook'] = 'enabled' if self.youtube_toggle.get_active() else 'disabled'
        with open(config_path,'w') as f:
            config.write(f)
        if self.browser:
            self.browser.apply_config()
        self.destroy()

# --- Browser ---
class BrowserWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="ZenPlus Browser")
        self.set_default_size(1200,800)
        self.tabs = []
        self.active_index = 0

        if config['general'].get('zen_mode','no')=='yes':
            self.get_style_context().add_class("window-background")

        main_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(main_vbox)

        toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        main_vbox.pack_start(toolbar, False, False, 0)
        win_controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        for label in ['_','⬜','X']:
            btn = Gtk.Button(label=label)
            btn.connect("clicked", self.window_control)
            win_controls.pack_start(btn, False, False,2)
        toolbar.pack_end(win_controls, False, False,2)

        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        main_vbox.pack_start(hbox, True, True,0)

        self.sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.sidebar.get_style_context().add_class("sidebar")
        hbox.pack_start(self.sidebar, False, False,0)

        self.url_entry = Gtk.Entry()
        self.url_entry.set_placeholder_text("Search or URL...")
        self.url_entry.get_style_context().add_class("url-entry")
        self.url_entry.connect("activate", self.on_search)
        self.sidebar.pack_start(self.url_entry, False, False,5)

        self.tab_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.sidebar.pack_start(self.tab_box, True, True,5)

        nav_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        back_btn = Gtk.Button(label="◀")
        back_btn.connect("clicked", lambda w:self.current_webview().go_back())
        forward_btn = Gtk.Button(label="▶")
        forward_btn.connect("clicked", lambda w:self.current_webview().go_forward())
        reload_btn = Gtk.Button(label="⟳")
        reload_btn.connect("clicked", lambda w:self.current_webview().reload())
        for btn in [back_btn, forward_btn, reload_btn]:
            nav_box.pack_start(btn, False, False,2)
        self.sidebar.pack_start(nav_box, False, False,5)

        new_tab_btn = Gtk.Button(label="New Tab")
        new_tab_btn.connect("clicked", self.new_tab)
        self.sidebar.pack_start(new_tab_btn, False, False,5)

        settings_btn = Gtk.Button(label="Settings")
        settings_btn.connect("clicked", self.open_config)
        self.sidebar.pack_end(settings_btn, False, False,5)

        self.webview_box = Gtk.Box()
        hbox.pack_start(self.webview_box, True, True,0)

        self.connect("key-press-event", self.on_keypress)

        self.new_tab()

    def current_webview(self):
        return self.tabs[self.active_index]['webview']

    def new_tab(self, widget=None, url=None, incognito=False):
        context = WebKit2.WebContext.new_ephemeral() if incognito else WebKit2.WebContext.get_default()
        if not incognito and config['privacy'].get('cookies_enabled','yes')=='yes':
            cookie_manager = context.get_cookie_manager()
            cookie_manager.set_persistent_storage(
                os.path.join(BASE_DIR,"cookies.db"),
                WebKit2.CookiePersistentStorage.SQLITE
            )

        webview = WebKit2.WebView.new_with_context(context)
        settings = WebKit2.Settings()
        settings.set_property("enable-javascript", config['privacy'].get('javascript_enabled','yes')=='yes')
        settings.set_property("enable-plugins", config['privacy'].get('plugins_enabled','yes')=='yes')
        settings.set_property("allow-modal-dialogs", True)
        settings.set_property("enable-fullscreen", True)
        settings.set_property("media-playback-requires-user-gesture", False)
        webview.set_settings(settings)

        if url is None:
            html = "<html><body style='background-color: rgba(30,30,30,0.5);'></body></html>"
            webview.load_html(html, "file://")
            url = "New Tab"
        else:
            webview.load_uri(url)

        self.tabs.append({'webview':webview,'title':url})
        index = len(self.tabs)-1
        self.active_index = index

        tab_btn = Gtk.Button(label=url)
        tab_btn.connect("clicked", lambda w,idx=index:self.switch_tab(idx))
        tab_btn.connect("button-press-event", lambda w,e,idx=index:self.middle_click_close(e,idx))
        tab_btn.get_style_context().add_class("tab")
        self.tab_box.pack_start(tab_btn, False, False,2)
        self.update_tab_styles()

        for child in self.webview_box.get_children():
            self.webview_box.remove(child)
        scrolled = Gtk.ScrolledWindow()
        scrolled.add(webview)
        self.webview_box.pack_start(scrolled, True, True,0)
        self.show_all()

    def middle_click_close(self, event, index):
        if event.type == Gdk.EventType.BUTTON_PRESS and event.button == 2:
            self.remove_tab(index)

    def remove_tab(self, index):
        self.tabs.pop(index)
        btn_to_remove = self.tab_box.get_children()[index]
        self.tab_box.remove(btn_to_remove)
        if self.active_index >= len(self.tabs):
            self.active_index = len(self.tabs)-1
        if self.tabs:
            self.switch_tab(self.active_index)
        self.show_all()

    def switch_tab(self, index):
        self.active_index = index
        webview = self.tabs[index]['webview']
        for child in self.webview_box.get_children():
            self.webview_box.remove(child)
        scrolled = Gtk.ScrolledWindow()
        scrolled.add(webview)
        self.webview_box.pack_start(scrolled, True, True,0)
        self.update_tab_styles()
        self.show_all()

    def update_tab_styles(self):
        for i,btn in enumerate(self.tab_box.get_children()):
            if i == self.active_index:
                btn.get_style_context().add_class("active")
            else:
                btn.get_style_context().remove_class("active")

    def on_search(self, entry):
        text = entry.get_text()
        if text.startswith("http://") or text.startswith("https://"):
            self.current_webview().load_uri(text)
        else:
            engine = config['general'].get('default_search_engine','ecosia')
            self.current_webview().load_uri(f"https://{engine}.org/search?q={text}")

    def open_config(self, widget=None):
        ConfigAgent(browser=self)

    def apply_config(self):
        if os.path.exists(css_path):
            css_provider.load_from_path(css_path)

    def update_macros(self):
        pass

    def window_control(self, widget):
        label = widget.get_label()
        if label=="_":
            self.iconify()
        elif label=="⬜":
            self.maximize()
        elif label=="X":
            Gtk.main_quit()

    def on_keypress(self, widget, event):
        key = Gdk.keyval_name(event.keyval)
        state = event.state
        if key=="Left" and state & Gdk.ModifierType.MOD1_MASK:
            self.current_webview().go_back()
        elif key=="Right" and state & Gdk.ModifierType.MOD1_MASK:
            self.current_webview().go_forward()
        elif key=="r" and state & Gdk.ModifierType.MOD1_MASK:
            self.current_webview().reload()


if __name__=="__main__":
    win = BrowserWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
