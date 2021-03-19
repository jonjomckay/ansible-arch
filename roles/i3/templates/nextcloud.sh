#!/bin/sh

while ! $(secret-tool lookup Title Nextcloud &> /dev/null); do
	echo "Waiting for secret provider before starting Nextcloud"
	sleep 1s
done

/usr/bin/nextcloud --background