#!/bin/zsh
# Copies a wrapper script to /usr/local/bin/msg2eml so it can be used
# from Finder Quick Actions without sandbox restrictions.
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

sudo tee /usr/local/bin/msg2eml > /dev/null << EOF
#!/bin/zsh
"$PROJECT_DIR/.venv/bin/python" "$PROJECT_DIR/msg2eml.py" "\$@"
EOF

sudo chmod +x /usr/local/bin/msg2eml

echo "Installed: /usr/local/bin/msg2eml"
echo "In your Quick Action use: /usr/local/bin/msg2eml \"\$@\""
