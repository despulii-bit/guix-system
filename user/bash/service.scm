;; user/bash/service.scm
(define-module (user bash service)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:export (bash-packages
            bash-home-services))

;; Bash itself ships as part of Guix Home's core support, so there's
;; nothing extra to pull in here. Kept as an empty list for parity with
;; the other service files, and as a natural place to add packages like
;; bash-completion later.
(define bash-packages
  (list))

(define bash-home-services
  (list
   ;; Ensure XDG_RUNTIME_DIR exists on login with 0700 permissions,
   ;; before any shell startup files run
   (simple-service 'create-xdg-runtime-dir
                   home-activation-service-type
                   #~(let ((dir (string-append "/tmp/runtime-" (number->string (getuid)))))
                       (mkdir-p dir)
                       (chmod dir #o700)))

   ;; Bash configuration: profile (login shells) + bashrc (interactive shells)
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (bash-profile
              (list (plain-file "bash_profile"
                                (string-append
                                 "# Set and export XDG_RUNTIME_DIR early on login\n"
                                 "export XDG_RUNTIME_DIR=\"/tmp/runtime-$(id -u)\"\n"
                                 "if [ ! -d \"$XDG_RUNTIME_DIR\" ]; then\n"
                                 "  mkdir -p -m 0700 \"$XDG_RUNTIME_DIR\"\n"
                                 "fi\n\n"
                                 "# Run Guix Home on-first-login script if skipped\n"
                                 "if [ -f \"$HOME/.guix-home/on-first-login\" ]; then\n"
                                 "  \"$HOME/.guix-home/on-first-login\"\n"
                                 "fi\n\n"
                                 "# Login shells don't source .bashrc automatically - pull it in\n"
                                 "# so PATH (Guix Home / Nix profile bins) is set before we exec dwl\n"
                                 "if [ -f \"$HOME/.bashrc\" ]; then\n"
                                 "  . \"$HOME/.bashrc\"\n"
                                 "fi\n"))))
             (bashrc
              (list (plain-file "bashrc"
                                (string-append
                                 "export EDITOR=nano\n"
                                 "alias ll='ls -l'\n"
                                 "alias chromium='chromium --disable-gpu'\n"
                                 "alias ungoogled-chromium='chromium --disable-gpu'\n\n"
                                 "# Include local bin, Guix Home, and Nix profile binaries in PATH\n"
                                 "export PATH=\"$HOME/.local/bin:$HOME/.guix-home/profile/bin:$HOME/.guix-profile/bin:$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:$PATH\"\n"))))))))
