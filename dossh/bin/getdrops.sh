#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo 'Pass OAuth token as first argument.'
  exit 0
fi

echo "" > ip_list.tmp
nextlink="https://api.digitalocean.com/v2/droplets"

while [ "$nextlink" != "" ]
do
echo "Fetching $nextlink"
curl -s -X GET -H "Authorization: Bearer $1" "$nextlink" > tmp.txt
# Print droplet name, and the type and address of all the v4 and v6 networks
# Droplets are separated by a line with '#' which we use later.
cat tmp.txt | jshon -e droplets -a -s '#' -u -p -e id -u -p -e name -u -p -e networks -a -a -e type -u -p -e ip_address -u >> ip_list.tmp
# Note, this throws an error on the last page because there is no 'links.pages.next'
nextlink=$(cat tmp.txt | jshon -e links -e pages -e next -u)
done

echo 'Done downloading droplet data.'
# Make it pretty. Use that '#' we inserted between droplets.
cat ip_list.tmp | tr '\n' '\t' | tr '#' '\n' | column -t | nl > ip_list.txt
rm tmp.txt
rm ip_list.tmp
echo 'Saved in ip_list.txt'
