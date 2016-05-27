# Install Panda Linux from source

- Download the repository from *Github*

```console
git clone https://github.com/PandaLinux/base-64.git
```

- Change directory

```console
cd base-64
```

- Configure your system before starting the installation:

```console
bash configure.sh
```

- You will see the following if the configuration was successful

```console
Your system is now configured!!
You can now run ./install.sh to continue...
```

- Now comes the obvious part, start the installation.

    *The system is built in the `/tmp` directory, so it is advised to complete the build without restarting the system.*

```console
./install.sh
```

- If the script doesn't generate any errors then a backup of your newly created system will be
genearated in the root directory of your cloned repository with the name `backup.tar.bz2`.

- Now restart your system to remove any unwanted files left behind by the installer.

- Now simply extract this backup to a partitioned drive with `ext4` filesystem. *Make sure you have at least `2GB` of space
in the partitioned drive.*

    - Extract the backup

    ```console
    tar -pxPf backup.tar.bz2
    ```

    - The files will be extracted to `/tmp/panda64` by default.
    - Now, move these files to your partitioned drive. *Mount your drive to the `/mnt` folder. And, replace `xxx` by your drive id*

    ```console
    mv -v /tmp/panda64/* /mnt/panda/xxx
    ```
- Now, enter the drive

```console
cd /mnt/panda
```

- Run the `cleaner.sh` script to remove all the installation files.

```console
bash cleaner.sh
```

- Edit the `etc/fstab` file. Uncomment the line containing `/dev/sda` and change `/dev/sda` to your drive id.
And, do the same if you have a swap drive. For eg:

```console
/dev/sda9      /             ext4     defaults            1     1
/dev/sda8     swap           swap     pri=1               0     0
```

- You also need to edit the `boot/grub/grub.cfg` file.
    - Find and replace `root=/dev/sdaxx` with `root=/dev/sdayy` Here `yy` is the number you copied `Panda Linux` to. For eg:

    ```console
    sudo vi boot/grub/grub.cfg
    linux	/boot/vmlinuz-3.14.21-systemd root=/dev/sda10 ro
    linux	/boot/vmlinuz-3.14.21-systemd root=/dev/sda10 ro single
    ```

- Update your grub information by running the following command

```console
sudo grub-update
```

- Your system should now be ready. Restart your system and boot up your newly installed `Panda Linux`.
    - Your default `root` credentials will be

    ```console
    Username: root
    Password: root
    ```