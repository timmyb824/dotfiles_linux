#!/bin/bash

# confirm an argument is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <add|remove>"
  exit 1
fi

# if arg is `add` then append 1.1.1.1 to top of resolv.conf
if [ "$1" == "add" ]; then
  echo "Adding 1.1.1.1 to resolv.conf..."
  sudo sh -c 'echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf > /tmp/resolv.conf && mv /tmp/resolv.conf /etc/resolv.conf'
  echo "Done"
fi

# if arg is `remove` then remove 1.1.1.1 from resolv.conf
if [ "$1" == "remove" ]; then
  echo "Removing 1.1.1.1 from resolv.conf..."
  sed -i '1d' /etc/resolv.conf
  echo "Done"
fi
