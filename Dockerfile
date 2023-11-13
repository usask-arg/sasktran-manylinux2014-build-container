from quay.io/pypa/manylinux2014_x86_64:2023-11-07-de0c444

RUN yum -y update && yum -y install wget openssh openssh-clients

# Setup the SSH Deploy key
ARG SSH_PRV_KEY
ARG SSH_PUB_KEY

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan arggit.usask.ca > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$SSH_PRV_KEY" > /root/.ssh/id_rsa && \
    echo "$SSH_PUB_KEY" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub



ENV INSTALLPREFIX /usr/local

# lapack
RUN cd ~ && wget -nv https://github.com/xianyi/OpenBLAS/releases/download/v0.3.18/OpenBLAS-0.3.18.tar.gz && tar xf OpenBLAS-0.3.18.tar.gz
RUN mkdir ~/OpenBLAS-0.3.18/build && cd ~/OpenBLAS-0.3.18/build && cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DBUILD_SHARED_LIBS:bool=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true -DLAPACKE:BOOL=on && cmake --build . && cmake --install .

# Eigen
RUN cd ~ && wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz && tar xf eigen-3.4.0.tar.gz
RUN mkdir ~/eigen-3.4.0/build && cd ~/eigen-3.4.0/build && cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DBUILD_SHARED_LIBS:bool=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true && cmake --build . && cmake --install . > /dev/null 2>&1

# Boost installation
RUN cd ~ && wget -nv https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz && tar xf boost_1_77_0.tar.gz 
RUN cd ~/boost_1_77_0 && ./bootstrap.sh && ./b2 cxxflags="-fPIC" cflags="-fPIC" link=static --without-python install

#zlib ugh
RUN cd ~ && wget -nv https://zlib.net/current/zlib.tar.gz && tar xf zlib.tar.gz 
RUN mkdir ~/zlib-1.3/build && cd ~/zlib-1.3/build && cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true && cmake --build . && cmake --install . > /dev/null 2>&1
# zlib builds shared libraries anyways so we remove them to force static link
# although I'm pretty sure netcdf is dynamically linking system zlib anyway even though hdf5 complains about it
RUN rm -rf /usr/local/lib/libz.so*

#hdf5
RUN cd ~ && wget -nv https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_1.tar.gz && tar xf hdf5-1_12_1.tar.gz 
RUN mkdir ~/hdf5-hdf5-1_12_1/build && cd ~/hdf5-hdf5-1_12_1/build && cmake ../ -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON -DZLIB_DIR=/lib/x86_x64-linux-gnu/ && cmake --build . && cmake --install . > /dev/null 2>&1

# netcdf-c, if we statically link against hdf5 we have to explicitly link lz and ldl
RUN cd ~ && wget -nv https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz && tar xf v4.8.1.tar.gz
RUN mkdir ~/netcdf-c-4.8.1/build && cd ~/netcdf-c-4.8.1/build && cmake ../ -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true -DBUILD_UTILITIES:bool=OFF -DENABLE_DAP:BOOL=off -DCMAKE_EXE_LINKER_FLAGS="-lz -ldl" -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX && cmake --build . && cmake --install . > /dev/null 2>&1

# yaml-cpp
RUN cd ~ && wget -nv https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.7.0.tar.gz && tar xf yaml-cpp-0.7.0.tar.gz 
RUN mkdir ~/yaml-cpp-yaml-cpp-0.7.0/build && cd ~/yaml-cpp-yaml-cpp-0.7.0/build && cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true && cmake --build . && cmake --install . > /dev/null 2>&1

# catch2
RUN cd ~ && wget -nv https://github.com/catchorg/Catch2/archive/refs/tags/v3.3.2.tar.gz && tar xf v3.3.2.tar.gz 
RUN mkdir ~/Catch2-3.3.2/build && cd ~/Catch2-3.3.2/build && cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALLPREFIX -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true && cmake --build . && cmake --install . > /dev/null 2>&1

# Install numpy in the python environments, use the oldest version that has a manylinux wheel for each environment
# NOTE: this is using the oldest semimajor version and ignoring the minor version, I don't know if the minor version affects ABI
RUN /opt/python/cp38-cp38/bin/pip install numpy==1.17.5
RUN /opt/python/cp39-cp39/bin/pip install numpy==1.19.5
RUN /opt/python/cp310-cp310/bin/pip install numpy==1.21.4
RUN /opt/python/cp311-cp311/bin/pip install numpy==1.23.5
RUN /opt/python/cp312-cp312/bin/pip install numpy==1.26.0


