# pg_backup.sh
simple postgresql backup script
## 参数配置  
```
BASEDIR="toYourBackupBaseDir"  
WALDIR="toYourWalArchiveDir"
MAXCOPY=7 #最多保存备份数量
```
## postgresql.conf
```
wal_level = logical #postgres 10
wal_level = hot_standby #postgres 9
archive_mode = on
archive_command = 'cp %p toYourWalArchiveDir/%f'
```
## contab
每周一 
`30 2 * * 1  /pathToYourScriptDir/pg_backup.sh`
  


