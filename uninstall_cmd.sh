#!/bin/zsh
# Removes /usr/local/bin/msg2eml installed by install_cmd.sh.

if [[ -f /usr/local/bin/msg2eml ]]; then
    sudo rm /usr/local/bin/msg2eml
    echo "Removed: /usr/local/bin/msg2eml"
else
    echo "Not installed: /usr/local/bin/msg2eml"
fi
