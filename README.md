# qrz.sh

This script queries the QRZ.com callsign database and returns
the result to the command line. A XML subscription plan with
QRZ.com is required for full functionality.

![screenshot](/screenshot.jpg?raw=true "screenshot")

# Installation

* Copy the file _.qrz.conf_ into your home directory
* Copy the file _qrz.sh_ into a directory that is in you PATH variable
* Set the correct file permissions: _chmod u+x qrz.sh_

# Configuration

Edit the file _~/.qrz.conf_ like this:

```
user=<your QRZ.com username - typically your callsign>
password=<your QRZ.com password - NOT your API key>
```

# Usage

```
# qrz.sh <callsign>
```
