#!/bin/sh

HASHED_PASSWORD=$(tail -n 1 /hashed_password.txt)
echo "Hashed password is: ${HASHED_PASSWORD}"
echo "SocksPort 0.0.0.0:30053" > /etc/tor/torrc
echo "ControlPort 0.0.0.0:30054" >> /etc/tor/torrc
echo "HashedControlPassword ${HASHED_PASSWORD}" >> /etc/tor/torrc
echo "CookieAuthentication 0" >> /etc/tor/torrc
