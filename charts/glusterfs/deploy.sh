
if [ "$#" -ne 2 ]; then
    echo "./deploy.sh <type> <ips>"
    exit
fi

ansible-playbook --private-key ~/.ssh/it -u ubuntu -i $2, -e "service=$1" main.yaml