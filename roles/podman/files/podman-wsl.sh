# Fix Podman on WSL: WARN[0000] "/" is not a shared mount
#
wsl.exe -u root -e mount --make-rshared /

