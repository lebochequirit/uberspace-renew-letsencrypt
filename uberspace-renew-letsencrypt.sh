#!/bin/bash

# define warndate as 10 days before cert expiration
# you can call the script weekly via cron then
WARNDATE=$(date -d "+10 days" +"%s")

# define let's encrypt work directory
LEDIR=/home/$USER/.config/letsencrypt

# define let's encrypt cert directory - read and build path
CERTDIR=$(basename $LEDIR/live/*)
CERTDIR=$LEDIR/live/$CERTDIR

# check if let's encrypt cli parameters are set and set if necessary
# agree-dev-preview first, most likely commented out
if ! grep -q "agree-dev-preview" $LEDIR/cli.ini; then
        echo "agree-dev-preview = True" >> $LEDIR/cli.ini; else
        if grep -q "#agree-dev-preview = True" $LEDIR/cli.ini; then
                cp $LEDIR/cli.ini $LEDIR/cli.bak
                sed -i s/#agree-dev-preview/agree-dev-preview/g $LEDIR/cli.ini
        fi
fi
# now agree-tos
if ! grep -q "agree-tos" $LEDIR/cli.ini; then
        echo "agree-tos = True" >> $LEDIR/cli.ini; else
        if grep -q "#agree-tos = True" $LEDIR/cli.ini; then
                cp $LEDIR/cli.ini $LEDIR/cli.bak
                sed -i s/#agree-tos/agree-tos/g $LEDIR/cli.ini
        fi
fi
#and renew-by-default
if ! grep -q "renew-by-default" $LEDIR/cli.ini; then
        echo "renew-by-default = True" >> $LEDIR/cli.ini; else
        if grep -q "#renew-by-default = True" $LEDIR/cli.ini; then
                cp $LEDIR/cli.copy $LEDIR/cli.bak
                sed -i s/#renew-by-default/renew-by-default/g $LEDIR/cli.ini
        fi
fi

# read expiration date from let's encrypt directory
for cert in $CERTDIR/cert.pem; do
	toDate=$(date -d "$(openssl x509 -in $cert -noout -enddate | cut -f2 -d'=')" +"%s")
	# check whether certs are due to expire
	if [ $WARNDATE -gt $toDate ]; then
	# create new certificates
	letsencrypt certonly
	# configure the uberspace webserver to use the new certificates
	uberspace-prepare-certificate -k $CERTDIR/privkey.pem -c $CERTDIR/cert.pem
fi
done
exit 0
