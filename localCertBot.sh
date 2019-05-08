#!/bin/bash
while getopts ":a:" opt; do
  case "${opt}" in
    a)
     apachefile=${OPTARG}
     ;;
    \?) 
      echo "Usage: cmd [-a]"
      exit 1
  esac
done
shift $((OPTIND-1))

$(openssl req -x509 -out "$apachefile".crt -keyout "$apachefile".key \
 -newkey rsa:4096 -nodes -sha512 \
 -subj '/CN=localhost' -extensions EXT -config <( \
printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth"))

sudo $(sed -i "/\/VirtualHost/i SSLEngine on\nSSLCertificateFile /home/jl/certs/$apachefile.crt\nSSLCertificateKeyFile /home/jl/certs/$apachefile.key" /etc/apache2/sites-available/${apachefile}.conf)
echo "added"
exit 0
