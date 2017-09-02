# sudo apt-get install g++ binutils libc6-dev-i386 VirtualBox grub-legacy xorriso



GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o gdt.o kernel.o

%.o: %.cpp
	g++ $(GPPPARAMS) -c -o $@ $<
	
%.o: %.s 
	as $(ASPARAMS) -o $@ $<
	
mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)
	
mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp mykernel.bin iso/boot/mykernel.bin
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo '' 	     >> iso/boot/grub/grub.cfg
	echo 'menuentry "Okton 0.1" {' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso/boot/grub/grub.cfg
	echo '	boot'			      >> iso/boot/grub/grub.cfg
	echo '}'			      >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=mykernel.iso iso

run : mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm 'Okton 0.1' &

install: mykernel.bin

	sudo cp $< /boot/mykernel.bin
