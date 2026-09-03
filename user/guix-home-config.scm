(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages linux)             ; Added for brightnessctl
             (gnu packages wm)                ; Added for kanshi and wlr-randr
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
          brightnessctl                   ; Brightness control CLI
          kanshi                          ; Dynamic display autoconfig daemon
          wlr-randr                       ; Command-line tool for Wayland display management
          fontconfig                      ; Provides 'fc-cache'
          font-dejavu                      ; Standard UI fonts
          font-liberation                  ; Standard web fallbacks
          font-google-noto))              ; Full unicode/glyph coverage

  ;; Services for managing dotfiles, environment variables, and activation hooks
  (services
    (list
     ;; 1. Global Environment Variables (Sourced before shells start)
     (simple-service 'set-xdg-runtime-dir
                     home-environment-variables-service-type
                     `(("XDG_RUNTIME_DIR" . ,(string-append "/tmp/runtime-" (number->string (getuid))))))

     ;; 2. Ensure runtime directory folder exists on activation
     (simple-service 'create-xdg-runtime-dir
                     home-activation-service-type
                     #~(let ((dir (string-append "/tmp/runtime-" (number->string (getuid)))))
                         (mkdir-p dir)
                         (chmod dir #o700)))

     ;; 3. Configure Bash & PATH for Guix Home and Nix binaries
     (service home-bash-service-type
              (home-bash-configuration
               (guix-defaults? #t)
               (bashrc
                (list (plain-file "bashrc"
                                  (string-append
                                   "export EDITOR=nano\n"
                                   "alias ll='ls -l'\n"
                                   "alias dwl='dwl -s ~/.config/dwl/autostart.sh'\n"
                                   "alias chromium='chromium --disable-gpu'\n"
                                   "alias ungoogled-chromium='chromium --disable-gpu'\n\n"
                                   "# Include Guix Home and Nix profile binaries in PATH\n"
                                   "export PATH=\"$HOME/.guix-home/profile/bin:$HOME/.guix-profile/bin:$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:$PATH\"\n"))))))

     ;; 4. Declaratively manage ~/.config/kanshi/config for auto-display switching
     (simple-service 'kanshi-config-service
                     home-xdg-configuration-files-service-type
                     `(("kanshi/config"
                        ,(plain-file "kanshi-config"
                                     (string-append
                                      "# Fallback: Laptop screen only when no external display is present\n"
                                      "profile laptop_only {\n"
                                      "  output eDP-1 enable\n"
                                      "}\n\n"
                                      "# When HDMI is connected: disable laptop screen, enable external display\n"
                                      "profile external_only {\n"
                                      "  output eDP-1 disable\n"
                                      "  output HDMI-A-1 enable\n"
                                      "}\n")))))

     ;; 5. Declaratively manage ~/.config/nix/nix.conf
     (simple-service 'nix-config-service
                     home-xdg-configuration-files-service-type
                     `(("nix/nix.conf"
                        ,(plain-file "nix.conf"
                                     "experimental-features = nix-command flakes\n"))))

     ;; 6. Automatically activate/add the Nix Flake on 'guix home reconfigure'
     (simple-service 'nix-flake-activation
                     home-activation-service-type
                     #~(system* "nix" "profile" "add"
                                (string-append "path:" (getenv "HOME") "/src/guix-system/nix"))))))
