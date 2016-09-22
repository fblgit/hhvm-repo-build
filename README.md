# hhvm-repo-build
HHVM with Repo-Build and Sync Enabled

Flow:

  >> Start Docker Container > Run RepoBuild > 
  >> Check/Sync Repo > Rebuild repo if needed/forced > Sync if Enabled >
  >> Start Supervisord > Start HHVM

Configure the following ENV VARS:

WWW_ROOT = Original WWW folder that is gonna be used to build the repo

HHVM_SYNC = 1 ON / 0 OFF Sync Replicated Repo Folder (if you have multiple instances for the same content, this will sync)

HHVM_SYNC_FOLDER = Folder with the replicated repo

HHVM_REPO = Folder with local repo (suggest SHM RAM)

HHVM_CFG = Path for the HHVM.INI (default: /etc/hhvm/server.ini)

REPO_FILE = Filename for the RepoBuild (default: hhvm.hhbc)

HHVM_FORCE = 1 ON / 0 OFF Force rebuild the repo, no matter what.

Based on Debian
