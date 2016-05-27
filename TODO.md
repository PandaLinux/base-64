# TODO

- We need a better logo for our system.
- Create an `ISO` image of the system.
- Create a shell installer to setup the system instead of using it as a `live` os.
- Thoroughly test the all the packages before the next release.
- `version-check.sh` script should exit upon error after checking all the programs instead pf just one.
- Improve `install.sh` script. Add parameters to change `install directory`, `destination directory`,
`number of procs to use` and `whether to run tests`.
- Backup the system: pigz uses multicore to improve compression speed.
- Implement [#6](https://github.com/PandaLinux/base-64/issues/6) before the next release.
- Create a `wget` filter for showing less output. This filter should be created for versions `1.15` and below. 
For versions greater than `1.15`, add the flags `--show-progress --quiet`, these flags show less output on the
console.
- Use `mutex locks` while executing scripts to prevent multiple executions.
