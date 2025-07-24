#!/bin/bash
clbuild lisp <<EOF
(asdf:operate 'asdf:load-op :hemlock/tty)
(hi::old-hemlock)
EOF
