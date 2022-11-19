# BAPP file Development
Please also see details on [contributing](/CONTRIBUTING.md)

# Overview
The bapp files are located in the [app/](./README.md) directory. There is stable and experimental branches. The stable branch is core applications and consistently maintained packages. These packages are expected to be functional on all supported hardware. bapp files are for classic x86 architecture and ARM(pi) hardware

The experimental branch is open for inclusion of apps by the community as well as apps with less development or less attention, these apps worked at one time and could have gone stale or need more involvement to deploy due to less automation possibilities.

Why yad/bash? the installers are all normally bash/command line so why not.. it would be cool to have a python front end take over the menu.sh to handle the display better.

# Structure
The bapp files are just a set of specific function calls, the header is metadata for the user interface. The following is a highly commented template. It is important to review the comments and maintain the structure of the bapp. 

.bapp version header `BAPP=` this header is checked and there is a variable in the menu and app-check that validate which version of file format to use. see hamlib.bapp for enhanced use of the file.

## Header
| .bapp file header string | comment on its functions |
| --- | --- |
|BAPP=4.0 | #required flag for bapi currently 4.0 is release use only one!
|ID=DEMO | #required flag for bapi depends references, short string name
|Name=Demo | #required common name of app if type-long use strings ideally don't.
|Comment='Demo Ham App' | #required comment field
|Ver=0.0 | #required but dynamically updated at runtime
|localVer=1.0 | #required and dynamically updated set to initial tested ver.
|W3='http://appweb.local' | #best support page for the application
|Author='john doe' | #author for the application or email for contact on updates

## Functions Body
```
BAPP=4.0
ID=EXAMPLE
Name='Exa mple'
Comment='Example Ham App'
VerLocal=0 #runtime set
VerRemote=0 #runtime set
W3='http://appweb.local'
Author='spud'
NOTE='any notes for double click in menu'

INSTALL(){
    #   operations handled buy the job-runner from the menu selections

    # Detect cortex chip (ARM's)
    if [[ "$BAPCPU" == *"ar"* ]]; then
        export BAPsrc="/run/shm/" # example, possibly set the build to ram disk to save SDCARD bashing
    fi

    #common process to all platforms
    cd hamlib || return
    ./configure
    make

    # Detect pi3
    if [[ "$BAPCPU" == *"arm"* ]]; then
        make install
        ldconfig
        make clean
    fi

    # Detect mint
    if [[ "$BAPDIST" == *"linuxmint"* ]]; then
        make install
        ldconfig
        make clean
    fi
}

VERSION(){
    #Required variable ideally dynamic
    NEWVER=0-git
    
    #Required variable ideally dynamic, additionally shows installed or not
    if [[ $(whereis ls | grep bin) ]];then
        CURRENT=0-DEB
    else
        CURRENT=NONE
    fi
}

DEPENDS(){
    NEEDED="" #example of none required
    NEEDED="64BIT|HAMLIB" #Example of Multiple -BAPcore- Dependencies separated by identifier |

    #additionally further example just like INSTALL you can..
    # Detect pi3
    if [[ "$BAPARCH" == *"arm"* ]]; then
        NEEDED="64BIT"
    fi
}
```
The files are put into the experimental location and optionally viewed to the menu at load. You should see the file processing in the startup routine checks as listed for checks, any standard output is displayed here as well for the end user and logs.

# CACHE folder
there is a link `src` in the bapi folder to `~/.bap-source-files` where you can find your way to quick debug

### Logging and error Trapping
The intention is to send all error lines of critical nature into a central log location in `errors/`

### Running AKA single files
This is a tool that can be used to run any given bapp file `./bin/dev-runner.sh hamlib.bapp` 
It will just bypass the menu system and run the single install with dep check and install run job. Is this feature written yet?

# GLOBALS for runtime and bapp use
Generically speaking they are set once variables but can be manipulated just variables, damage may occur.

| Details | Values | Variable to use in .bapp |
| --- | --- | --- |
cpu | 64 / 32 | BAPARCH
number of core | int | BAPCORE
cpu architecture | armv7l / aarch64 / x86_64 | BAPCPU
linux distribution | raspbian/debian/linuxmint | BAPDIST
script install location| path to install dir | BAPDIR
MyCALL | string | BAPCALL
MyCALL | string | MYCALL
source file collection | .bap-source-files | BAPSRC
whoami | string | BAPWHOAMI

## Additional tools
Most of them are considered developer tools and should not be used without understanding where the rabbit will go.

| purpose | command | note |
| --- | --- | --- |
|debug facility|`touch .debug` or `rm .debug`| verbose output for debug .bapp
|reset user data (fake a first run)|`./bin/set-enviroment.sh reset`|
|reset src cache|`./bin/set-enviroment.sh clean`|
|bapp dev template maker|`./bin/template-naker.sh build`|menu driven builder
|bapp dev runner|`./bin/dev-runner.sh hamlib.bapp check file.bapp`|basic structure tests
|pi-build migration tool|`./bin/backup-pi-build`|fork of the existing
|bapi backup tool|`./bin/bapi-backup.sh`|non functioning currently
|bapi Template Tool|`./bin/template-maker.sh check file.bapp`|used to validate files and move to corrupt
|bapi Template Tool|`./bin/template-maker.sh build`|start template generator tool
