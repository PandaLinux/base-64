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

- While configuring your system, a new user will be created which will be
used for building `Panda Linux`.

- You will see the following if the configuration was successful

```console
Environment is now ready!!
```

- Log into the newly created environment
```console
sudo su - cub
```

- Now comes the obvious part, start the installation.
```console
./install.sh
```

Now, just follow the on-screen instructions.

**Note: By default, the installation directory is set to `/tmp/panda64`. It is mandatory to change this location to the partition where the actual system will reside such as `/dev/sdaXX`.**

To change the installation location (you'll need to mount the partition to `/mnt/XXX`):
```console
./install.sh -i /mnt/panda
```

To see the help menu for installation:
```console
./install.sh -h
```