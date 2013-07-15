VENV_DIR = `pwd`/venv

URL = http://download.ag-projects.com/SipClient
URL_BLINK = http://download.ag-projects.com/BlinkQt/

DEPENDENCIES = sipclients-0.35.0 python-xcaplib-1.0.17 python-sipsimple-0.35.0 python-msrplib-0.15.0 python-eventlib-0.1.1 python-backports-1.0.1 blink-0.4.0
DEPS_TAR_GZ = $(patsubst %,%.tar.gz,$(DEPENDENCIES))

PYTHON_DEPENDENCIES = Cython python-cjson 

SIP_DEP = sip-4.14.7
SIP_DEP_TAR = $(SIP_DEP).tar.gz

PYQT_DEP = PyQt-x11-gpl-4.10.2
PYQT_DEP_TAR = $(PYQT_DEP).tar.gz

MANUAL_DEPS = $(SIP_DEP) $(PYQT_DEP)

DEPS_BLINK_TAR_GZ = blink-0.4.0.tar.gz
DEPS = $(patsubst %,%,$(DEPENDENCIES))

$(DEPS_TAR_GZ):
	wget $(URL)/$@

$(DEPS_BLINK_TAR_GZ):
	wget $(URL_BLINK)/$@

$(DEPENDENCIES): $(DEPS_TAR_GZ)
	tar -xf $@.tar.gz
	pushd $@; $(VENV_DIR)/bin/python setup.py -q install; popd

$(VENV_DIR): 
	virtualenv-2.7 $(VENV_DIR)
	# Need to copy include dir instead of symlink since sip install header
	unlink $(VENV_DIR)/include/python-2.7
	cp -r /usr/include/python2.7 $(VENV_DIR)/include/python-2.7

$(PYTHON_DEPENDENCIES): $(VENV_DIR)
	$(VENV_DIR)/bin/pip install -q $@

$(SIP_DEP_TAR):
	wget http://sourceforge.net/projects/pyqt/files/$(SIP_DEP)/$(SIP_DEP)/$(SIP_DEP_TAR)

$(PYQT_DEP_TAR):
	wget http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.10.2/PyQt-x11-gpl-4.10.2.tar.gz

$(MANUAL_DEPS): $(SIP_DEP_TAR) $(PYQT_DEP_TAR)
	tar -xf $@.tar.gz
	pushd $@; $(VENV_DIR)/bin/python configure.py -e $(VENV_DIR)/include/python2.7
	pushd $@; make install -j5; popd

install: $(MANUAL_DEPS) $(PYTHON_DEPENDENCIES) $(DEPS)
