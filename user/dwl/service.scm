;; user/dwl/service.scm
(define-module (user dwl service)
  #:use-module (gnu home services)
  #:use-module (gnu packages window-management)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:export (dwl-home-services
            dwl-packages))

;; Startup script that waits for WAYLAND_DISPLAY before running wlr-randr
(define dwl-startup-script
  (program-file
   "dwl-startup"
   #~(begin
       (use-modules (ice-9 popen))
       (system "while [ -z \"$WAYLAND_DISPLAY\" ]; do sleep 0.1; done; wlr-randr --output eDP-1 --off"))))

;; Managed dwl C configuration header generated as a store file
(define dwl-config-h-file
  (mixed-text-file
   "config.h"
   "/* Managed Declaratively via Guix Home */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \\
                        ((hex >> 16) & 0xFF) / 255.0f, \\
                        ((hex >> 8) & 0xFF) / 255.0f, \\
                        (hex & 0xFF) / 255.0f }

static const int sloppyfocus               = 1;
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 0;
static const float rootcolor[]             = COLOR(0x000000ff);
static const float bordercolor[]           = COLOR(0x000000ff);
static const float focuscolor[]            = COLOR(0x000000ff);
static const float urgentcolor[]           = COLOR(0xff5555ff);
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

#define TAGCOUNT (9)
static int log_level = WLR_ERROR;

static const Rule rules[] = {
    { \"foot\",      NULL,    0,            0,           -1 },
};

static const Layout layouts[] = {
    { \"[]=\",     tile },
    { \"><>\",     NULL },
    { \"[M]\",     monocle },
};

static const MonitorRule monrules[] = {
    { NULL,        0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

static const struct xkb_rule_names xkb_rules = {
    .options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define MODKEY WLR_MODIFIER_ALT

#define TAGKEYS(KEY,SKEY,TAG) \\
    { MODKEY,                                KEY,     view,           {.ui = 1 << TAG} }, \\
    { MODKEY|WLR_MODIFIER_CTRL,              KEY,     toggleview,     {.ui = 1 << TAG} }, \\
    { MODKEY|WLR_MODIFIER_SHIFT,              SKEY,    tag,            {.ui = 1 << TAG} }, \\
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag,     {.ui = 1 << TAG} }

/* Autostart array calling store script */
static const char *const autostart[] = {
    \"" dwl-startup-script "\", NULL,
    NULL /* terminate */
};

static const char *termcmd[] = { \"foot\", NULL };
static const char *menucmd[] = { \"wmenu-run\", NULL };

static const Key keys[] = {
    { MODKEY,                    XKB_KEY_p,         spawn,          {.v = menucmd} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,    spawn,          {.v = termcmd} },
    { MODKEY,                    XKB_KEY_j,         focusstack,     {.i = +1} },
    { MODKEY,                    XKB_KEY_k,         focusstack,     {.i = -1} },
    { MODKEY,                    XKB_KEY_i,         incnmaster,     {.i = +1} },
    { MODKEY,                    XKB_KEY_d,         incnmaster,     {.i = -1} },
    { MODKEY,                    XKB_KEY_h,         setmfact,       {.f = -0.05f} },
    { MODKEY,                    XKB_KEY_l,         setmfact,       {.f = +0.05f} },
    { MODKEY,                    XKB_KEY_Return,    zoom,           {0} },
    { MODKEY,                    XKB_KEY_Tab,       view,           {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c,         killclient,     {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,         killclient,     {0} },
    { MODKEY,                    XKB_KEY_t,         setlayout,      {.v = &layouts[0]} },
    { MODKEY,                    XKB_KEY_f,         setlayout,      {.v = &layouts[1]} },
    { MODKEY,                    XKB_KEY_m,         setlayout,      {.v = &layouts[2]} },
    { MODKEY,                    XKB_KEY_space,     setlayout,      {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,     togglefloating, {0} },
    { MODKEY,                    XKB_KEY_e,         togglefullscreen, {0} },
    { MODKEY,                    XKB_KEY_0,         view,           {.ui = ~0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },
    { MODKEY,                    XKB_KEY_comma,     focusmon,       {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_period,    focusmon,       {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },
    TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                    0),
    TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                        1),
    TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                2),
    TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                    3),
    TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                   4),
    TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,               5),
    TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                 6),
    TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                  7),
    TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                 8),
    { MODKEY|WLR_MODIFIER_SHIFT|WLR_MODIFIER_CTRL, XKB_KEY_q, quit,     {0} },

#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
    { MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
    { MODKEY, BTN_MIDDLE, togglefloating, {0} },
    { MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
"))

(define custom-dwl
  (package
    (inherit dwl)
    (arguments
     (substitute-keyword-arguments (package-arguments dwl)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-before 'build 'apply-custom-config
              (lambda _
                (copy-file #$dwl-config-h-file "config.h")))))))))

(define dwl-packages
  (list custom-dwl
        wlr-randr))

(define dwl-home-services
  (list
   (simple-service 'dwl-config-service
                   home-xdg-configuration-files-service-type
                   `(("dwl/config.h" ,dwl-config-h-file)))))
