#!/bin/bash

export CORDA_HOST="${CORDA_HOST:-localhost}"
export CORDA_PORT_P2P="${CORDA_PORT_P2P:-10002}"
export CORDA_PORT_RPC="${CORDA_PORT_RPC:-10003}"
export CORDA_PORT_WEB="${CORDA_PORT_WEB:-10004}"
export CORDA_LEGAL_NAME="${CORDA_LEGAL_NAME:-Corda Test Node}"
export CORDA_ORG="${CORDA_ORG:-CordaTest}"
export CORDA_ORG_UNIT="${CORDA_ORG_UNIT:-CordaTest}"
export CORDA_COUNTRY="${CORDA_COUNTRY:-GB}"
export CORDA_CITY="${CORDA_CITY:-London}"
export CORDA_EMAIL="${CORDA_EMAIL:-admin@corda.test}"
export JAVA_OPTIONS="${JAVA_OPTIONS--Xmx512m}"
export JAVA_CAPSULE="${JAVA_CAPSULE-''}"

cd /opt/corda

cat > node.conf << EOF
basedir : "/opt/corda"
p2pAddress : "$CORDA_HOST:$CORDA_PORT_P2P"
rpcAddress : "$CORDA_HOST:$CORDA_PORT_RPC"
webAddress : "$CORDA_HOST:$CORDA_PORT_WEB"
h2port : 11000
myLegalName : "CN=$CORDA_LEGAL_NAME,O=$CORDA_ORG,OU=$CORDA_ORG_UNIT,L=$CORDA_CITY,C=$CORDA_COUNTRY, E=$CORDA_EMAIL"
keyStorePassword : "cordacadevpass"
trustStorePassword : "trustpass"
extraAdvertisedServiceIds: [ "$CORDA_EXTRA_SERVICE" ]
useHTTPS : false
devMode : true
rpcUsers=[
	{
		user=corda
		password=not_blockchain
		permissions=[
			StartFlow.net.corda.flows.CashIssueFlow,
			StartFlow.net.corda.flows.CashExitFlow,
			StartFlow.net.corda.flows.CashPaymentFlow
		]
	}
]
EOF
if [[  ${CORDA_NETMAP_ADDRESS+x} ]]; then
        cat<< EOF  >> node.conf
        networkMapService : {
          address : "$CORDA_NETMAP_ADDRESS"
          legalName : "$CORDA_NETMAP_LEGALNAME"
        }
EOF
fi

tmux

tmux new-session -d -s webserver 'java $JAVA_OPTIONS -jar /opt/corda/corda-webserver.jar >>/opt/corda/logs/web-output.log 2>&1'

exec java $JAVA_OPTIONS -Dcapsule.jvm.args="$CAPSULE_ARGS" -jar /opt/corda/corda.jar >>/opt/corda/logs/output.log 2>&1

