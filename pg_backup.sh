#!/bin/bash  

#
#参数配置  
BASEDIR=""  
WALDIR=""
MAXCOPY=7
  
export LANG=en_US.utf8  
export PGHOME=/usr/pgsql-10
export LD_LIBRARY_PATH=$PGHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH  
export DATE=`date +"%Y%m%d"`  
export PATH=$PGHOME/bin:$PATH:.  
export PGDATA=/data/pgsql/10/data  
 
date +%F%T  


#开始备份  
if [ ! -d $BASEDIR/$DATE ]; then  
  mkdir -p $BASEDIR/$DATE  
  if [ $? -eq 0 ]; then  
    psql -c "select pg_start_backup(now()::text)"  
    if [ $? -eq 0 ]; then  
      cp -r -L $PGDATA $BASEDIR/$DATE  
    else  
      echo -e "select pg_start_backup(now()::text) error"  
      exit 1  
    fi  
    psql -c "select pg_stop_backup()"  
    date +%F%T  
    echo -e "backup successed"  
  else  
    echo -e "mkdir -p $BASEDIR/$DATE error"  
    exit 1  
  fi  
else  
  echo -e "$DATE backuped, don't backup repeated"  
fi  

#开始清理
baseDirs=($(ls "$BASEDIR"))
baseCount=${#baseDirs[*]}


if (($baseCount \> $MAXCOPY))
then
  #清除多余基础备份
  if [ ${baseDirs[0]} ]
  then
    #rm -rf "${BASEDIR}/${baseDirs[0]}"
    echo "rm -rf ${BASEDIR}/${baseDirs[0]}"
  fi
  #清除多余wal日志 
  if [ -f "${BASEDIR}/${baseDirs[1]}/data/backup_label" ]
  then
    latestBlock=$(sed -n '1p' "${BASEDIR}/${baseDirs[1]}/data/backup_label"|awk '{print $6}'|cut -c -24)
    walBlocks=$(ls "${WALDIR}")
    for block in $walBlocks
    do
      if [ $block == $latestBlock ]
      then
        break
      fi
      #rm -f $block
      echo "#rm -f $block"
    done 
  fi
fi