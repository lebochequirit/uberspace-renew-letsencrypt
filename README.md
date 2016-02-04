# uberspace-renew-letsencrypt
A script to implement painless Lets's Encrypt Certificate renewal for ubernauts. Just call it  weekly via cron.
It checks whether a Let's encrypt SSL cert is still valid and otherwise renews it.

Put it somewhere on your uberspace, eg. /home/$USER/scripts, either by cloning the repo or download the ZIP.

Make the .sh script executable (chmod +x)

call it @weekly via cron.
Read https://wiki.uberspace.de/system:cron for further information.
