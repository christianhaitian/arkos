# Update Scripts
To create an update package, create a subdirectory inside [/updates/RG351P](./RG351P)
with a script named `update.sh` and any files necessary for the update.
[Update-RG351P.sh](../Update-RG351P.sh) will automatically
parse the GitHub repo's updates directory and run the script. 

## Parameters
Three arguments are passed to `update.sh` for use in update scripts:
* `$1` - Name of the enclosing directory, referred to as `updateName` in [Update-RG351P.sh](../Update-RG351P.sh)(eg, 12202020)
* `$2` - URL of the enclosing directory's RAW GitHub endpoint
* `$3` - Local path to the update log file

*Example:*
_/updates/RG351P/mynewupdate/update.sh:_
```shell
	#!/bin/bash
	UPDATE_NAME=${1} // mynewupdate
	UPDATE_DIR_URL=${2} // https://raw.githubusercontent.com/christianhaitian/arkos/main/updates/RG351P
	LOG_FILE=${3} // /home/ark/.updatemynewupdate.log

	# Do something...
	# curl ${UPDATE_DIR_URL}/${UPDATE_NAME}/update.sh | tee -a "${LOG_FILE}"
	exit
```

## Exiting and Errors
If your update script exits with a code != 0,
the main script will detect it and pass it to the error handler.
The error handler then tears down and resets the environment
before killing the update process.

## Caveats
The script will error out if a subdirectory in [/updates/RG351P](./RG351P)
does not contain an `update.sh`. For update directories
without an update script, one possible workaround
might be to just place an empty script in the directory:

```shell
	#!/bin/bash
	exit
```
