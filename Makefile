 #############################################################################
 # Copyright (c) 2020 Cisco and/or its affiliates.
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at:
 #
 #     http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 ##############################################################################

default.target: help

export BASE_DIR=$(shell pwd)
export QT_HOME=`pwd`/Qt
export QT_VERSION=5.13.2
export QT_VERSION_INSTALL=5132
export QT_CI_PACKAGES=qt.qt5.${QT_VERSION_INSTALL}.ios,qt.qt5.${QT_VERSION_INSTALL}.qtcharts.ios,qt.qt5.${QT_VERSION_INSTALL}.qtcharts

BREW_INSTALLED := $(shell eval which brew | wc -l	)
TAP_INSTALLED := $(shell eval brew tap  | grep icn-team/hicn-tap | wc -l)

init:
	@mkdir -p usr/lib && mkdir -p usr/include && mkdir -p src && mkdir -p qt

init_qt:
	@echo "ciao"
	#@mkdir -p qt
	#@if [ ! -d ${BASE_DIR}/qt/Qt ]; then \
	#	if [ -z ${QT_CI_LOGIN} ] || [ -z ${QT_CI_PASSWORD} ]; then \
	#		echo "QT_CI_LOGIN and/or QT_CI_PASSWORD not set."; \
	#		echo "export QT_CI_LOGIN=<qt username>"; \
	#		echo "export QT_CI_PASSWORD=<qt password>"; \
	#		echo "If you don't have a qt account, please create a new one on:"; \
	#		echo "https://login.qt.io/register"; \
	#		exit 1; \
	#	else \
	#		cd qt && if [ ! -d qtci ]; then git clone https://github.com/benlau/qtci.git; fi && export PATH=`pwd`/qtci/bin:`pwd`/qtci/recipes:"${PATH}" && install-qt ${QT_VERSION} && rm qt-opensource* && rm -rf qtci && rm -rf Qt/MaintenanceTool.app && rm -rf Examples && rm -rf Docs && rm -rf Qt\ Creator.app; \
	#	fi; \
	#fi

install_hicn_tap:
	@if [ ${BREW_INSTALLED} -eq 1 ] && [ ${TAP_INSTALLED} -ne 0 ]; then \
		brew install hicn; \
	fi

openssl_download: init
	@cd src && if [ ! -d openssl ]; then if [ ! -f openssl-1.1.1e.tar.gz ]; then wget https://www.openssl.org/source/openssl-1.1.1e.tar.gz; fi;  tar xf openssl-1.1.1e.tar.gz && mv openssl-1.1.1e openssl && rm -rf openssl-1.1.1e.tar.gz; fi

openssl_src: openssl_download

	@mkdir -p build/openssl && cd build/openssl && ${BASE_DIR}/src/openssl/Configure --prefix=${BASE_DIR}/usr --openssldir=${BASE_DIR}/src/openssl/ no-ssl3 no-ssl3-method no-zlib  darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 && make -j && make install
	
download_libevent: init
	@cd ${BASE_DIR}/src && if [ ! -d libevent ]; then echo "libevent not found"; git clone https://github.com/libevent/libevent.git; cd libevent; git checkout tags/release-2.1.11-stable; fi;

libevent_src: download_libevent
	@mkdir -p build/libevent && cd build/libevent && cmake ${BASE_DIR}/src/libevent -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr -DOPENSSL_ROOT_DIR=${BASE_DIR}/usr -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON -DEVENT__HAVE_EPOLL=OFF -DEVENT__HAVE_PIPE2=OFF -DEVENT__DISABLE_BENCHMARK=ON && make -j && make -j && make install

download_libparc: init
	@cd ${BASE_DIR}/src && if [ ! -d cframework ]; then echo "cframework not found"; git clone -b cframework/master https://gerrit.fd.io/r/cicn cframework; fi;

libparc_src: download_libparc
	@mkdir -p build/libparc && cd build/libparc && cmake ${BASE_DIR}/src/cframework/libparc -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr -DOPENSSL_ROOT_DIR=${BASE_DIR}/usr -DDISABLE_EXECUTABLES=ON && make -j && make install

download_libconfig: init
	@cd ${BASE_DIR}/src && if [ ! -d libconfig ]; then echo "libconfig not found"; git clone https://github.com/hyperrealm/libconfig.git; cd libconfig; git checkout a6b370e78578f5bf594f8efe0802cdc9b9d18f1a; fi;

libconfig_src: download_libconfig
	@mkdir -p build/libconfig && cd build/libconfig && cmake ${BASE_DIR}/src/libconfig/ -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF && make -j && make -j && make install

download_asio: init
	@cd ${BASE_DIR}/src && if [ ! -d asio ]; then echo "Asio directory not found"; git clone https://github.com/chriskohlhoff/asio.git; cd asio; git checkout tags/asio-1-12-2;	fi;

asio_src: download_asio
	@if [ ! -d ${BASE_DIR}/usr/include/asio ]; then cp -r ${BASE_DIR}/src/asio/asio/include/asio* ${BASE_DIR}/usr/include/; fi;

download_hicn: init
	@cd ${BASE_DIR}/src && if [ ! -d hicn ]; then echo "libhicn not found"; git clone https://github.com/FDio/hicn.git; fi;

hicn_src: download_hicn
	@mkdir -p build/hicn/OS64 && cd build/hicn/OS64 && cmake ${BASE_DIR}/src/hicn -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr  -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr -DOPENSSL_ROOT_DIR=${BASE_DIR}/usr -DDISABLE_EXECUTABLES=ON && make -j && make install

download_curl: init
	@cd ${BASE_DIR}/src && if [ ! -d curl ]; then echo "curl not found"; git clone https://github.com/curl/curl.git; cd curl; git checkout tags/curl-7_66_0; fi;

curl_src: download_curl
	@mkdir -p build/curl && cd build/curl && cmake ${BASE_DIR}/src/curl  -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr  -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr -DOPENSSL_ROOT_DIR=${BASE_DIR}/usr -DBUILD_CURL_EXE=OFF -DBUILD_TESTING=OFF && make -j && make install

#download_ffmpeg: init
#	@cd ${BASE_DIR}/src && if [ ! -d ffmpeg ]; then if [ ! -f ffmpeg-4.2-iOS-lite.tar.gz ]; then echo "ffmpeg not found"; wget https://iweb.dl.sourceforge.net/project/avbuild/iOS/ffmpeg-4.2-iOS-lite.tar.xz; fi; tar xf ffmpeg-4.2-iOS-lite.tar.xz; rm -rf ffmpeg-4.2-iOS-lite.tar.xz; mv ffmpeg-4.2-iOS-lite ffmpeg; fi;

#ffmpeg: download_ffmpeg
#	@if [ ! -d ${BASE_DIR}/usr/include/libavcodec ] || [ ! -d ${BASE_DIR}/usr/include/libavfilter ] || [ ! -d ${BASE_DIR}/usr/include/libswresample ] || [ ! -d ${BASE_DIR}/usr/include/libavformat ] || [ ! -d ${BASE_DIR}/usr/include/libavutil ] || [ ! -d ${BASE_DIR}/usr/include/libswscale ]; then cp -rf ${BASE_DIR}/src/ffmpeg/include/* ${BASE_DIR}/usr/include/ ; cp -rf ${BASE_DIR}/src/ffmpeg/lib/* ${BASE_DIR}/usr/lib/; fi;

download_qtav: init
	@cd ${BASE_DIR}/src && if [ ! -d QtAV ]; then echo "qtav not found"; git clone https://github.com/wang-bin/QtAV.git; cd QtAV; git checkout 0307c174a4197fd33b1c1e7d37406d1ee5df6c82; git submodule update --init; sed -i '' 's/\/usr\/share\/doc/.\/usr\/share\/doc/' deploy.pri; echo "INCLUDEPATH = ${BASE_DIR}/usr/include/" > .qmake.conf; echo "LIBS = -L${BASE_DIR}/usr/lib/" >> .qmake.conf; fi;

qtav: download_qtav
	@mkdir -p ${BASE_DIR}/build/qtav && cd ${BASE_DIR}/build/qtav && ${BASE_DIR}/qt/Qt/${QT_VERSION}/ios/bin/qmake ${BASE_DIR}/src/QtAV "target.path = ${BASE_DIR}/qt/Qt/5.13.2/ios" "CONFIG+=no-examples release" "share.path=${BASE_DIR}/qt/doc" && make && make install && bash sdk_install.sh
	
update_hicn: init
	@if [ -d ${BASE_DIR}/src/hicn ]; then cd ${BASE_DIR}/src/hicn; git pull; fi;

download_viper: init
	@cd ${BASE_DIR}/src && if [ ! -d viper ]; then echo "viper not found"; git clone https://github.com/FDio/cicn.git -b viper/master viper;  fi;

libdash_src: download_viper
	@mkdir -p build/libdash && cd build/libdash && cmake ${BASE_DIR}/src/viper/libdash -DCMAKE_FIND_ROOT_PATH=${BASE_DIR}/usr  -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/usr && make -j && make install



update_libparc: init
	@if [ -d ${BASE_DIR}/src/cframework ]; then cd ${BASE_DIR}/src/cframework; git pull; fi;

update: update_libparc update_hicn

all: openssl libevent libconfig asio libparc hicn

all_src: openssl_src libevent_src libconfig_src asio_src libparc_src hicn_src

qt_dep: init_qt ffmpeg qtav curl libdash

all_qt: qt_dep all

help:
	@echo "---- Basic build targets ----"
	@echo "make all					- Compile hICN libraries and the dependencies"
	@echo "make all_qt					- Compile hICN libraries, install the Qt environment and build all the dependencies"
	@echo "make init_qt					- Install the Qt environment"
	@echo "make openssl					- Compile openssl"
	@echo "make download_libevent				- Download libevent"
	@echo "make libevent					- Download and compile libevent"
	@echo "make download_libparc				- Download libparc source code"
	@echo "make libparc					- Download and compile libparc"
	@echo "make download_libconfig				- Download libconfig source code"
	@echo "make libconfig					- Download and compile libconfig"
	@echo "make download_asio				- Download asio source code"
	@echo "make asio					- Download and install asio"
	@echo "make download_hicn				- Download hicn source code"
	@echo "make hicn					- Download and compile hicn"
	@echo "make download_ffmpeg				- Download ffmpeg libs"
	@echo "make ffmpeg					- Download and install ffmpeg"
	@echo "make download_curl				- Download libcurl source code"
	@echo "make hicn					- Download and compile libcurl"
	@echo "make download_qtav				- Download qtav source code"
	@echo "make qtav					- Download and compile qtav"
	@echo "make download_viper				- Download viper and libdash source code"
	@echo "make build_libdash				- Download viper and libdash and compile libdash" 
	@echo "make update					- Update hicn and libparc source code"
	@echo "make update_hicn				- Update hicn source code"
	@echo "make update_libparc				- Update libparc source code"	
