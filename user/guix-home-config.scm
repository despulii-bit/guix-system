;; user/guix-home-config.scm
(use-modules (gnu home)
             (gnu home services)
             (gnu packages linux)
             (gnu packages version-control)
             (gnu packages screen)
             (gnu packages fontutils)
             (gnu packages fonts)
             (guix gexp)
             (srfi srfi-1))

;; 1. Load the relative module files into memory first
(load (string-append (dirname (current-filename)) "/dwl/service.scm"))
(load (string-append (dirname (current-filename)) "/kanshi/service.scm"))
(load (string-append (dirname (current-filename)) "/foot/service.scm"))
(load (string-append (dirname (current-filename)) "/emacs/service.scm"))
(load (string-append (dirname (current-filename)) "/bash/service.scm"))

;; 2. Import their exported variables
(use-modules (user dwl service)
             (user kanshi service)
             (user foot service)
             (user emacs service)
             (user bash service))

(home-environment
  ;; Combine base packages + DWL packages + Kanshi packages + Foot packages
  ;; + Emacs packages + Bash packages
  (packages
    (append (list git
                  screen
                  brightnessctl
                  fontconfig
                  font-dejavu
                  font-liberation
                  font-google-noto)
            dwl-packages
            kanshi-packages
            foot-packages
            emacs-packages
            bash-packages))

  ;; Combine base services + DWL services + Kanshi services + Foot services
  ;; + Emacs services + Bash services
  (services
    (append (list
             ;; 1. Nix config service
             (simple-service 'nix-config-service
                             home-xdg-configuration-files-service-type
                             `(("nix/nix.conf"
                                ,(plain-file "nix.conf"
                                             "experimental-features = nix-command flakes\n"))))

             ;; 2. Nix Flake activation safely checking if Nix binary exists
             (simple-service 'nix-flake-activation
                             home-activation-service-type
                             #~(let ((nix-bin (or (false-if-exception (search-path (string-split (getenv "PATH") #\:) "nix"))
                                                  "/nix/var/nix/profiles/default/bin/nix")))
                                 (when (file-exists? nix-bin)
                                   (system* nix-bin "profile" "add"
                                            (string-append "path:" (getenv "HOME") "/src/guix-system/nix"))))))
            
            dwl-home-services
            kanshi-home-services
            foot-home-services
            emacs-home-services
            bash-home-services)))
