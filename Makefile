SOURCE_LINK=http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.3/OpenCV-2.4.3.tar.bz2

TARBALL_NAME=$(shell echo $(SOURCE_LINK) | sed -e 's/.*\///g')

VERSION=$(shell echo $(TARBALL_NAME) | sed -e 's/\.tar\.bz2//g ; s/OpenCV-//')

ROOT=tmp/libopencv-all-$(VERSION)_amd64

DEST=usr/opencv-$(VERSION)

all:	deb

deb:	$(ROOT)
	dpkg-deb --build $(ROOT)
	
$(ROOT):	opencv debian/control
	mkdir -p $(ROOT)/$(DEST)
	mkdir -p $(ROOT)/DEBIAN
	cp -rf debian/* $(ROOT)/DEBIAN/
	sed -i -e 's/\$$VERSION/$(VERSION)/' $(ROOT)/DEBIAN/control
	mkdir -p $(ROOT)/etc/ld.so.conf.d
	echo "/$(DEST)/lib" > $(ROOT)/etc/ld.so.conf.d/libopencv-all.conf


opencv: $(TARBALL_NAME)
	mkdir -p opencv
	tar -C opencv --strip-components=1 -jxvf $(TARBALL_NAME)
	cd opencv ; cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=../$(ROOT)/$(DEST) . && make -j$(nproc) && make install
	mkdir -p $(ROOT)/usr/local/include
	mv $(ROOT)/$(DEST)/include/* $(ROOT)/usr/local/include

$(TARBALL_NAME):
	wget $(SOURCE_LINK)

.PHONY:
clean-opencv:
	rm -rf opencv
	rm $(TARBALL_NAME)

.PHONY:
clean-deb:
	rm -rf tmp
.PHONY:
clean: clean-opencv clean-deb

