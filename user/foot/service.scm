;; user/foot/service.scm
(use-modules (gnu home services)
             (gnu packages terminals)
             (guix gexp))

;; Packages required for Foot terminal setup
(define foot-packages
  (list foot))

;; Foot INI configuration string - Pitch Black / Minimalist Low Contrast
(define foot-ini-config
  "[main]
term=foot
font=monospace:size=16
dpi-aware=yes
pad=8x8

[colors-dark]
alpha=1.0
background=000000
foreground=7f8c8d

## Selection and Cursor (Low Contrast / Dark Gray Highlight)
selection-foreground=a0a0a0
selection-background=1c1c1c
jump-labels=000000 4e5d6c

## Normal colors (Desaturated & Dimmed)
regular0=0d0d0d # black
regular1=5c3a3a # muted dark red
regular2=3a5c43 # muted dark green
regular3=5c533a # muted dark yellow
regular4=3a4b5c # muted dark blue
regular5=4e3a5c # muted dark magenta
regular6=3a585c # muted dark cyan
regular7=505050 # dim gray

## Bright colors (Overridden to remain dim/low-contrast)
bright0=1a1a1a # dark gray
bright1=6e4646 # low-contrast red
bright2=466e52 # low-contrast green
bright3=6e6446 # low-contrast yellow
bright4=465a6e # low-contrast blue
bright5=5e466e # low-contrast magenta
bright6=466a6e # low-contrast cyan
bright7=707070 # muted light gray

[csd]
preferred=server
")

(define foot-home-services
  (list
   ;; Declaratively manage ~/.config/foot/foot.ini
   (simple-service 'foot-config-service
                   home-xdg-configuration-files-service-type
                   `(("foot/foot.ini" ,(plain-file "foot.ini" foot-ini-config))))))
