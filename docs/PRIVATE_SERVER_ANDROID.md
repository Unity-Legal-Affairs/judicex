# Private server deployment for Android access

This deployment profile is intended for one lawyer using an Android phone.
It keeps the web application bound to localhost and uses Tailscale Serve for
private HTTPS access inside the user's tailnet. Do not use Tailscale Funnel
or expose port 5051 to the public internet.

## Important security status

Judicex is currently an alpha project. Its SECURITY.md explicitly says that
it has no security guarantee for internet-exposed or shared deployments.
The local password gate is not a multi-user identity and authorization
system. This deployment profile reduces network exposure; it does not turn
the application into an audited production system. Do not upload live client
files until access control, backup/restore, data retention, and application
security have been reviewed and tested.

## Target architecture

Android Chrome -> Tailscale private HTTPS -> Tailscale Serve -> 127.0.0.1:5051
-> Gunicorn (one worker) -> Flask -> SQLite and matter files.

The app is not bound to 0.0.0.0. The only application listener is loopback.
Use a supported Ubuntu LTS server, a non-root service account, SSH keys,
host firewall rules, and automatic security updates.

## Server preparation

1. Provision a private Ubuntu LTS VPS or a server under your control.
2. Create a non-root administrator and configure SSH key access before
   disabling password-based SSH. Keep the provider console available.
3. Install Python 3.11+, Git, and the Tailscale Linux client.
4. Create the service account and directories:
   - user/group: rahimi-assistant
   - application: /opt/rahimi-assistant
   - data: /var/lib/rahimi-assistant
5. Clone this repository using branch Iran-legal into /opt/rahimi-assistant.
6. Create a virtual environment and install:
   pip install -e ".[crypto,server]"
7. Copy deploy/rahimi-assistant.env.example to
   /etc/rahimi-assistant.env. Generate JUDICEX_SECRET_KEY with
   openssl rand -hex 32. Keep the file readable only by root and the
   rahimi-assistant group; never commit it.
8. Set ownership of /var/lib/rahimi-assistant to the service account.
9. Install deploy/systemd/rahimi-assistant.service into
   /etc/systemd/system/rahimi-assistant.service, then run systemctl daemon-reload
   and enable/start the service.
10. Verify locally on the server that 127.0.0.1:5051 responds.

## Private phone access

1. Create a Tailscale tailnet with an account controlled by the lawyer.
2. Install Tailscale on the Ubuntu server and sign it into that tailnet.
3. Install Tailscale on Android and sign into the same tailnet.
4. Enable MagicDNS and HTTPS certificates in the tailnet admin settings.
5. On the server, run:
   tailscale serve --bg http://127.0.0.1:5051
6. Read the private HTTPS URL printed by Tailscale and open it in Chrome
   on the Android phone while Tailscale is connected.
7. Add the page to the Android home screen from Chrome's menu.

Do not run tailscale funnel. Do not open TCP 5051 in the public firewall.
Keep SSH restricted to trusted source addresses or reachable through the
private tailnet.

## First login and data

- On first private access, set a strong application password if the UI
  offers the setup flow. The app password is an additional gate, not a
  replacement for Tailscale identity controls.
- Keep API keys out of Git and out of browser-visible settings.
- Prefer a local model provider if documents must not leave the server.
- Configure encrypted off-server backups and periodically test restoration.
- Restrict backup access; backups contain the same confidential data as the
  live database and uploaded documents.

## Operational checks before using real client matters

- Confirm the server is reachable only over the private tailnet.
- Confirm public port scans do not show the application port.
- Confirm HTTPS and secure session cookies in Android Chrome.
- Test login, logout, file upload, database persistence after restart,
  backup, and restore.
- Test that a non-tailnet device cannot reach the application.
- Review application logs for accidental document or credential disclosure.
- Document provider region, retention, access, and data processing before
  enabling any hosted AI provider.

This file is an installation plan, not a claim that a server has already been
provisioned or that a live deployment has been completed.
