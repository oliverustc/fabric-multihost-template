. scripts/utils.sh
. scripts/env.sh

function remoteDown(){
  IP=$(ip route | head -1 | cut -d' ' -f9)
  
  println "\n remove blockchain config and cert files on ${IP} ... \n" 
  
  removeDir ${HOME}/${PROJECT_NAME}/channel-artifacts
  
  removeDir ${HOME}/${PROJECT_NAME}/system-genesis-block
  
  removeDir ${HOME}/${PROJECT_NAME}/organizations
  
  removeDir ${HOME}/${PROJECT_NAME}/scripts
  
  removeDir ${HOME}/${PROJECT_NAME}/remote-scripts
  
  removeContainer
  
  removeFile ${HOME}/${PROJECT_NAME}/docker/docker-compose-up.yaml
  
  removeFile ${HOME}/${PROJECT_NAME}/*.tar.gz

  set -x
  rm -rf chaincode/*
  set +x
}

function remoteUp(){
  IP=$(ip route | head -1 | cut -d' ' -f9)

  echo -e "\n start docker containers by docker-compose on ${IP} ... \n"

  set -x
  docker-compose -f docker/docker-compose-up.yaml up -d 
  set +x 

  sleep 3
  echo -e "\n sleep 3 seconds for containers ...\n"

  docker ps --format "{{.ID}}\t{{.Status}}\t{{.Names}}"

}

function remoteInit() {

  if [ "${IPHOST_DISTRIBUTED}" == "true" ]; then
    infoln "\n ip-hosts already distributed, skip ... \n"
  else
    addIpHost
  fi
  mkdir -p docker chaincode

}

function addIpHost(){
  IP=$(ip route | head -1 | cut -d' ' -f9)
  infoln "distribute ip hosts and insert to /etc/hosts on $IP..."
  cat ~/${PROJECT_NAME}/iphosts | sudo tee -a /etc/hosts > /dev/null
  infoln "\n after that ... \n"
  cat /etc/hosts
}


command=$1

if [ "$command" == "init" ]; then
  remoteInit
elif [ "$command" == "up" ]; then
  remoteUp
elif [ "$command" == "down" ]; then
  remoteDown
else
  echo "wrong input !!"
fi

