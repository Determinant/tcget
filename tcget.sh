#! /bin/bash -e

site_name='community.topcoder.com/tc'
site_ip='http://209.202.141.182/'
url="http://$site_name?&module=Login"
temp_dir='/tmp'
user="$1"
passwd="$2"
header_info='header.txt'

function login {

	local ret=`curl -3 "$site_ip""tc" -H "Host: community.topcoder.com" -e "$url" -d "&module=Login&username=$user&password=$passwd" -D "$header_info"`
	if [ "$ret" == '' ]; then echo 0; else echo 1; fi
}

function get_id() { # $1, $2 => round prob

	local res=`curl -3 -b "$header_info" "$site_ip""tc?module=ProblemDetail&pm=$2&rd=$1" | \
			  grep 'problem_solution' | \
			  sed "s/.*stat?c=problem_solution&amp;cr=\([0-9]*\)&amp;rd=$1&amp;pm=$2.*/\1/g" | tail -1`
	echo $res
}

function get_data { # $1 $2 $3 $4 => round prob ct file_path

	curl -b "$header_info" "$site_ip""stat?c=problem_solution&pm=$2&rd=$1&cr=$3" | \
	sed  -n '1h;1!H;${;g;s/<TD[^>]*>\([^<]*\)<\/TD>/\1/g;p;}' | \
	sed  -n '1h;1!H;${;g;s/<script[^>]*>\([^<]*\)<\/script>//g;p;}' | \
	sed 's/<.*>//g' | \
	sed  -n '1h;1!H;${;g;s/\n//g;p;}' | \
	sed 's/[ ]\+/ /g' | \
	sed 's/.*Results Success //g' | \
	sed 's/Passed /\n/g' | \
	sed '$d' | ./parser > $4
}

function get_prob { # $1 $2 $3 => round prob file_path

	printf '
		<HTML>
		<HEAD>
		   <TITLE>TopCoder Offline - Problem Statement</TITLE>
			<style type="text/css">
				a:link {color: white}
				a:visited {color: white}
		  	</style>
		</HEAD>
		<BODY text="#FFFFFF">' > $3

	curl -b "$header_info" "$site_ip""stat?c=problem_statement&pm=$2&rd=$1" | \
	sed  -n '1h;1!H;${;g;s/.*<!-- BEGIN BODY -->\(.*\)<p><br><\/p>[ \t\n]*<!-- END BODY -->.*/\1/g;p;}' | 
	sed  -n '1h;1!H;${;g;s/<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="100%">.*&#160;&#160;Problem Statement&#160;&#160;.*\(<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="10" BGCOLOR="#001B35" WIDTH="100%">\)/\1/g;p;}' >> $3
	printf '</BODY></HTML>' >> $3
}

## here comes main ##

if [ $(login) == '1' ]; then
	echo 'Login Failed -- Please check your username, password and network environment'
	exit 1
fi

echo 'Logged in'
#match_num=`wc -l "$temp_dir/matches" | sed 's/\([0-9]*\).*$/\1/g'`
cat "$temp_dir/matches" | \
while read line
do
#	head -n $i "$temp_dir/matches" | tail -1 | read round name
	read -r round round_name <<< "$line"
	dir="SRM$round_name"
	mkdir -p $dir
	printf "\n\n========== SRM$round_name ==========\n\n"
	curl -b "$header_info" "$site_ip""stat?c=round_overview&rd=$round" | \
	grep '/stat?c=problem_statement&pm' | sed 's/.*pm=\([0-9]*\)&rd=[0-9]*" class="statText">\(.*\)<\/A.*$/\1 \2/g' | \
	while read prob_line
	do
		read -r prob prob_name <<< "$prob_line"
		full_path="$dir/$prob_name"
		mkdir -p "$full_path"
		ct=$(get_id $round $prob)
		if [ "$ct" != '' ]; then
			get_data $round $prob $ct "$full_path/testcases.txt"
		fi
		get_prob $round $prob "$full_path/prob.html"

		printf "\n\n$prob_name\n\n"
	done
	printf "\n\n========== SRM$round_name ==========\n\n"
done

##                 ##
