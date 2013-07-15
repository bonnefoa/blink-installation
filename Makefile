# Need package dev-qt/qtwebkit

VENV_DIR = ~/git-repos/blink-install/venv

SIP_BASE_URL = http://download.ag-projects.com/SipClient
MANUAL_DEPS = sipclients-0.35.0 python-xcaplib-1.0.17 python-sipsimple-0.35.0 python-msrplib-0.15.0 python-eventlib-0.1.1 python-backports-1.0.1 
DEPS_TAR_GZ = $(patsubst %,%.tar.gz,$(MANUAL_DEPS))

PIP_DEPENDENCIES = Cython python-cjson python-application zope.app.interface greenlet twisted dnspython lxml python-dateutil

GNU_DEP = python-gnutls-1.2.4
GNU_DEP_TAR = python-gnutls-1.2.4.tar.gz

SIP_DEP = sip-4.14.7
SIP_DEP_TAR = $(SIP_DEP).tar.gz

PYQT_DEP = PyQt-x11-gpl-4.10.2
PYQT_DEP_TAR = $(PYQT_DEP).tar.gz

QT_DEPS = $(SIP_DEP) $(PYQT_DEP) $(GNU_DEP)

DEPS_BLINK = blink-0.4.0
DEPS_BLINK_TAR_GZ = blink-0.4.0.tar.gz

TARGET_FILES = $(VENV_DIR)/include/python2.7/sip.h $(VENV_DIR)/bin/blink $(VENV_DIR)/lib/python2.7/site-packages/PyQt4/Qt.so $(VENV_DIR)/lib/python2.7/site-packages/gnutls

$(DEPS_TAR_GZ):
	wget $(SIP_BASE_URL)/$@

$(DEPS_BLINK_TAR_GZ):
	wget http://download.ag-projects.com/BlinkQt/blink-0.4.0.tar.gz

$(SIP_DEP_TAR):
	wget http://sourceforge.net/projects/pyqt/files/sip/sip-4.14.7/sip-4.14.7.tar.gz

$(PYQT_DEP_TAR):
	wget http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.10.2/PyQt-x11-gpl-4.10.2.tar.gz

$(GNU_DEP_TAR):
	wget https://pypi.python.org/packages/source/p/python-gnutls/python-gnutls-1.2.4.tar.gz#md5=e3536c421291a791869d875a41dcb26a

$(MANUAL_DEPS): $(DEPS_TAR_GZ)
	tar -xf $@.tar.gz

$(DEPS_BLINK): $(DEPS_BLINK_TAR_GZ)
	tar -xf $@.tar.gz

$(VENV_DIR): 
	virtualenv-2.7 $(VENV_DIR)
	# Need to copy include dir instead of symlink since sip install header
	unlink $(VENV_DIR)/include/python2.7
	cp -r /usr/include/python2.7 $(VENV_DIR)/include/python2.7
	$(foreach DEP,$(PIP_DEPENDENCIES), $(VENV_DIR)/bin/pip install -q $(DEP);)

install_manual_deps: $(VENV_DIR) $(MANUAL_DEPS)
	$(foreach DEP,$(MANUAL_DEPS), pushd $(DEP); $(VENV_DIR)/bin/python setup.py -q install; pushd;)

$(QT_DEPS): $(SIP_DEP_TAR) $(PYQT_DEP_TAR) $(GNU_DEP_TAR)
	tar -xf $@.tar.gz

$(VENV_DIR)/include/python2.7/sip.h: $(VENV_DIR) $(QT_DEPS) 
	pushd $(SIP_DEP); \
		$(VENV_DIR)/bin/python configure.py -e $(VENV_DIR)/include/python2.7; \
		make -j5 ;\
		make install ;\
		popd;

$(VENV_DIR)/lib/python2.7/site-packages/PyQt4/Qt.so: $(VENV_DIR) $(QT_DEPS) 
	pushd $(PYQT_DEP); \
		$(VENV_DIR)/bin/python configure.py --confirm-license; \
		make -j5 ;\
		make install;\
		popd;

$(VENV_DIR)/lib/python2.7/site-packages/gnutls: $(GNU_DEP)
	patch --quiet -N $(GNU_DEP)/gnutls/library/__init__.py gnu.diff
	pushd $(GNU_DEP); \
		$(VENV_DIR)/bin/python setup.py install; \
		popd;

$(VENV_DIR)/bin/blink: install_manual_deps $(DEPS_BLINK) $(VENV_DIR)/include/python2.7/sip.h
	pushd $(DEPS_BLINK); $(VENV_DIR)/bin/python setup.py -q install; popd;

install: $(TARGET_FILES)
