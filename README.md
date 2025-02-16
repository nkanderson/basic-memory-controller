# Basic Memory Controller

A very basic memory controller implementing in SystemVerilog.

## Contributing

### Verible Installation Script

This script automates the process of downloading, extracting, and setting up the latest version of Verible for a single user. The binaries are installed in `~/bin`, ensuring they do not interfere with system-wide packages.

#### **How to Run It**

Perform the following from the `scripts` directory.

1. **Give the install script execute permissions**
```bash
chmod +x install_verible.sh
```

2. **Run the script**
```bash
./install_verible.sh
```

3. **(Optional) Manually verify the installation**
```bash
verible-verilog-lint --version
```

If the installation was successful, you should see the Verible version printed in the terminal.

______________


### Setting Up a GitHub Deploy Key

A **deploy key** is an SSH key that grants access to a single GitHub repository. We'll be using this as a secure way to grant access to our project directory, while limiting permissions for a key stored on a PSU server.

1. **Generate an SSH Key**

Run the following command, replacing `your_email@example.com` with your email:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
- When prompted, press **Enter** to accept the default location (`~/.ssh/id_ed25519`).
- You may also add a passphrase for extra security. This is optional but recommended.


2. **Add the Public Key to GitHub**

Copy the contents of your **public key** to the clipboard:

```bash
cat ~/.ssh/id_ed25519.pub
```

Go to the project github repository and navigate to **Settings > Deploy keys**. Click to **Add deploy key**. Give it a descriptive title (e.g. "PSU ECE server Mo"). Paste the **public key** into the "Key" field and select **Allow write access**. Last, click to **Add key**.

You should now have access to **push** to the project repository from the server. You may also want to update the git configuration on the server to use the correct name and email address associated with your github account.
