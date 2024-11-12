#!/bin/sh

HASHED_PASSWORD=$(tail -n 1 /hashed_password.txt)
echo "SocksPort 127.0.0.1:12453" > /etc/tor/torrc
echo "ControlPort 127.0.0.1:12454" >> /etc/tor/torrc
echo "HashedControlPassword ${HASHED_PASSWORD}" >> /etc/tor/torrc
echo "CookieAuthentication 0" >> /etc/tor/torrc
