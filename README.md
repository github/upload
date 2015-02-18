**NOTE: This repository is no longer supported or updated by GitHub. If you wish to continue to develop this code yourself, we recommend you fork it.**

GitHub Upload Script
====================

`github_upload` is a command line utility to allow quick uploading of files to non-repo storage on GitHub.

If can be used from within a local repo, or given an explicit repo name to upload to.

In repo:

    $ cd my_local_repo
    $ github_upload file_to_upload

Explicit:

    $ github_upload file_to_upload myname/myrepo

github_upload requires you have Ruby and a few gems installed.  See below for details.


Install
-------

`github_upload` is most easily installed as a standalone script:

    $ curl -s http://github.com/github/upload/raw/master/upload.rb > ~/bin/github_upload
    $ chmod 755 ~/bin/github_upload
    $ gem install xml-simple mime-types

Assuming `~/bin/` is in your `$PATH`, you just need to set your git config and you're ready to roll.

Setup
-----

To use this script you need to have your GitHub username and token stored in your git config.

To test it run this:

    $ git config --global github.user
    $ git config --global github.token

If you see nothing, you need to set the config setting:

    $ git config --global github.user YOUR_USER
    $ git config --global github.token YOUR_TOKEN

See <http://help.github.com/git-email-settings/> for more information.
