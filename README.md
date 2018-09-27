# capi-flash-script

**This script is now maintained by [ibm-capi](https://github.com/ibm-capi) as part of [capi-utils](https://github.com/ibm-capi/capi-utils).**

Usage:
  `sudo capi-flash-script.sh`
  `sudo capi-flash-script.sh <path-to-bit-file>`

This script can be used in systems with one or more CAPI cards installed, to display a list of the available cards with their flash history, and to flash a new image to a specific card.

There are four benefits from using this script rather than calling the `capi-flash` binaries directly;

1. This script writes some information to `/var/cxl/card#` whenever someone flashes a new image. This information is displayed the next time someone wants to flash a new image to one of the cards, making it easier for people to share the cards. To quickly check if your image is still loaded onto the card simply run the script without an input argument.

2. This script will read the PSL revision from the card and matches it to one of the items in the `psl-revisions` file. This makes it easier for people to target the right card when multiple cards of different vendors are present in one system.

3. This script will take care of the reset required to use the new image.

4. This script ensures mutual exclusion.

Please note that the `capi-flash` binaries should be located in the same directory as this script and should be named according to the following naming convention; `capi-flash-XXXX` where `XXXX` is the PSL revision as listed in `psl-revisions`.

Please refer to the [checksum](https://github.com/mbrobbel/capi-flash-script/tree/checksum) branch for a more advanced setup with checksum support.
