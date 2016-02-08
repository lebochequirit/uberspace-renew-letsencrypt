#!/bin/bash

# define warntime in seconds, equals 10 days before cert expiration
# you can call the script weekly via cron then
WARNTIME=864000

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

# check expiration date from let's encrypt directory
	if ! openssl x509 -in $CERTDIR/cert.pem -checkend $WARNTIME -noout; then
	# create new certificates
	letsencrypt certonly
	# configure the uberspace webserver to use the new certificates
	uberspace-prepare-certificate -k $CERTDIR/privkey.pem -c $CERTDIR/cert.pem
fi
exit 0
