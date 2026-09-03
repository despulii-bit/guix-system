;; /etc/config.scm
(use-modules (gnu)
             (gnu packages window-management)
             (gnu services networking)
             (gnu services shepherd)          ; Added for shepherd-service-type
             (guix packages)
             (guix gexp)
             (guix utils)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules desktop xorg networking guix pm)
(use-package-modules linux firmware screen version-control admin terminals ncurses)

;; Custom package definition that injects your HHKB config.h into dwl
(define custom-dwl
  (package
    (inherit dwl)
    (arguments
     (substitute-keyword-arguments (package-arguments dwl)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-before 'build 'use-custom-config
              (lambda _
                (copy-file #$(local-file "/home/i/.config/dwl/config.h") "config.h")
                #t))))))))

;; Service to automatically create /tmp/runtime-1000 on boot for Wayland/dwl
(define create-user-runtime-dir-service
  (simple-service 'create-user-runtime-dir
                  shepherd-root-service-type
                  (list (shepherd-service
                          (provision '(user-runtime-dir))
                          (requirement '(file-systems))
                          (documentation "Create /tmp/runtime-1000 for user i.")
                          (start #~(lambda _
                                     (let ((dir "/tmp/runtime-1000"))
                                       (mkdir-p dir)
                                       (chown dir 1000 100) ; UID 1000 (user i), GID 100 (users)
                                       (chmod dir #o700))))
                          (one-shot? #t)))))

;; Service to set initial screen brightness to 1% at boot
(define boot-brightness-service
  (simple-service 'boot-brightness
                  shepherd-root-service-type
                  (list (shepherd-service
                          (provision '(set-boot-brightness))
                          (requirement '(udev))
                          (documentation "Set backlight brightness to 1% on boot.")
                          (start #~(lambda _
                                     (invoke #$(file-append brightnessctl "/bin/brightnessctl")
                                             "set" "1%")))
                          (one-shot? #t)))))

(operating-system
  (host-name "dl74")
  (timezone "America/New_York")
  (locale "en_US.utf8")

  ;; --- User Accounts Setup ---
  (users (cons (user-account
                 (name "i")
                 (comment "Default User")
                 (group "users")
                 (supplementary-groups '("wheel" "netdev" "audio" "video" "input" "seat")))
               %base-user-accounts))

  ;; Include custom dwl and essential Wayland tools globally
  (packages (cons* custom-dwl foot wmenu ncurses %base-packages))

  ;; --- Non-free Hardware Setup ---
  (kernel linux-lts)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  ;; --- Bootloader Setup ---
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))

  ;; --- Storage Configuration ---
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid "0a6f17dd-41ca-458c-924a-44770ac778cd"))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "0A06-3EA1" 'fat))
                         (type "vfat"))
                       %base-file-systems))

  (swap-devices (list (swap-space
                        (target (uuid "d998248e-e034-4db1-80a9-0d9fa1a64933")))))

  ;; --- Services ---
  (services
    (append (list 
                  ;; Creates /tmp/runtime-1000 at boot to prevent missing XDG_RUNTIME_DIR errors
                  create-user-runtime-dir-service

                  ;; Automatically sets brightness to 1% on startup
                  boot-brightness-service

                  ;; Seat management daemon for Wayland
                  (service seatd-service-type)

                  ;; Udev rules to allow video group non-root access to backlight devices
                  (simple-service 'brightness-udev-rules
                                  udev-service-type
                                  (list brightnessctl))

                  ;; Wi-Fi daemon required by NetworkManager
                  (service wpa-supplicant-service-type)

                  ;; Automatic network configuration via DHCP
                  (service network-manager-service-type)

                  ;; Non-free binary substitutes
                  (simple-service 'nonguix-substitutes
                                  guix-service-type
                                  (guix-extension
                                    (substitute-urls
                                      (append '("https://substitutes.nonguix.org")
                                              %default-substitute-urls))
                                    (authorized-keys
                                      (append (list (plain-file "nonguix.pub"
                                                                "(public-key (ecc (curve Ed25519) (q #C1F338F19428B2CE45A122E426D8D8CF058225736D2A6D5A704D8B6538E00C8D#)))"))
                                              %default-authorized-guix-keys)))))
            
            %base-services)))
