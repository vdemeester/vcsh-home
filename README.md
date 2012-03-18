                         __           __                            
    .--.--..----..-----.|  |--.______|  |--..-----..--------..-----.
    |  |  ||  __||__ --||     |______|     ||  _  ||        ||  -__|
     \___/ |____||_____||__|__|      |__|__||_____||__|__|__||_____|


vcsh "home" repository. This repository is used with [vcsh] [1] with the default
directory layout, powered by [mr] [2].

> vcsh allows you to have several git repositories, all maintaining their working
> trees in $HOME without clobbering each other. That, in turn, means you can have
> one repository per config set (zsh, vim, ssh, etc), picking and choosing which
> configs you want to use on which machine.
> <small>vcsh README file</small>

The default *enabled* repositories are mr (this one), sh (which contains the
shell configuration [bash,zsh,…]) and vim.

The convention I used is the following for the vcsh/mr configuration (`.vcsh`)
is to omit the `-config` fo the filename, e.g. `sh` = `sh-config`, … 

# Requirements

You'll have to install [mr] [2] and [vcsh] [1]. On debian the packages are
available for sid, wheezy and in the [squeeze-backports](http://backports-master.debian.org/).

    # apt-get install -t squeeze-backports mr vcsh

<del>This repository currently depend on the `hook_support` branch of my vcsh fork
on github. Maybe someday it'll be merged upstream. The master branch of my fork
is merge with the `hook_support`.</del>

# Using it

A branch is made for *bootstraping* the default configuration (with the vcsh hooks, etc…).
If you like *on-liner command*, here is one for you.

    $ bash < <(curl -s "http://code.nofau.lt/vincent/vcsh-home.git/plain/bootstrap.sh?h=bootstrap")

[1]: https://github.com/RichiH/vcsh (vcsh)
[2]: http://kitenet.net/~joey/code/mr/ (http://kitenet.net/~joey/code/mr/)
