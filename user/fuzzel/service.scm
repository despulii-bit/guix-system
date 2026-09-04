;; user/fuzzel/service.scm
(define-module (user fuzzel service)
  #:use-module (gnu home services)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix gexp)
  #:export (fuzzel-packages
            fuzzel-home-services))

;; Packages required for the fuzzel application launcher
(define fuzzel-packages
  (list fuzzel))

;; Fuzzel INI configuration - matches the "Pitch Black / Minimalist Low
;; Contrast" palette used by foot and the Emacs theme.
(define fuzzel-ini-config
  "[main]
font=monospace:size=14
lines=8
width=40
prompt='> '
icon-theme=hicolor
terminal=foot

[colors]
background=000000ff
text=7f8c8dff
match=466a6eff
selection=1c1c1cff
selection-text=a0a0a0ff
selection-match=466a6eff
border=505050ff

[border]
width=1
radius=0
")

(define fuzzel-home-services
  (list
   ;; Declaratively manage ~/.config/fuzzel/fuzzel.ini
   (simple-service 'fuzzel-config-service
                   home-xdg-configuration-files-service-type
                   `(("fuzzel/fuzzel.ini" ,(plain-file "fuzzel.ini" fuzzel-ini-config))))))
