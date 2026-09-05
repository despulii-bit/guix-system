;; user/guix-home-config.scm
(use-modules (gnu home)
             (gnu home services)
             (gnu packages)
             (gnu packages linux)
             (gnu packages version-control)
             (gnu packages screen)
             (gnu packages ncurses)
             (guix gexp)
             (guix utils)
             (srfi srfi-1))

;; Get current directory reliably
(define %config-dir (current-source-directory))

;; 1. Load the relative module files into memory first
(load (string-append %config-dir "/dwl/service.scm"))
(load (string-append %config-dir "/kanshi/service.scm"))
(load (string-append %config-dir "/foot/service.scm"))
(load (string-append %config-dir "/emacs/service.scm"))
(load (string-append %config-dir "/bash/service.scm"))
(load (string-append %config-dir "/fuzzel/service.scm"))
(load (string-append %config-dir "/fontconfig/service.scm"))

;; 2. Import their exported variables
(use-modules (user dwl service)
             (user kanshi service)
             (user foot service)
             (user emacs service)
             (user bash service)
             (user fuzzel service)
             (user fontconfig service))

(home-environment
  (packages
    (append (list git
                  screen
                  brightnessctl
                  ncurses
                  (specification->package "ungoogled-chromium-wayland"))
            fontconfig-packages
            dwl-packages
            kanshi-packages
            foot-packages
            emacs-packages
            bash-packages
            fuzzel-packages))
  (services
    (append fontconfig-home-services
            dwl-home-services
            kanshi-home-services
            foot-home-services
            emacs-home-services
            bash-home-services
            fuzzel-home-services)))
