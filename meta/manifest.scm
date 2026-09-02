;; ~/.config/guix/manifest.scm
(specifications->manifest
  '(;; Core Utilities & Shell
    "bash"
    "coreutils"
    "git"
    "screen"
    "htop"
    "curl"
    "wget"

    ;; System info & diagnostics
    "pciutils"
    "usbutils"
    "lshw"))
