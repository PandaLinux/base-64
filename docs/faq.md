# FAQ's

- What is the mission of your project?

    Our only goal at this time is to make a highly customized operating system with bare minimum tools. Our project aims
    at building scripts that can be used by anyone to build their own distro.

    This project has been inspired by [Linux from scratch](www.linuxfromscratch.org).

- Which distro should I use to build `Panda Linux`?

    Well, you can use either `Debian Jessie` or `Ubuntu 14.04`. Currently, we have only tested our build using `Ubuntu 14.04`
    but you can test it on `Jessie` and let us know. *Make sure to use only `64bit` system for your build.*

- When can I expect the stable release?

    We are working on the the release but at the present moment everything is unsure. But you can enable notifications
    by clicking on the `Watch` option and stay up to date.

- Can I change the global variables provided in the `variables.sh` file?

    As of now, you should not change any global variables as the system is highly unstable and heavily under development.
    Anything can change at anytime. We are planning to improve our `install.sh` file in a way that you can change some
    of the variables.

- I don't understand the commands written in the `build.sh` file. Where is the documentation for these commands?

    There is no documentation as of now. But once we build a stable system, we'll start working on the documentation
    and we'll try to make it as easy as possible.

- What kind of users are you trying to target?

    We want to build systems for all possible kinds of users. We want to target everybody. But this repository is for
    people who have atleast a basic knowledge of bash.

- My installation failed but I have all the required dependencies and the previous packages have been built properly.
 What should I do?

    Logout and login again and try to re-run the previous command. Sometimes the installation fails due to not having adequate resources.
    such as CPU, memory etc. If the issue still persists, open up an [issue](https:github.com/PandaLinux/base-64/issues).
    
- How do I install `GCC 5+` on `Ubuntu` ?

    ```console
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt-get update
    sudo apt-get install gcc-5 g++-5
    
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
    ```