(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages version-control)
             (gnu packages screen)
             (gnu packages bash)
             (gnu packages fontutils)
             (gnu packages fonts)
             (guix gexp))

(home-environment
  ;; Packages installed directly into your user profile via Guix
  (packages
    (list git
          screen
          fontconfig              ; Provides 'fc-cache'
          font-dejavu             ; Standard UI fonts
          font-liberation         ; Standard web fallbacks
          font-google-noto))      ; Full unicode/glyph coverage

  ;; Services for managing dotfiles, environment variables, and activation hooks
  (services
    (list
     ;; 1. Configure Bash & PATH for Guix Home and Nix binaries
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
                                   "# Include Guix Home and Nix profile binaries in PATH\n"
                                   "export PATH=\"$HOME/.guix-home/profile/bin:$HOME/.guix-profile/bin:$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:$PATH\"\n"))))))

     ;; 2. Declaratively manage ~/.config/nix/nix.conf
     (simple-service 'nix-config-service
                     home-xdg-configuration-files-service-type
                     `(("nix/nix.conf"
                        ,(plain-file "nix.conf"
                                     "experimental-features = nix-command flakes\n"))))

     ;; 3. Automatically activate/add the Nix Flake on 'guix home reconfigure'
     (simple-service 'nix-flake-activation
                     home-activation-service-type
                     #~(system* "nix" "profile" "add"
                                (string-append "path:" (getenv "HOME") "/src/guix-system/nix"))))))
