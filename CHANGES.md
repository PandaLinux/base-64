
## Major Changes

- The directory structure has slightly been modified.
    - All the patches have been moved to the `$ROOT_DIR/patches` folder.
    - This makes it easy for maintaining the patches.

- Now, the user is created while configuring the system. This user's home is also setup on the fly without any user intervention.
- The created user can be referenced by `${PANDA_USER}` and this variable is setup in `variables.sh`
- The `install.sh` script has also been modified a lot.
    - It is now possible to change some of the variables such as `installation directory`, `concurrent jobs` etc. For more details about these variables, just execute `./install.sh -h`.
    - The variables changed via the `install.sh` are stored in `variables.sh` and `~/.bashrc` of `${PANDA_USER}`.
- The `cleaner.sh` script has been removed for now and later a better version of this script will be made written.
- The data in `${PANDA_HOME}` can only be edited by `${PANDA_USER}` but can be seen by anyone to avoid accidental changes to the installation script.
- `version-check.sh` has been cleaned and re-written to check for minimum requirements from the host.
- All the major scripts can now only be executed by `${PANDA_USER}` to avoid damage to the host system and provide a clean environment to the installer.
- `${PANDA_USER}` is a password-less user. This keeps the installation running even when the user has left.
- Logs are now stored in a separate folder in the working directory.
- The `DONE` has been moved to the `${DONE_DIR}` and is renamed to the package's name. 