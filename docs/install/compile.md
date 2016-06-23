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

- Edit your `/etc/sudoers` file to remove password prompt for `${PANDA_USER}`
```console
sudo visudo
```

At the end of the file add the following line:
```console
cub	ALL=(ALL) NOPASSWD: ALL
```

- Log into the newly created environment
```console
sudo su - cub
```

- Now comes the obvious part, start the installation.
```console
./install.sh
```

To see the help menu for installation:
```console
./install.sh -h
```

Now, just follow the on-screen instructions.