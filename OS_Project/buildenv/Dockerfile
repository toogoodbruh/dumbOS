#FROM--platform=linux/amd64 randomdude/gcc-cross-x86_64-elf

FROM randomdude/gcc-cross-x86_64-elf

RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install -y nasm
RUN apt-get install -y xorriso
RUN apt-get install -y grub-pc-bin
RUN apt-get install -y grub-common

VOLUME /root/env
WORKDIR /root/env

#create instance of this image:
#docker build buildenv -t myos-buildenv
#Linux/macOS:   docker run --rm -it -v $PWD:/root/env myos-buildenv
#Windows:       docker run --rm -it -v %cd%:/root/env myos-buildenv
# remove docker image: docker rmi myos-buildenv -f
#run qemu i386 emulator: qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso