#!/bin/bash
WWW_ROOT=${WWW_ROOT:-/mnt/ssd_vg/cache_lv}
HHVM_SYNC=${HHVM_SYNC:-1}
HHVM_SYNC_FOLDER=${HHVM_SYNC_FOLDER:-/mnt/hhvm_repo}
HHVM_REPO=${HHVM_REPO:-/mnt/hhvm}
HHVM_CFG=${HHVM_CFG:-/etc/hhvm/server.ini}
REPO_FILE=${HHVM_FILE:-hhvm.hhbc}
HHVM_FORCE=${HHVM_FORCE:-0}
HHVM_LOCK=$HHVM_REPO/repo.lock

##############

mkdir -p $HHVM_REPO
if [[ -d $WWW_ROOT ]]; then
  if [[ -f "$HHVM_REPO/$REPO_FILE" ]]; then
      echo HHVM BC Already Exist
      if [[ "$HHVM_FORCE" == "0" ]]; then
        echo Forcing Rebuild
        rm -f $HHVM_LOCK
      fi
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
  date > $HHVM_LOCK
  HHVM_BC=`echo $HHVM_REPO|sed -e 's/\//\\\\\//g'`\\/$REPO_FILE
  mkdir -p $HHVM_REPO
  sed -i "s/.*hhvm.repo.central.path.*/hhvm.repo.central.path=${HHVM_BC}/g" $HHVM_CFG
  hhvm-repo-mode enable $WWW_ROOT
  rsync -av --progress --delete $HHVM_REPO/ $HHVM_SYNC_FOLDER/
  rm -f $HHVM_LOCK
else
  echo $WWW_ROOT does not Exist
  exit 2
fi
