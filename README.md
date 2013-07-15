Makefile to install blink softphone (http://icanblink.com/) on gentoo in a virtualenv.

Since there is a lot of dependencies from ag-projects and a small patch on python-gnutls, I choosed the virtualenv option to avoid polluting the system.

You need dev-python/virtualenv (for python 2.7) and dev-qt/qtwebkit installed.

To install just run:

        make install VENV_DIR=~/local/venv

If everything is okay, you can launch blink with ~/local/venv/bin/blink
