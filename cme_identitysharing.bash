#!/bin/bash

: '
------- No supported in production -------
Enable Identity Sharing feature under IA
Needs to be run in Autoprovision template with "IDSHARING" as a custom parameter and also 
Rulebase name to install as second Parameter and Name of the GW where we will take the identities
------- No supported in production -------
'

. /var/opt/CPshrd-R80.40/tmp/.CPprofile.sh

AUTOPROV_ACTION=$1
GW_NAME=$2
CUSTOM_PARAMETERS=$3
RULEBASE=$4
IDSHARINGGW=$5
RULEBASE_SH=$6

if [[ $AUTOPROV_ACTION == delete ]]
then
		exit 0
fi

if [[ $CUSTOM_PARAMETERS != IDSHARING ]];
then
	exit 0
fi

if [[ $CUSTOM_PARAMETERS == IDSHARING ]]
then

INSTALL_STATUS=1
INSTALL_STATUS_SH=1
POLICY_PACKAGE_NAME=$RULEBASE
POLICY_PACKAGE_NAME_SH=$RULEBASE_SH

	echo "Connection to API server"
	SID=$(mgmt_cli -r true login -f json | jq -r '.sid')
	GW_JSON=$(mgmt_cli --session-id $SID show simple-gateway name $GW_NAME -f json)
	GW_UID=$(echo $GW_JSON | jq '.uid')
	GW_JSON_SH=$(mgmt_cli --session-id $SID show simple-gateway name $IDSHARINGGW -f json)
	GW_UID_SH=$(echo $GW_JSON_SH | jq '.uid')
	
	echo "adding Sharing GW to the list and enabling sharing"
		
		mgmt_cli --session-id $SID set generic-object uid $GW_UID identityAwareBlade.idServerGateway.add $GW_UID_SH
		mgmt_cli --session-id $SID set generic-object uid $GW_UID identityAwareBlade.enableOtherGateways true
		
	echo "Publishing changes"
		mgmt_cli publish --session-id $SID
		
	echo "Install policy"
		until [[ $INSTALL_STATUS != 1 ]]; do
			mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME targets $GW_UID
			INSTALL_STATUS=$?
		done
		
	echo "Policy Installed"
	
	echo "Install policy"
		until [[ $INSTALL_STATUS_SH != 1 ]]; do
			mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME_SH targets $GW_UID_SH
			INSTALL_STATUS=$?
		done
		
	echo "Policy Installed"

        echo "Logging out of session"
        mgmt_cli logout --session-id $SID
			
		exit 0
fi

exit 0
