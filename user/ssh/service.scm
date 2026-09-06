(define-module (user ssh service)
  #:use-module (gnu home services ssh)
  #:use-module (gnu services)
  #:export (ssh-home-service))

(define ssh-home-service
  (service home-openssh-service-type
           (home-openssh-configuration
            (hosts
             (list
              ;; Proxmox VE
              (openssh-host
               (name "pve")
               (host-name "192.168.1.110")
               (user "root")
               (identity-file "~/.ssh/id_ed25519_homelab"))

              ;; Dungaroo Home Server (Local LAN)
              (openssh-host
               (name "dungaroo")
               (host-name "192.168.1.214")
               (user "i")
               (identity-file "~/.ssh/id_ed25519_void")
               (extra-content "    IdentitiesOnly yes\n"))

              ;; GitHub (ytaudit)
              (openssh-host
               (name "github.com-ytaudit")
               (host-name "github.com")
               (user "git")
               (identity-file "~/.ssh/id_ed25519_void")
               (extra-content "    IdentitiesOnly yes\n")))))))
