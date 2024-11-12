#!/bin/sh

HASHED_PASSWORD=$(tail -n 1 /hashed_password.txt)
echo "Hashed password is: ${HASHED_PASSWORD}"
echo "SocksPort 0.0.0.0:12453" > /etc/tor/torrc
echo "ControlPort 0.0.0.0:12454" >> /etc/tor/torrc
echo "HashedControlPassword ${HASHED_PASSWORD}" >> /etc/tor/torrc
echo "CookieAuthentication 0" >> /etc/tor/torrc
