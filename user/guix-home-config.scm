;; user/guix-home-config.scm
(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages linux)
             (gnu packages version-control)
             (gnu packages screen)
             (gnu packages bash)
             (gnu packages fontutils)
             (gnu packages fonts)
             (guix gexp)
             (srfi srfi-1))

;; Load the dwl service file relative to the current directory
(load (string-append (dirname (current-filename)) "/dwl/service.scm"))

(home-environment
  ;; Base packages + packages from DWL module
  (packages
    (append (list git
                  screen
                  brightnessctl
                  fontconfig
                  font-dejavu
                  font-liberation
                  font-google-noto)
            dwl-packages))

  ;; Base services + DWL services
  (services
    (append (list
             ;; 1. Ensure runtime directory is created on login with 0700 permissions
             (simple-service 'create-xdg-runtime-dir
                             home-activation-service-type
                             #~(let ((dir (string-append "/tmp/runtime-" (number->string (getuid)))))
                                 (mkdir-p dir)
                                 (chmod dir #o700)))

             ;; 2. Shell configuration
             (service home-bash-service-type
                      (home-bash-configuration
                       (guix-defaults? #t)
                       (bashrc
                        (list (plain-file "bashrc"
                                          (string-append
                                           "export EDITOR=nano\n"
                                           "alias ll='ls -l'\n"
                                           "alias chromium='chromium --disable-gpu'\n"
                                           "alias ungoogled-chromium='chromium --disable-gpu'\n\n"
                                           "# Set XDG_RUNTIME_DIR if not already set by system login\n"
                                           "if [ -z \"$XDG_RUNTIME_DIR\" ]; then\n"
                                           "  export XDG_RUNTIME_DIR=\"/tmp/runtime-$(id -u)\"\n"
                                           "fi\n\n"
                                           "# Include Guix Home and Nix profile binaries in PATH\n"
                                           "export PATH=\"$HOME/.guix-home/profile/bin:$HOME/.guix-profile/bin:$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:$PATH\"\n"))))))

             ;; 3. Nix config service
             (simple-service 'nix-config-service
                             home-xdg-configuration-files-service-type
                             `(("nix/nix.conf"
                                ,(plain-file "nix.conf"
                                             "experimental-features = nix-command flakes\n"))))

             ;; 4. Nix Flake activation safely checking if Nix binary exists
             (simple-service 'nix-flake-activation
                             home-activation-service-type
                             #~(let ((nix-bin (or (false-if-exception (search-path (string-split (getenv "PATH") #\:) "nix"))
                                                  "/nix/var/nix/profiles/default/bin/nix")))
                                 (when (file-exists? nix-bin)
                                   (system* nix-bin "profile" "add"
                                            (string-append "path:" (getenv "HOME") "/src/guix-system/nix"))))))
            
            dwl-home-services)))
