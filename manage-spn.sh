#! /usr/bin/bash

set -euo "pipefail"

usage() {
    echo -e "\e[94mThe following provides the usage of the script:\e[37m"
    echo -e "   \e[92m${0} -c -n 'spn-1'\e[90m: Creates a service principal named 'spn-1' and assigns it contributor role over the current subscription."
    echo -e "   \e[92m${0} -d -n 'spn-1'\e[90m: Deletes a service principal named 'spn-1'."
    exit 1
}

check_authentication() {
    if ! az account show >/dev/null 2>&1; then 
        echo -e '\e[91mYou are not logged in! To log in correctly, please run: az login --use-device-code\e[37m'
        exit 1
    fi 
}

create_service_principal() {
    local name=$1

    if [[ "$(az ad sp list --display-name ${name})" != "[]" ]]; then 
        echo -e "\e[91m${name} already exists!\e[37m"
        exit 1
    fi

    az ad sp create-for-rbac \
        --name "${name}" \
        --role "contributor" \
        --scopes "/subscriptions/$(az account show | jq --raw-output '.id')"
}

delete_service_principal() {
    local name=$1

    enterprise_registration=$(az ad sp list --display-name "${name}")
    app_registration=$(az ad app list --display-name "${name}")

    if [[ "${enterprise_registration}" == "[]" ]] && [[ "${app_registration}" == "[]" ]]; then 
        echo -e "\e[91m${name} doesn't exist so cannot be deleted!\e[37m"
        exit 1
    fi

    az ad sp delete --id $(echo "${enterprise_registration}" | jq --raw-output '. | .[] | .appId')
    az ad app delete --id $(echo "${app_registration}" | jq --raw-output '. | .[] | .appId')
}

########## BEGIN SCRIPT ##########
check_authentication

create_mode=false
delete_mode=false
spn_name=''

while getopts ':cdn:' option; do
    case "${option}" in 
        (c) create_mode=true
        ;;
        (d) delete_mode=true
        ;;
        (n) spn_name=${OPTARG}
        ;;
        (*) usage
        ;;
    esac
done

if [[ -z "$*" ]]; then
    usage
fi

if $create_mode && $delete_mode; then 
    usage
fi

if $create_mode && [[ -n "${spn_name}" ]]; then
    create_service_principal "${spn_name}"
fi 

if $delete_mode && [[ -n "${spn_name}" ]]; then 
    delete_service_principal "${spn_name}"
fi 
