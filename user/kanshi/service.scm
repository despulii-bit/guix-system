;; user/kanshi/service.scm
(define-module (user kanshi service)
  #:use-module (gnu home services)
  #:use-module (gnu packages window-management)
  #:use-module (guix gexp)
  #:export (kanshi-packages
            kanshi-home-services))

(define kanshi-packages
  (list kanshi))

(define kanshi-home-services
  (list
   ;; Managed ~/.config/kanshi/config
   (simple-service 'kanshi-config-service
                   home-xdg-configuration-files-service-type
                   `(("kanshi/config"
                      ,(plain-file "kanshi-config"
                                   (string-append
                                    "profile external_only {\n"
                                    "  output HDMI-A-1 enable mode 1920x1080@60Hz position 0,0\n"
                                    "  output eDP-1 disable\n"
                                    "}\n\n"
                                    "profile laptop_only {\n"
                                    "  output eDP-1 enable mode 1920x1080@60.049Hz position 0,0\n"
                                    "}\n")))))))
