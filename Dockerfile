FROM ubuntu:bionic

ARG LLVM_VERSION=9
ENV LLVM_VERSION=$LLVM_VERSION

ARG KERNEL_VERSION=5.0.21
ARG KERNEL_RELEASE=5.0.0-32-generic
ARG BCC_VERSION=0.8.0
ARG BPFTRACE_VERSION=0.9.2

RUN apt-get update && apt-get install -y curl gnupg &&\
    llvmRepository="\n\
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main\n\
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main\n\
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-${LLVM_VERSION} main\n\
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-${LLVM_VERSION} main\n" &&\
    echo $llvmRepository >> /etc/apt/sources.list && \
    curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4052245BD4284CDD && \
    echo "deb https://repo.iovisor.org/apt/bionic bionic main" | tee /etc/apt/sources.list.d/iovisor.list


RUN apt-get update && apt-get install -y \
      wget \
      bison \
      cmake \
      flex \
      g++ \
      git \
      libelf-dev \
      zlib1g-dev \
      libbcc \
      clang-${LLVM_VERSION} \
      libclang-${LLVM_VERSION}-dev \
      libclang-common-${LLVM_VERSION}-dev \
      libclang1-${LLVM_VERSION} \
      llvm-${LLVM_VERSION} \
      llvm-${LLVM_VERSION}-dev \
      llvm-${LLVM_VERSION}-runtime \
      libllvm${LLVM_VERSION} \
      systemtap-sdt-dev \
      python3 \ 
      luajit \
      luajit-5.1-dev

# download and build kernel
RUN MAJOR_VERSION=$(echo $KERNEL_VERSION | awk -F. '{ print $1 }') && \
    KERNEL_VERSION_ADJUSTED=$(echo $KERNEL_VERSION | awk -F. '{OFS = "."}{ if ($2==$3 && $3=="0") print $1,$2; else print $1,$2,$3; }' ) && \
    wget -qO- https://www.kernel.org/pub/linux/kernel/v$MAJOR_VERSION.x/linux-$KERNEL_VERSION_ADJUSTED.tar.gz | tar -C /srv -xzf - && \
    mv /srv/linux-$KERNEL_VERSION_ADJUSTED /srv/linux && \
    cd /srv/linux && \
    make defconfig && \
    make oldconfig && \
    make modules_prepare && \
    make modules && \
    make modules_install && \
    make clean

# download and build bcc
RUN wget -qO- https://github.com/iovisor/bcc/archive/v$BCC_VERSION.tar.gz | tar -C / -xzf - && \
    mv /bcc-$BCC_VERSION /bcc && \
    cd /bcc && mkdir build && cd build && cmake .. && make install -j4 && \
    cp src/cc/libbcc.a /usr/local/lib64/libbcc.a && \
    cp src/cc/libbcc-loader-static.a /usr/local/lib64/libbcc-loader-static.a && \
    cp src/cc/libbpf.a /usr/local/lib64/libbpf.a


# download and build bpftrace
RUN wget -qO- https://github.com/iovisor/bpftrace/archive/v$BPFTRACE_VERSION.tar.gz | tar -C / -xzf - && \
    mv /bpftrace-$BPFTRACE_VERSION /bpftrace && \
    STATIC_LINKING=ON RUN_TESTS=0 /bin/sh /bpftrace/docker/build.sh "/bpftrace/build-release" Release "$@" && \
    cd /bpftrace/build-release && \
    make && \
    make install

# prepare minimum kernel files to move into final image
RUN mkdir -p /srv/slim-linux/include/linux /srv/slim-linux/include/generated /srv/slim-linux/arch/x86/include/uapi/asm \
    /srv/slim-linux/include/uapi/linux /srv/slim-linux/include/uapi/asm-generic /srv/slim-linux/include/uapi/asm \  
    /srv/slim-linux/include/asm-generic /srv/slim-linux/include/asm && \ 
    cp /srv/linux/include/asm-generic/int-ll64.h /srv/slim-linux/include/asm-generic/int-ll64.h && \
    cp /srv/linux/include/asm-generic/bitsperlong.h /srv/slim-linux/include/asm-generic/bitsperlong.h && \
    cp /srv/linux/include/generated/autoconf.h /srv/slim-linux/include/generated/autoconf.h && \
    cp /srv/linux/include/linux/types.h /srv/slim-linux/include/linux/types.h && \
    cp /srv/linux/include/linux/compiler_types.h /srv/slim-linux/include/linux/compiler_types.h && \
    cp /srv/linux/include/linux/compiler_attributes.h /srv/slim-linux/include/linux/compiler_attributes.h && \
    cp /srv/linux/include/linux/compiler-clang.h /srv/slim-linux/include/linux/compiler-clang.h && \
    cp /srv/linux/include/uapi/linux/bpf* /srv/slim-linux/include/uapi/linux/ && \
    cp /srv/linux/include/uapi/linux/types.h /srv/slim-linux/include/uapi/linux/types.h && \
    cp /srv/linux/include/uapi/linux/posix_types.h /srv/slim-linux/include/uapi/linux/posix_types.h && \
    cp /srv/linux/include/uapi/linux/stddef.h /srv/slim-linux/include/uapi/linux/stddef.h && \
    cp /srv/linux/include/uapi/asm-generic/int-ll64.h /srv/slim-linux/include/uapi/asm-generic/int-ll64.h && \
    cp /srv/linux/include/uapi/asm-generic/types.h /srv/slim-linux/include/uapi/asm-generic/types.h && \
    cp /srv/linux/include/uapi/asm-generic/posix_types.h /srv/slim-linux/include/uapi/asm-generic/posix_types.h && \
    cp /srv/linux/include/uapi/asm-generic/bitsperlong.h /srv/slim-linux/include/uapi/asm-generic/bitsperlong.h && \
    cp /srv/linux/arch/x86/include/uapi/asm/types.h /srv/slim-linux/arch/x86/include/uapi/asm/types.h && \
    cp /srv/linux/arch/x86/include/uapi/asm/posix_types.h /srv/slim-linux/arch/x86/include/uapi/asm/posix_types.h && \
    cp /srv/linux/arch/x86/include/uapi/asm/bitsperlong.h /srv/slim-linux/arch/x86/include/uapi/asm/bitsperlong.h && \
    cp -r /srv/linux/arch/x86/* /srv/slim-linux/arch/x86 && \  
    cp /srv/linux/include/linux/kconfig.h /srv/slim-linux/include/linux/kconfig.h


# prepare scripts to check kernel features and create symlink based on kernel release
RUN mkdir /scripts && \
    cp /bpftrace/scripts/check_kernel_features.sh /scripts && \
    echo "./bpftrace/scripts/check_kernel_features.sh\n" > /scripts/init.sh && \
    echo "ln -sf /lib/modules/$KERNEL_VERSION /lib/modules/\$(uname -r)" > /scripts/init.sh && \
    chmod +x /scripts/init.sh


# # push only necessary files into alpine:latest
# FROM ubuntu:bionic

# COPY --from=build /lib/modules/ /lib/modules/
# COPY --from=build /srv/slim-linux/ /srv/linux/
# COPY --from=build /scripts /
# COPY --from=build /bpftrace/build-release/src/bpftrace /bin
# COPY --from=build /usr/local/share/bpftrace/tools/* /bin/
# ENV PATH $PATH:/bin
# CMD ["/bin/bpftrace"]