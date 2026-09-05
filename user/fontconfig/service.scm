;; user/fontconfig/service.scm
(define-module (user fontconfig service)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (guix gexp)
  #:export (fontconfig-packages
            fontconfig-home-services))

;; Font packages to be installed in the profile
(define fontconfig-packages
  (list fontconfig
        font-dejavu
        font-liberation
        font-google-noto))

;; Extend the built-in fontconfig service with your extra directories
(define fontconfig-home-services
  (list
   (simple-service 'extra-fontconfig-dirs
                   home-fontconfig-service-type
                   (list "~/.guix-home/profile/share/fonts"
                         "/run/current-system/profile/share/fonts"
                         "~/.guix-profile/share/fonts"
                         "~/.local/share/fonts"))))
