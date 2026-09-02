;; /etc/nonguix.scm
(define-module (nonguix-config)
  #:use-module (gnu services base)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (nonguix-kernel
            nonguix-initrd
            nonguix-firmware
            nonguix-substitute-service))

(define nonguix-kernel linux-lts)
(define nonguix-initrd microcode-initrd)
(define nonguix-firmware (list linux-firmware))

(define nonguix-substitute-service
  (simple-service 'nonguix-substitutes
                  guix-service-type
                  (guix-extension
                   (substitute-urls
                    (append '("https://substitutes.nonguix.org")
                            %default-substitute-urls)))))
