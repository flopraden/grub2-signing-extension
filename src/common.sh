## Common bash function for sign/verify grub gpg signature

# Define color
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)


# Find file to be signed/verified
# Parameter: none
# Descr:
#        Return list of file (delimited by \0 )
#          which should be sign or verified
# Return:
#  + none
# Erase:
#  + FILES: list of file as array
declare -a FILES;
list-all-file() {
    FILES=()
    mapfile -d $'\0' FILES < <(find "${BOOTDIR}" -name "*.cfg" -or \
                                    -name "*.lst" -or -name "*.mod" -or \
                                    -name "vmlinuz*" -or -name "initrd*" -or \
                                    -name "grubenv" -or -name "*.asc" -or \
                                    -name "*.pf2" -or -name "*.efi" -or \
                                    -name "*.elf" -or -name "*.bin" -or \
                                    -name "*-generic" -or -name "*.jpg" -or \
                                    -name "*.png" -or -name "*.mo" \
                                    -print0);
    return 0;
}

# Sign file given in $1
# Parameters:
#  + $1 filename to sign
#  + $2 quiet mode: 1 to enable
# Descr:
#       Create a detached signature for grub file in $1.sig
#       Remove the $1.sig if present
#       If quiet is on, just return error code, no printing
#          if error, set the ERR global variable to the ouput of GPG
# Return:
#  + ret code of 
# Erase:
#  + ERR if quiet=1
sign-file() {
    local file="$1";
    local quiet="$2";
    # Remove sign if present
    if [[ -e "${file}.sig" ]]; then
        rm -f "${file}.sig";
    fi;

    out=$(gpg --homedir "${GPGDIR}" ${GPGARGS} --batch --detach-sign --no-tty "${file}" 2>&1)
    ret=$?
    if [[  "x${quiet}" == "x1"]]; then
        if [ ${ret} -eq 0 ]; then
            # Clean out if no error
            out=""
        fi;
        ERR="${out}"
        return ${ret};
    fi;
    if [ ${ret} -eq 0 ]; then
        echo -e " ${green}signed${normal}."
    else
        echo -e " ${red}not signed: ERROR!${normal}"
        echo " ===== out ======"
        echo "${out}"
        echo " ================"
    fi
    return ${ret}
}

# Verify file given in $1
# Parameters:
#  + $1 filename to sign
#  + $2 quiet mode: 1 to enable
# Descr:
#       Verify a detached signature for grub file in $1.sig
#       If quiet is on, just return error code, no printing
#          if error, set the ERR global variable to the ouput of GPG
# Erase:
#  + ERR if quiet=1
verif-file() {
    local file="$1";
    local quiet="$2";
    # test if a signature is present
    if [[ ! -e "${file}.sig" ]]; then
        if [[  "x${quiet}" != "x1"]]; then
            echo -e " ${yellow}sign missing!${normal}"
        fi;
        return 3
    fi;

    # Testing signature
    out=$(gpg --homedir "${GPGDIR}" ${GPGARGS} --batch --no-tty --verify-files "${file}.sig" 2>&1)
    ret=$?
    
    if [[  "x${quiet}" == "x1"]]; then
        if [ ${ret} -eq 0 ]; then
            # Clean out if no error
            out=""
        fi;
        ERR="${out}"
        return ${ret};
    fi;
    if [ ${ret} -eq 0 ]; then
        echo -e " ${green}verified${normal}."
    else
        echo -e " ${red}signature failed: ERROR!${normal}"
        echo " ===== out ======"
        echo "${out}"
        echo " ================"
    fi
    return ${ret}
}


