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

    $ bash < <(curl -s "https://raw.github.com/vdemeester/vcsh-home/bootstrap/bootstrap.sh")
    
# How it is supposed to work

As previously said, this repository is kind of a skeleton for all of  my others configuration
repositories. The idea is :

* You *bootstrap* this one (a little more stuff to do than just a ``git clone``).
* Then you clone other repositories with vcsh (``vcsh clone git://github.com/vdemeester/sh-config`` for example).
* When you want to update, you have the choice :
  * ``vcsh pull`` to pull **just** the configuration repositories
  * ``mr u`` to pull the configuration repositories and their potential dependencies/externals..

As you can see in other configuration repository (like https://github.com/vdemeester/sh-config) there is README
file that won't be checked out by vcsh when cloning. As explaine [there (#120)](https://github.com/RichiH/vcsh/issues/120#issuecomment-42639619), I just use together to hook feature of vcsh
and the sparse-checkout feature of git.

[1]: https://github.com/RichiH/vcsh (vcsh)
[2]: http://kitenet.net/~joey/code/mr/ (http://kitenet.net/~joey/code/mr/)
