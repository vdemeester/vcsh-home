#/bin/sh
# vcsh-home bootstrap file

check_cmds() {
# test if on debian or not
# test if command available
# test if command on apt (mainly vcsh version number)
}

check_cmds git mr vcsh

test -z "$HOOK_D" && HOOK_D=$HOME/.config/vcsh/hooks-enabled

if ! test -d $HOOK_D; then
    mkdir -p $HOOK_D
fi

cat > $HOOK_D/mr.post-setup << HOOK
#!/bin/sh
# mr vcsh post-setup hook
if ! test "$(git config core.sparseCheckout)" = "true"; then
    git config core.sparseCheckout true
fi
if ! test -e "$GIT_DIR/info/sparse-checkout"; then
    cat > $GIT_DIR/info/sparse-checkout << EOF
*
!README
!README.md
!bootstrap.sh
EOF
fi
HOOK

