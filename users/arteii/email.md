Log In to Proton Mail Bridge

The bridge runs automatically as a systemd user service. Authenticate your account via the command-line interface:
Bash

protonmail-bridge --cli

(Note: If the CLI states another instance is running, stop the background service with systemctl --user stop protonmail-bridge before running the command.)

    Enter the login command.

    Enter your Proton Mail address and your main password (plus 2FA if enabled).

    Wait for the initialization to complete.

4. Save the Bridge Password to the Keyring

The bridge generates a unique local password for your mail clients.

    Inside the bridge CLI, enter the info command.

    Copy the generated string next to Password:.

    Exit the CLI by typing exit.

Now, securely save this password into your unlocked system keyring using secret-tool:
Bash

secret-tool store --label="Protonmail Bridge Local Password" service protonmail-bridge account local-pass

The terminal will pause. Paste your copied Bridge Password here and press Enter.
Usage
Running NeoMutt / Thunderbird

Launch the mail client from your terminal:
Bash

neomutt

    The configuration automatically fetches the password from your system keyring at startup without storing plaintext files on disk.

    Use the sidebar to navigate through your mail folders.

    Git diffs and patches are automatically color-coded in the mail body.


Troubleshooting

    Check Bridge Status:
    Verify that the background service is active:

Bash

  systemctl --user status protonmail-bridge

    Keyring Locked Error:
    If secret-tool or your mail client fails to fetch the password, ensure your user session unlocked the gnome-keyring at login.