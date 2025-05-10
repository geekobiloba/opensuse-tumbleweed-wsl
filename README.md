#   OpenSUSE Tumbleweed setup for WSL

![Preview on Windows Terminal](https://github.com/geekobiloba/opensuse-tumbleweed-wsl/blob/main/preview.png)

##  Highlights

-   Zsh + Oh My Zsh
-   Podman + Podman Compose
-   Miscelaneus useful packages
-   Some fixes.

##  How-to

1.  Install OpenSUSE Tumbleweed from Windows Store,
    and follow YaST2 setup afterward.

    ```powershell
    winget install --id 9MSSK2ZXXN11
    ```

2.  Shutdown all WSL distros, and set OpenSUSE Tumbleweed as the default,

    ```powershell
    wsl --shutdown ; wsl --set-default openSUSE-Tumbleweed
    ```

3.  Recommendedly, add the following lines into Windows `$HOME\.wslconfig` file,[^gui]

    ```powershell
    [wsl2]
    networkingMode    = mirrored
    kernelCommandLine = cgroup_no_v1=all
    guiApplications   = false
    ```

4. Open Tumbleweed again, and upgrade all packages,

    ```shell
    sudo zypper ref && sudo zypper dup
    ```

5.  Shutdown all WSL distros again after upgrade finishes,
    and open Tumbleweed shell again,

    ```powershell
    wsl --shutdown
    ```

6.  Optionally, set passwordless sudo to make your life easier,

    ```shell
    sudo zypper in -y system-group-wheel && \
    sudo sh -c "echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /usr/etc/sudoers.d/wheel" && \
    sudo usermod -aG wheel $USER
    ```

7.  Install the latest Python with pyenv, this will take some time,

    ```shell
    sudo zypper in -y -t pattern devel_C_C++ ;\
    sudo zypper in -y \
      pyenv       \
      xz-devel     \
      tk-devel      \
      libbz2-devel   \
      libffi-devel    \
      sqlite3-devel    \
      readline-devel    \
      libopenssl-devel  ;\
    pyenv install --list |\
    awk '/^[0-9\. ]+$/ {ver=$1} END {print ver}' |\
    xargs -I_ sh -c 'pyenv install _ && pyenv global _' ;\
    sed -i '/# pyenv BEGIN/,/# pyenv END/d' ~/.$(basename $SHELL)rc ;\
    cat <<'EOF' >> ~/.$(basename $SHELL)rc ; exec $SHELL
    # BEGIN pyenv
    export PYENV_ROOT="${HOME}/.pyenv"
    test -d "${PYENV_ROOT}/bin" && PATH=$_:$PATH && export PATH
    eval "$(pyenv init -)"
    # END pyenv
    EOF
    ```

8.  Install Ansible with pipx,

    ```shell
    pip install --upgrade pip && \
    pip install pipx && \
    pipx install --include-deps ansible && \
    pipx inject  --include-apps ansible ansible-lint
    ```

9.  Test Ansible on localhost,

    ```shell
    ansible -i localhost, all -c local -m setup
    ```

10. Run the Ansible playbook,

    ```shell
    ansible-playbook -i localhost, -c local setup.yaml -vv
    ```

11. Shutdown all WSL distros from PowerShell,
    and your Tumbleweed will be ready afterward.

    ```powershell
    wsl --shutdown
    ```

[^gui]: The `guiApplications = false` line
        prevents running GUI application from WSL,
        which is normally unneeded.
        It can fix `fastfect`, too,
        but we have already a better fix in `wsl` role.

##  Using Ansible on WSL from PowerShell

Run the following command to add `ansible` function to PowerShell profile,

```powershell
New-Item -ItemType Directory -Path ($PROFILE | Split-Path) -ErrorAction Ignore ;`
New-Item -ItemType File -Path $PROFILE -ErrorAction Ignore ;`
@'

# Ansible
function ansible {wsl --shell-type login -- ansible @Args}

'@ | Out-File -Append -FilePath $PROFILE
```

