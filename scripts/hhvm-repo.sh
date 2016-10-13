#!/bin/bash
WWW_ROOT=${WWW_ROOT:-/mnt/ssd_vg/cache_lv}
HHVM_SYNC=${HHVM_SYNC:-1}
HHVM_SYNC_FOLDER=${HHVM_SYNC_FOLDER:-/mnt/hhvm_repo}
HHVM_REPO=${HHVM_REPO:-/mnt/hhvm}
HHVM_CFG=${HHVM_CFG:-/etc/hhvm/server.ini}
REPO_FILE=${HHVM_FILE:-hhvm.hhbc}
HHVM_FORCE=${HHVM_FORCE:-0}
HHVM_LOCK=$HHVM_SYNC_FOLDER/repo.lock
HHVM_POSTFIX=${HHVM_POSTFIX:-0}
HHVM_POSTFIX_CONFIG=${HHVM_POSTFIX_CONFIG:-/postfix_cfg}
HHVM_MAILNAME=${HHVM_MAILNAME:-localhost}
CACHEFS_ENABLED=${CACHEFS_ENABLED:-0}
CACHEFS_TARGET=${CACHEFS_TARGET:-/mnt/cache}
CACHEFS_CACHE=${CACHEFS_CACHE:-/mnt/shm}
CACHEFS_MOUNT=${CACHEFS_MOUNT:-/var/www}
CACHEFS_URL=${CACHEFS_URL:-"https://github.com/cconstantine/CacheFS/archive/master.zip"}

##############
if [[ "$CACHEFS_ENABLED" == "1" ]] && [[ -d $CACHEFS_TARGET ]] && [[ -d $CACHEFS_CACHE ]]; then
  if [[ ! -d $CACHEFS_MOUNT ]]; then
    mkdir -p $CACHEFS_MOUNT
    echo Created accelerated folder $CACHEFS_MOUNT
  fi
  if [[ ! -f "/root/cachefs.zip" ]]; then
    wget -qO /root/cachefs.zip $CACHEFS_URL
  fi
  if [[ -f /root/cachefs.zip ]]; then
    if [[ -d "/root/CacheFS-master" ]]; then
      FOLD=/root/CacheFS-master
    else
      cd /root
      FOLD=`unzip cachefs.zip | grep 'creating:' | awk '{print $2}' | head -1`
      cd -
    fi
  else
    echo Error downloading CacheFS
  fi
  if [[ -d "$FOLD" ]]; then
    cd /root/$FOLD && ./cachefs.py ${CACHEFS_MOUNT} -o target=${CACHEFS_TARGET},cache=${CACHEFS_CACHE} && cd -
    echo Fusion CacheFS enabled $CACHEFS_TARGET accelerated to $CACHEFS_MOUNT via $CACHEFS_CACHE
  else
    echo Error installing CacheFS
  fi
else
  echo CacheFS disabled
fi
mkdir -p $HHVM_REPO
if [[ -d $WWW_ROOT ]]; then
  if [[ -f "$HHVM_REPO/$REPO_FILE" ]]; then
      echo HHVM BC Already Exist
      if [[ "$HHVM_FORCE" == "1" ]]; then
        echo Forcing Rebuild
        rm -f $HHVM_LOCK
      else
        exit 0
      fi
  fi
  if [[ "$HHVM_POSTFIX" == "1" ]] && [[ -d $HHVM_POSTFIX_CONFIG ]]; then
    echo Postfix Configuration OK
    rsync -av --progress --delete $HHVM_POSTFIX_CONFIG/ /etc/postfix/
    echo $HHVM_MAILNAME > /etc/mailname
    service postfix start
  fi
  if [[ -d $HHVM_SYNC_FOLDER ]] && [[ "$HHVM_SYNC" == "1" ]]; then
    echo Sync $HHVM_SYNC_FOLDER to $HHVM_REPO
    mkdir -p $HHVM_REPO
    rsync -av --progress --delete $HHVM_SYNC_FOLDER/ $HHVM_REPO/
  fi
  if [[ -f $HHVM_LOCK ]]; then
    echo HHVM Repo File Locked at `cat $HHVM_LOCK`
    exit 2
  fi
  if [[ -d $HHVM_SYNC_FOLDER ]] && [[ "$HHVM_SYNC" == "1" ]]; then
    date > $HHVM_LOCK
  fi
  HHVM_BC=`echo $HHVM_REPO|sed -e 's/\//\\\\\//g'`\\/$REPO_FILE
  mkdir -p $HHVM_REPO
  sed -i "s/.*hhvm.repo.central.path.*/hhvm.repo.central.path=${HHVM_BC}/g" $HHVM_CFG
  hhvm-repo-mode enable $WWW_ROOT
  if [[ -d $HHVM_SYNC_FOLDER ]] && [[ "$HHVM_SYNC" == "1" ]]; then
    rsync -av --progress --delete $HHVM_REPO/ $HHVM_SYNC_FOLDER/
    rm -f $HHVM_LOCK
  fi
else
  echo $WWW_ROOT does not Exist
  exit 2
fi
