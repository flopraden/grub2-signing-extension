# Makefile for grub2-sign-extension
# Author: Bandie
# Licence: GNU-GPLv3

all: 
	@printf "Nothing to make. Run make install.\n"

install:
	install -D -m744 src/grub-verify /usr/local/sbin/grub-verify
	install -D -m744 src/grub-sign /usr/local/sbin/grub-sign
	install -D -m744 src/grub-unsign /usr/local/sbin/grub-unsign
	@printf "Script installed in /usr/local/sbin."
	./scripts/install-conf
	@printf "Configfile installed in /etc/grub-sign."
uninstall:
	rm -f /usr/local/sbin/grub-{verify,sign,unsign}
	@printf "Script uninstalled from /usr/local/sbin."
purge: uninstall
	rm -rf /etc/grub-sign
	@printf "Configfile removed from /etc/grub-sign."
