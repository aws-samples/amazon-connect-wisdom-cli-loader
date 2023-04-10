#!/bin/bash
while getopts 'ha:c:' args; do
	case ${args} in
		 h)
	        echo "Create a Wisdom Assistant for Amazon Connect.";
	        echo "Usage:";
	        echo "wisdom-helper -a ASSISTANT-NAME -c CONNECT-ID";
	        echo "ASSISTANT-NAME: Wisdom assistant name.";
	        echo "CONNECT-ID: Amazon Connect Instance Id "
	        exit;;
	    a) assistName=${OPTARG};;
	    c) connectId=${OPTARG};;
		:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
	esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$assistName" ]; then
        echo 'Assistant name not specified.' >&2
        echo 'Try: wisdom-helper.sh -h'
        exit 1
fi

if [ -z "$connectId" ]; then
        echo 'Connect instance Id not specified' >&2
        echo 'Try: wisdom-helper.sh -h'
        exit 1
fi


if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed or properly configured.' >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed or properly configured.' >&2
  exit 1
fi

assistantDetails=$(aws wisdom create-assistant --name $assistName --type AGENT| jq -r '.assistant|{assistantId,assistantArn}')

assistantId=$(echo ${assistantDetails}|jq -r '.assistantId')
assistantArn=$(echo ${assistantDetails}|jq -r '.assistantArn')
echo "Assistant Id: $assistantId"

kbDetails=$(aws wisdom create-knowledge-base --name $assistName --knowledge-base-type CUSTOM| jq -r '.knowledgeBase|{knowledgeBaseId,knowledgeBaseArn}')
kbId=$(echo ${kbDetails}|jq -r '.knowledgeBaseId')
kbArn=$(echo ${kbDetails}|jq -r '.knowledgeBaseArn')
echo "KB Id: $kbId"

association=($(aws wisdom create-assistant-association --association-type KNOWLEDGE_BASE --assistant-id ${assistantId} --association knowledgeBaseId=${kbId}| jq -r '.'))
  
assistAssoc=($(aws connect create-integration-association --instance-id $connectId --integration-type WISDOM_ASSISTANT --integration-arn $assistantArn| jq -r '.IntegrationAssociationArn'))
echo "Assistant association ARN : $assistAssoc"
kbAssoc=($(aws connect create-integration-association --instance-id $connectId --integration-type WISDOM_KNOWLEDGE_BASE --integration-arn $kbArn| jq -r '.IntegrationAssociationArn'))
echo "KB association ARN : $kbAssoc"

unset assistName
unset connectId
unset kbDetails
unset assistantId
unset assistantArn
unset association
unset kbArn
unset kbId
unset kbAssoc
unset assistAssoc


