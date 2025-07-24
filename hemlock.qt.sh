#!/bin/bash
clbuild lisp <<EOF
(asdf:operate 'asdf:load-op :hemlock/qt)
(hi::hemlock)
EOF
