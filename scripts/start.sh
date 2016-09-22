#!/bin/bash
/scripts/hhvm-repo.sh
exec supervisord -n
