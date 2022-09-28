#!/bin/bash

function upload(){
	if [ ! -z "$1" ]; then
		local f=$1
		local ctype=$(file -b --mime-type $f)
		echo "Sub: "$(pwd)
		echo ":Getting URL for: $f"
		if [ ! -z "$2" ];
		then
			local path=$2
			local fullkey=${path}/${f}
		else
			local fullkey=${f}
		fi
		echo "curl -s https://${idapi}.execute-api.${region}.amazonaws.com/prod/presign?filename=${fullkey}\&bucketname=${bucketname}\&ctype=${ctype}"
		response=$(eval "curl -s https://${idapi}.execute-api.${region}.amazonaws.com/prod/presign?filename=${fullkey}\&bucketname=${bucketname}\&ctype=${ctype}")
		echo "::Uploading"
		eval "curl -# -L -H \"Content-Type: ${ctype}\" --upload-file ${f} ${response}"
	fi
}

function filebrowse(){
	if [ ! -z "$1" ]; 
	then
		local workingdir=$1
		cd ${workingdir}
		if [ ! -z "$2" ];
		then
			local basepath=$2
			local currpath="${basepath}/${workingdir}"
		else
			local currpath="${workingdir}"
		fi
					
	fi

	
	for file in * ; 
		do 
			if [ "$file" != "." ] && [ "$file" != ".." ] && [ "$file" != "*" ]; then
				if [ -d $file ];
				then

					if [ ! -z "$currpath" ]; 
					then
						echo "$currpath/${file}[d] \n";
					else
						echo "${file}[d] \n";
					fi
					echo $(filebrowse $file $currpath)
				else
					if [ ! -z "$currpath" ]; 
					then
						echo "$currpath/${file}[f] \n";
						printf "$(upload $file $currpath)"
					else
						echo "${file}[f] \n";
						printf "$(upload ${file})"
					fi
					
				fi
			fi
		done
	if [ ! -z "$workingdir" ]; 
	then
		cd ..
	fi
}

while getopts hf:b:a:r: args; do
case ${args} in
	 h)
        echo "Upload files to S3.";
        echo "Usage:";
        echo "s3upload.sh -a <API_ID> -r <REGION> -b <BUCKET> -f <FILE>"
        echo "FILE: File to upload"
        echo "BUCKET: Destination bucket."
        echo "REGION: Region where bucket is located."
        echo "API_ID: API ID for signing requests."
        exit;;
        r) region=${OPTARG};;
	a) idapi=${OPTARG};;
	b) bucketname=${OPTARG};;
	f) filename+=(${OPTARG});;
	:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$bucketname" ]; then
        echo 'Bucket not specified.' >&2
        echo 'Try: s3upload.sh -h'
        exit 1
fi



if [ ${#filename} -gt 0 ]; then
	echo "Mapping specific files"
	for val in "${filename[@]}"; do
		printf "$(upload $val)"
	done
else
	echo "No file specified, working on complete directory"
	printf "$(filebrowse)"
fi

echo "Finalized"
echo "==========================="
