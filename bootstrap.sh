#!/bin/sh
# This is my *vcsh-home* bootstrap file.
# To make a long story short, this script will initialize my home directory
# with share configuration in a new machine.
#
# Behind the scene, there is three required peice of software (available from
# debian repository, etc) :
#
# * git
# * vcsh
# * mr
#
# I use git for eveything, even my documents, pictures or music library. But
# for these, you will need git-annex too.
#
SELF="$(basename $0)"

# The most important line in any shell program.
set -e

# We will start by defining few useful functions.
#
# *log*: a wrapper of echo to print stuff in a more colorful way
log() {
    ECHO_ARGS=""
    test "$1" = "-n" && {
        ECHO_ARGS="-n"
        shift
    }
    echo $ECHO_ARGS "$(tput sgr0)$(tput setaf 2)>$(tput bold)>$(tput sgr0) $*"
}
# *warn*: a wrapper of echo to print stuff in a more colorful way, warning
warn() {
    test "$1" = "-n" && {
        ECHO_ARGS="-n"
        shift
    }
    echo $ECHO_ARGS "$(tput sgr0)$(tput setaf 3)<$(tput bold)<$(tput sgr0) $*"
}
# *fatal*: a wrapper of echo to print stuff in a more colorful way, error
fatal () {
    test "$1" = "-n" && {
        ECHO_ARGS="-n"
        shift
    }
    echo $ECHO_ARGS "$(tput sgr0)$(tput setaf 9)<$(tput bold)<$(tput sgr0) $*" >&2
    exit $2
}

# *check_cmd* : check a command and fail if not present
check_cmd() {
    command -v $1 >/dev/null && {
        echo "   $1"
    } || {
        echo ""
        warn "$1 is not available"
        echo
        exit 1
    }
}
# First, we check the precense of essential tools (git, vcsh, mr)
log "Checking needed commands :$(tput bold)"
check_cmd git

test -z "$HOME" && fatal '$HOME not set; exiting' 1

mkdir $HOME/tmp
cd $HOME/tmp

test -z "$HTTP_GET" && command -v wget >/dev/null && HTTP_GET='wget -nv'
test -z "$HTTP_GET" && command -v curl >/dev/null && HTTP_GET='curl -s -S -O'
test -z "$HTTP_GET" && fatal 'Unable to find wget or curl'

echo "$SELF: bootstrapping vcsh and mr with '$HTTP_GET'"

vcsh_root='https://raw.github.com/vdemeester/vcsh-home/master'

echo $HTTP_GET $vcsh_root/bin/vcsh
$HTTP_GET $vcsh_root/bin/vcsh
echo $HTTP_GET $vcsh_root/bin/mr
$HTTP_GET $vcsh_root/bin/mr


chmod 755 mr vcsh

cd $HOME

export PATH=$HOME/tmp:$PATH

# Next, we'll prepare for the initial bootstrap. It is basically :
# * Look at ``HOOK_D`` and ``HOOK_A`` variable if already defined
test -z "$HOOK_D" && HOOK_D=$HOME/.config/vcsh/hooks-enabled
test -z "$HOOK_A" && HOOK_A=$HOME/.config/vcsh/hooks-available
log "Preparing bootstrap:\n   Available hooks : $HOOK_A\n   Enabled hooks   : $HOOK_D"
# * Create folder if not present
test -d $HOOK_D || mkdir -p $HOOK_D
test -d $HOOK_A || mkdir -p $HOOK_A
# * Write initial vcsh hooks (to enable sparseCheckout and to ignore README)
log "Writing initial hooks: $(tput bold)"
# vcsh hook for enabling [sparseCheckout](http://www.kernel.org/pub/software/scm/git/docs/git-read-tree.html#_sparse_checkout).
# > "Sparse checkout" allows populating the working directory sparsely. It uses the skip-worktree bit (see git-update-index(1)) to tell Git whether a file in the working directory is worth looking at.
#
# This is very useful for the vcsh-enabled repository. I can document them with
# a README file so that other people can know what it does, but I don't want
# them to conflict when beeing used.
name="pre-upgrade.00-checkSparseCheckout"
cat > $HOOK_A/$name << HOOK
#!/bin/sh
if ! test "\$(git config core.sparseCheckout)" = "true"; then
    git config core.sparseCheckout true
fi
HOOK
ln -s $HOOK_A/$name $HOOK_D/$name
chmod +x $HOOK_A/$name
echo "   $name"
# vcsh hook for excluding README{,.md} using git sparseCheckout
name="pre-upgrade.01-defaultsparsecheckout"
cat > $HOOK_A/$name << HOOK
#!/bin/sh
if ! test $(grep $name \$GIT_DIR/info/sparse-checkout); then
    cat >> \$GIT_DIR/info/sparse-checkout << EOF
#/ from $name
*
EOF
fi
HOOK
chmod +x $HOOK_A/$name
ln -s $HOOK_A/$name $HOOK_D/$name
echo "   $name"
# vcsh hook for excluding README{,.md} using git sparseCheckout
name="pre-upgrade.02-READMEsparseCheckout"
cat > $HOOK_A/$name << HOOK
#!/bin/sh
if ! test $(grep $name \$GIT_DIR/info/sparse-checkout); then
    cat >> \$GIT_DIR/info/sparse-checkout << EOF
#/ from $name
!README
!README.md
!README.org
EOF
fi
HOOK
chmod +x $HOOK_A/$name
ln -s $HOOK_A/$name $HOOK_D/$name
echo "   $name"
# vcsh hook for excluding .gitignore using git sparseCheckout
name="pre-upgrade.02-GitignoresparseCheckout"
cat > $HOOK_A/$name << HOOK
#!/bin/sh
if ! test $(grep $name \$GIT_DIR/info/sparse-checkout); then
    cat >> \$GIT_DIR/info/sparse-checkout << EOF
#/ from $name
!.gitignore
EOF
fi
HOOK
chmod +x $HOOK_A/$name
ln -s $HOOK_A/$name $HOOK_D/$name
echo "   $name"
echo "$(tput sgr0)"

# * Clean some stuff (backup)
test -f $HOME/.profile && mv $HOME/.profile $HOME/.profile.orig
test -f $HOME/.bashrc && mv $HOME/.bashrc $HOME/.bashrc.orig
test -f $HOME/.bash_profile && mv $HOME/.bash_profile $HOME/.bash_profile.orig
test -f $HOME/.bash_logout && mv $HOME/.bash_logout $HOME/.bash_logout.orig
test -f $HOME/.zshrc && mv $HOME/.zshrc $HOME/.zshrc.orig
test -f $HOME/.zprofile && mv $HOME/.zprofile $HOME/.zprofile.orig
test -f $HOME/.zshenv && mv $HOME/.zshenv $HOME/.zshenv.orig
test -f $HOME/.zlogin && mv $HOME/.zlogin $HOME/.zlogin.orig
test -f $HOME/.zlogout && mv $HOME/.zlogout $HOME/.zlogout.orig

# * Clone the vcsh-home repository
log "Cloning vcsh-home"
vcsh clone git://github.com/vdemeester/vcsh-home.git vcsh-home

# Running mr in interactive mode on the most important one
log "Getting sh-config first"
vcsh  clone git://github.com/vdemeester/sh-config.git sh-config

# Update in a new shell (benefits the sh-config)
log "Updating everything in a new shell: $SHELL"
test -z "$SKIP_MRI" && $SHELL -c "mr -i -d .config u"
# Explain the user how to add configurations
log "That's it, you're home is now configured. \n You can add or remove configuration using vcsh."
