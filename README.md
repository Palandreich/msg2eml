# msg2eml

Converts Microsoft Outlook `.msg` files to standard `.eml` format (MIME).

## Requirements

- macOS
- Python 3.10+

## Installation

```bash
git clone <repo>
cd msg2eml

python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## Usage

```bash
# Single file (output saved next to the source)
.venv/bin/python msg2eml.py letter.msg

# Single file with explicit output path
.venv/bin/python msg2eml.py letter.msg ~/Desktop/letter.eml

# Entire directory
.venv/bin/python msg2eml.py ./msgs/ --output-dir ./emls/
```

## Finder Integration (context menu)

Finder runs Quick Actions in a sandboxed shell that blocks `source`, so a wrapper in `/usr/local/bin/` is used to call the venv Python directly.

**1. Install the command:**

```bash
./install_cmd.sh    # install
./uninstall_cmd.sh  # remove
```

This creates `/usr/local/bin/msg2eml` with a hardcoded path to the current project's venv Python. Re-run if you move the project to a different folder.

**2. Add a Quick Action in Automator:**

1. Open **Automator** → New Document → **Quick Action**
2. Set at the top: *Workflow receives* **files and folders** in **Finder**
3. Add a **Run Shell Script** action
4. Shell: `/bin/zsh`, Pass input: **as arguments**
5. Script body:
   ```zsh
   /usr/local/bin/msg2eml "$@"
   ```
6. Save as `Convert to EML`

In Finder: right-click any `.msg` file → **Quick Actions → Convert to EML**.  
A system notification will appear when conversion is complete.

> If the Quick Action does not appear, restart Finder:  
> Option + right-click the Finder icon in the Dock → **Relaunch**

