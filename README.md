The `main.sh` script goal is to deploy a fully functionnal mail server on a completely clean Debian 9 machine.

The deployed stack is the following :
- *nginx* as a web server and reverse proxy (for user mail and admin web interfaces)
- *postfix* as an MTA
- *dovecot* 
- *rspamd*


## Usage instruction
- Clone or download this repository on a clean instance of Debian 9.
- Carefully edit the `subscripts/vars.sh` file to fit your needs.
- Launch the script with admin priviledges `sudo ./main.sh`
- Follow the instructions and wait for it to finish
- Carefully read the generated `TODO` file and follow it's instruction to configure you DNS and securise your server.

## Disclaimer
This is a fairly straightforward script made to work on a completely blank Debian 9 machine. Very little safeguards are implemented and once it is started *there is no way back* ! Use it at your own risks.
If your building a new server from scratch then this script may releive you of many tedious tasks. But if you already have a production server on which you want to add an email component then you'd better look toward more complete solutions like iRedMail.
