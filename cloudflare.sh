#!/bin/bash

response=$(curl -s https://api.cloudflare.com/client/v4/ips)

ipv4_subnets=$(echo "$response" | jq -r '.result.ipv4_cidrs[]')
ipv6_subnets=$(echo "$response" | jq -r '.result.ipv6_cidrs[]')

# Change this to suit your needs
geo_file="/etc/nginx/cloudflare_geo.conf"
allow_file="/etc/nginx/cloudflare_allow.conf"

echo "# Cloudflare IPs Geo" > "$geo_file"
echo "geo \$cloudflare_ip {" >> "$geo_file"
echo "    default 0;" >> "$geo_file"
for subnet in $ipv4_subnets; do
    echo "    $subnet 1;" >> "$geo_file"
done
for subnet in $ipv6_subnets; do
    echo "    $subnet 1;" >> "$geo_file"
done
echo "}" >> "$geo_file"

echo "# Cloudflare IPs Allow" > "$allow_file"
for subnet in $ipv4_subnets; do
    echo "allow $subnet;" >> "$allow_file"
done
for subnet in $ipv6_subnets; do
    echo "allow $subnet;" >> "$allow_file"
done
echo "deny all;" >> "$allow_file"
echo "real_ip_header CF-Connecting-IP;" >> "$allow_file"
cat <<EOL >> "$allow_file"

# Check if the request is from Cloudflare
if (\$cloudflare_ip != 1) {
    return 403;
}
EOL

chmod 644 "$geo_file"
chmod 644 "$allow_file"

nginx -t && systemctl reload nginx
