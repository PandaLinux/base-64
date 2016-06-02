# TODO

- We need a better logo for our system.
- Create an `ISO` image of the system.
- Create a shell installer to setup the system instead of using it as a `live` os.
- Thoroughly test the all the packages before the next release.
- `version-check.sh` script should exit upon error after checking all the programs instead of just one.
- Backup the system: pigz uses multicore to improve compression speed.
- Use `mutex locks` while executing scripts to prevent multiple executions.
- Write a script to automate the process written in [compile from source](docs/install/compile.md) to make it easier for newbies.
- Three copies of these scripts are made at different locations.
    1. The github cloned copy
    2. Installation user copy
    3. Temporary location copy
    
    My suggestion would be not to make a temporary location copy but to use the installation user copy to keep the temporary build environment as clean as possible.