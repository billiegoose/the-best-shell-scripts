#!/bin/bash
if [ "$#" -lt 1 ]; then
echo 'Pass OAuth token as first argument.'
  exit 0
fi

TOKEN="$1"
shift
pretty="$1"

mkfifo a b c d
trap "rm -f a b c d" EXIT

nextlink="https://api.digitalocean.com/v2/droplets"

nextpage() {
    curl -s -X GET -H "Authorization: Bearer $TOKEN" "$nextlink" | tee -a a b &>/dev/null &
    # Print droplet name, and the type and address of all the v4 and v6 networks
    # Droplets are separated by a line with '#' which we use later.
    jshon -e droplets -a -s '#' -u -p -e id -u -p -e name -u -p -e networks -a -a -e type -u -p -e ip_address -u <b &
    # Note, this throws an error on the last page because there is no 'links.pages.next'
    nextlink=$(jshon -e links -e pages -e next -u <a 2>/dev/null)
    sleep 1
}

# Make it pretty. Use that '#' we inserted between droplets.
echo "id,host,type1,addr1,type2,addr2,type3,addr3" >c &
cat <c | tr '\n' ',' |  tr '#' '\n' | sed 's/^,//' | sed 's/,$//' >d & # nl | column -t | nl & #> ip_list.txt &

# Default is a CSV file. With --pretty option formats like a table.
if [ "$pretty" == "--pretty" ]
then
    column -t -s ',' <d | nl -v 0 | sed 's/^     0/lineno/' &
else
    cat <d &
fi

while [ "$nextlink" != "" ]
do
#echo "Fetching $nextlink"
nextpage >> c
done
