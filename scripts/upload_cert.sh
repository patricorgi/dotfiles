#!/bin/bash

hostname=$1
scp myCertificate.p12 $hostname:~
ssh $hostname -t '[ -x "$(command -v lb-dirac)" ] || source /cvmfs/lhcb.cern.ch/lib/LbEnv; lb-dirac dirac-cert-convert ~/myCertificate.p12; rm ~/myCertificate.p12'
