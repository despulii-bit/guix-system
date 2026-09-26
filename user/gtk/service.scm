;; user/gtk/service.scm
(define-module (user gtk service)
  #:use-module (gnu home services)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (guix gexp)
  #:export (gtk-packages
            gtk-home-services))

;; Packages needed for GTK dark theme, portal support, and settings
(define gtk-packages
  (list xdg-desktop-portal
        xdg-desktop-portal-gtk
        adwaita-icon-theme
        glib)) ;; provides gsettings

;; GTK 3 & 4 settings forcing dark theme
(define gtk3-ini-config
  "[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
")

(define gtk4-ini-config
  "[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
")

(define gtk-home-services
  (list
   ;; Force GTK environment variable globally for user session
   (simple-service 'gtk-environment-variables
                   home-environment-variables-service-type
                   '(("GTK_THEME" . "Adwaita:dark")))

   ;; Write configuration files for GTK 3 and GTK 4
   (simple-service 'gtk-config-service
                   home-xdg-configuration-files-service-type
                   `(("gtk-3.0/settings.ini"
                      ,(plain-file "gtk3-settings.ini" gtk3-ini-config))
                     ("gtk-4.0/settings.ini"
                      ,(plain-file "gtk4-settings.ini" gtk4-ini-config))))))
