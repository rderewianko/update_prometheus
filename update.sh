#!/bin/sh

##define if we're using alert manager or prometheus
product="alertmanager"

cd /var/tmp/


echo "downloading $product"

curl -s https://api.github.com/repos/prometheus/$product/releases/latest \
| grep "browser_download_url.*linux-amd64.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -


tarball="$(find . -name "*linux-amd64.tar.gz")"
echo "extracting $tarball"
tar -xzf "$tarball"


echo "Finding where $product was extracted"
pfolder=$(find . -name  "$product*" -type d | cut -c 3-)

echo "using $pfolder"

cd /var/tmp/"$pfolder"
echo "stopping $product"
systemctl stop $product.service

echo "moving files into place"

if [ "$product" = "alertmanager" ]; then
	chmod +x amtool
	chmod +x alertmanager
	mv amtool /usr/local/bin/
	mv alertmanager /usr/local/bin/

elif [ $product = "prometheus" ]; then
	chmod +x promtool
	chmod +x prometheus
	mv promtool /usr/local/bin/
	mv prometheus /usr/local/bin/
  chown prometheus:prometheus  /usr/local/bin/promtool
  chown prometheus:prometheus  /usr/local/bin/prometheus

fi

echo "starting $product"
systemctl start $product.service


echo "cleaning up"

rm -rf /var/tmp/"$pfolder"
rm  /var/tmp/"$pfolder".tar.gz


exit 0
