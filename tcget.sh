#! /bin/bash

site_name='community.topcoder.com/tc'
site_ip='http://209.202.141.182/'
url="http://$site_name?&module=Login"
temp_dir='/tmp'
user='your tc username'
passwd='your tc password'
header_info='header.txt'
round=$1
prob=$2

function login {

	curl -3 "$site_ip""tc" -H "Host: community.topcoder.com" -e "$url" -d "&module=Login&username=$user&password=$passwd" -D "$header_info"
}

function get_id() { # $1, $2 => round prob

	curl -3 -b "$header_info" "$site_ip""tc?module=ProblemDetail&pm=$2&rd=$1" > "$temp_dir/top_submission"
	local res=`grep problem_solution "$temp_dir/top_submission" | sed "s/.*stat?c=problem_solution&amp;cr=\([0-9]*\)&amp;rd=$1&amp;pm=$2.*/\1/g" | tail -1`
	echo $res
}

function get_data { # $1 $2 $3 $4 => round prob ct file_path

	curl -b "$header_info" "$site_ip""stat?c=problem_solution&pm=$2&rd=$1&cr=$3" > "$temp_dir/t.html"
	sed  -n '1h;1!H;${;g;s/<TD[^>]*>\([^<]*\)<\/TD>/\1/g;p;}' "$temp_dir/t.html" | 
	sed  -n '1h;1!H;${;g;s/<script[^>]*>\([^<]*\)<\/script>//g;p;}' | 
	sed 's/<.*>//g' | 
	sed  -n '1h;1!H;${;g;s/\n//g;p;}' | 
	sed 's/[ ]\+/ /g' | 
	sed 's/.*Results Success //g' | 
	sed 's/Passed /\n/g' | 
	sed '$d' > $4

}

function get_prob { # $1 $2 $3 => round prob file_path

	curl -b "$header_info" "$site_ip""stat?c=problem_statement&pm=$2&rd=$1" > $3
}

## here comes main ##

login
#match_num=`wc -l "$temp_dir/matches" | sed 's/\([0-9]*\).*$/\1/g'`
cat "$temp_dir/matches" | \
while read line
do
#	head -n $i "$temp_dir/matches" | tail -1 | read round name
	read -r round round_name <<< "$line"
	dir="SRM$round_name"
	mkdir -p $dir
	curl -b "$header_info" "$site_ip""stat?c=round_overview&rd=$round" > "$temp_dir/overview" 
	grep '/stat?c=problem_statement&pm' "$temp_dir/overview" | sed 's/.*pm=\([0-9]*\)&rd=[0-9]*" class="statText">\(.*\)<\/A.*$/\1 \2/g' | \
	while read prob_line
	do
		read -r prob prob_name <<< "$prob_line"
		full_path="$dir/$prob_name"
		mkdir -p "$full_path"
		ct=$(get_id $round $prob)
		get_data $round $prob $ct "$full_path/test_cases"
		get_prob $round $prob "$full_path/prob.html"

		echo "$prob_name"
	done
	echo "SRM$round_name"
	echo '======'
done

##                 ##
