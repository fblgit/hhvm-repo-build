#!/bin/bash
HHVM_REPO_ENABLED=${HHVM_REPO_ENABLED:-1}
if [[ "$HHVM_REPO_ENABLED" == "1" ]]; then
  /scripts/hhvm-repo.sh
else
  sed -i s'/hhvm.repo.authoritative = true//' /etc/hhvm/server.ini
fi
exec supervisord -n
