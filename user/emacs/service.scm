;; user/emacs/service.scm
(define-module (user emacs service)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs)
  #:use-module (guix gexp)
  #:export (emacs-packages
            emacs-home-services))

;; Packages required for Emacs setup
(define emacs-packages
  (list emacs))

;; Emacs theme mirroring the "Pitch Black / Minimalist Low Contrast" foot palette
(define emacs-theme-config
  "(deftheme pitch-black
  \"Pitch Black / Minimalist Low Contrast theme matching the foot terminal colors.\")

(let ((bg        \"#000000\")
      (fg        \"#7f8c8d\")
      (sel-bg    \"#1c1c1c\")
      (sel-fg    \"#a0a0a0\")
      (black     \"#0d0d0d\")
      (black-b   \"#1a1a1a\")
      (red       \"#5c3a3a\")
      (red-b     \"#6e4646\")
      (green     \"#3a5c43\")
      (green-b   \"#466e52\")
      (yellow    \"#5c533a\")
      (yellow-b  \"#6e6446\")
      (blue      \"#3a4b5c\")
      (blue-b    \"#465a6e\")
      (magenta   \"#4e3a5c\")
      (magenta-b \"#5e466e\")
      (cyan      \"#3a585c\")
      (cyan-b    \"#466a6e\")
      (gray      \"#505050\")
      (gray-b    \"#707070\"))
  (custom-theme-set-faces
   'pitch-black
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,gray-b))))
   `(region ((t (:background ,sel-bg :foreground ,sel-fg))))
   `(fringe ((t (:background ,bg))))
   `(mode-line ((t (:background ,black-b :foreground ,fg :box nil))))
   `(mode-line-inactive ((t (:background ,black :foreground ,gray :box nil))))
   `(minibuffer-prompt ((t (:foreground ,blue-b :weight bold))))
   `(line-number ((t (:foreground ,black-b :background ,bg))))
   `(line-number-current-line ((t (:foreground ,gray-b :background ,black :weight bold))))
   `(font-lock-comment-face ((t (:foreground ,gray :slant italic))))
   `(font-lock-string-face ((t (:foreground ,green-b))))
   `(font-lock-keyword-face ((t (:foreground ,blue-b :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,cyan-b))))
   `(font-lock-variable-name-face ((t (:foreground ,yellow-b))))
   `(font-lock-type-face ((t (:foreground ,magenta-b))))
   `(font-lock-constant-face ((t (:foreground ,red-b))))
   `(font-lock-builtin-face ((t (:foreground ,cyan))))
   `(font-lock-warning-face ((t (:foreground ,red-b :weight bold))))
   `(error ((t (:foreground ,red-b :weight bold))))
   `(warning ((t (:foreground ,yellow-b :weight bold))))
   `(success ((t (:foreground ,green-b :weight bold))))
   `(link ((t (:foreground ,blue-b :underline t))))
   `(isearch ((t (:background ,yellow :foreground ,bg))))
   `(lazy-highlight ((t (:background ,black-b :foreground ,gray-b))))
   `(show-paren-match ((t (:background ,sel-bg :foreground ,sel-fg :weight bold))))
   `(vertical-border ((t (:foreground ,black-b))))))

(provide-theme 'pitch-black)
")

;; Emacs init.el - loads the theme above and sets a few sane minimalist defaults
;; consistent with the low-contrast, no-frills feel of the foot config.
(define emacs-init-config
  "\
;; init.el - Guix Home managed

;; Make sure our custom theme (installed alongside this file) is found
(setq custom-theme-directory (expand-file-name \"themes\" user-emacs-directory))
(add-to-list 'custom-theme-load-path custom-theme-directory)
(load-theme 'pitch-black t)

;; Minimalist, low-chrome defaults to match the foot terminal aesthetic
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(column-number-mode t)
(global-display-line-numbers-mode t)
(setq-default cursor-type 'bar)
")

(define emacs-home-services
  (list
   ;; Declaratively manage ~/.config/emacs/init.el and the pitch-black theme
   (simple-service 'emacs-config-service
                   home-xdg-configuration-files-service-type
                   `(("emacs/init.el"
                      ,(plain-file "init.el" emacs-init-config))
                     ("emacs/themes/pitch-black-theme.el"
                      ,(plain-file "pitch-black-theme.el" emacs-theme-config))))))
