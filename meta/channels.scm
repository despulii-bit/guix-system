(cons* (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       (channel
        (name 'guix)
        (url "https://codeberg.org/guix/guix.git")
        (branch "master")
        (introduction
         (make-channel-introduction
          "9edb3f66a35182f6c445698d656a4237f08046a7"
          (openpgp-fingerprint
           "BBB0 4DDF 2ECF 63D4 6D30  207F 22F2 915B 6D56 E5A8"))))
       (cdr %default-channels))
