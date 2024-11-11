#create instance of this image:
#docker build buildenv -t myos-buildenv
#Linux/macOS:   docker run --rm -it -v $PWD:/root/env myos-buildenv
#Windows:       docker run --rm -it -v %cd%:/root/env myos-buildenv
# remove docker image: docker rmi myos-buildenv -f
#run qemu i386 emulator: qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso
