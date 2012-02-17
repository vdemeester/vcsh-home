#/bin/sh
# vcsh-home bootstrap file
SELF="$(basename $0)"

check_cmds() {
# TODO: test if on debian or not
# test if command available
command -v git || {
    echo "$SELF: git is not available."
    exit 1
}
command -v vcsh || {
    echo "$SELF: vcsh is not available."
    exit 1
}
command -v mr || {
    echo "$SELF: mr is not available"
    exit 1
}
# TODO: test if command on apt (mainly vcsh version number)
}

check_cmds git mr vcsh

test -z "$HOOK_D" && HOOK_D=$HOME/.config/vcsh/hooks-enabled
test -z "$HOOK_A" && HOOK_A=$HOME/.config/vcsh/hooks-available

if ! test -d $HOOK_D; then
    mkdir -p $HOOK_D
fi
if ! test -d $HOOK_A; then
    mkdir -p $HOOK_A
fi

# Write the vcsh hooks
cat > $HOOK_A/post-setup.00-checkSparseCheckout << HOOK
#!/bin/sh
# vcsh hook for enabling git sparse-checkout
if ! test "$(git config core.sparseCheckout)" = "true"; then
    git config core.sparseCheckout true
fi
# vim: filetype=sh autoindent expandtab shiftwidth=4
HOOK
ln -s {$HOOK_A,$HOOK_D}/post-setup.00-checkSparseCheckout
chmod +x $HOOK_A/post-setup.00-checkSparseCheckout
cat > $HOOK_A/post-setup.01-READMEsparseCheckout << HOOK
#!/bin/sh
# vcsh hook that set a default sparseCheckout for README{,.md}
if ! test -e "$GIT_DIR/info/sparse-checkout"; then
    cat > $GIT_DIR/info/sparse-checkout << EOF
*
!README
!README.md
EOF
fi
HOOK
ln -s {$HOOK_A,$HOOK_D}/post-setup.01-READMEsparseCheckout
chmod +x $HOOK_A/post-setup.01-READMEsparseCheckout
# go home !
cd $HOME
# an init it !
vcsh clone git://nofau.lt/vincent/vcsh-home.git mr
