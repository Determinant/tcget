#! /bin/bash

site_name='community.topcoder.com/tc'
site_ip='http://209.202.141.182/'
url="http://$site_name?&module=Login"
temp_dir='/tmp'

curl -3 -b "$header_info" "$site_ip""tc?module=MatchList&nr=200&sr=1" | \
		 grep 'rd=[0-9]*">SRM [0-9][0-9][0-9]' | sed 's/.*rd=\([0-9]*\)">SRM \([0-9.]*\).*/\1 \2/g' > "$temp_dir/matches"


