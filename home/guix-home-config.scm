(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages version-control)
             (gnu packages screen)
	     (guix gexp)
             (gnu packages bash))

(home-environment
  ;; Packages installed directly into your user profile
  (packages
    (list git
          screen))

  ;; Services for managing dotfiles and shell configurations
  (services
    (list
      (service home-bash-service-type
               (home-bash-configuration
                 (guix-defaults? #t)
                 (bashrc
                   (list (plain-file "bashrc"
                                     "export EDITOR=nano\nalias ll='ls -l'\n"))))))))
