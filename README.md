# nginx-cloudflare-config
##### *A small script to block non-Cloudflare traffic while restoring visitor ips*

## Why?
I wanted a script that fetches Cloudflare IPs automatically, to block non-Cloudflare traffic, while restoring visitor IPs.

## How to use it?
### Initial configuration
You'll need first to install jq and curl.
```bash
sudo apt update && sudo apt install curl jq # Debian/Ubuntu
sudo dnf install curl jq # Rocky Linux/RHEL/CentOS/Fedora
sudo pacman -S curl jq # Arch Linux
sudo apk add curl jq # Alpine Linux
```

Then download the [`cloudflare.sh`](/GeekCornerGH/nginx-cloudflare-config/blob/master/cloudflare.sh) file.
Remember to make it executable:
```bash
chmod +x cloudflare.sh
```
(Optional) Edit the path in the `geo_file` and `allow_file` variables. 
### Nginx configuration
Edit the `nginx.conf` file and put the following line in the `http` block. Remember to edit the path if you're not using the default script.
```nginx
include /etc/nginx/cloudflare_geo.conf;
```
Then add a reference to the `allow_file` file path in your vhost, in a location block like below. Once again, remember to edit the path if you edited the script.
```nginx
location / {
  include /etc/nginx/cloudflare_allow.conf;
```
### Run the script
Make sure everything works by running the script
```bash
sudo ./cloudflare.sh
```
### ...And automate it
Cloudflare may add or remove ips at any time. While this doesn't happens too often, you probably don't want to block newly added Cloudflare by mistake.
Simply run `crontab -e` then add the following contents
```cron
0 0 * * * /path/to/cloudflare.sh >/dev/null 2>&1
```
This example will run the script every day at midnight. You may adapt it to suit your needs.

