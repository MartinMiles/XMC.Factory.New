EXEC sys.sp_configure N'contained database authentication', N'1'
go
exec ('RECONFIGURE WITH OVERRIDE')
go


-- 1) Folder & working variables
DECLARE 
  @BackupFolder    NVARCHAR(260) = N'C:\data',
  @DataFolder      NVARCHAR(260) = N'C:\data',
  @LogFolder       NVARCHAR(260) = N'C:\data',
  @FileName        NVARCHAR(260),
  @NewDbName       NVARCHAR(128),
  @LogicalDataName NVARCHAR(128),
  @LogicalLogName  NVARCHAR(128),
  @FullPath        NVARCHAR(500),
  @SQL             NVARCHAR(MAX);

-- 2) Manual mapping with corrected logical names
DECLARE @Files TABLE (
  FileName        NVARCHAR(260),
  NewDbName       NVARCHAR(128),
  LogicalDataName NVARCHAR(128),
  LogicalLogName  NVARCHAR(128)
);

INSERT INTO @Files(FileName, NewDbName, LogicalDataName, LogicalLogName)
VALUES
  ('rssb.core.bak',   'Sitecore.CoreOld', 'RssbPlatform_Core',    'RssbPlatform_Core_log'),
  ('rssb.master.bak', 'Sitecore.Old',     'RssbPlatform_Master',  'RssbPlatform_Master_log');

-- 3) Drop existing targets (if any) and restore each backup
DECLARE cur CURSOR LOCAL FAST_FORWARD
  FOR SELECT FileName, NewDbName, LogicalDataName, LogicalLogName FROM @Files;

OPEN cur;
FETCH NEXT FROM cur INTO @FileName, @NewDbName, @LogicalDataName, @LogicalLogName;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @FullPath = @BackupFolder + N'\' + @FileName;

  -- Drop if exists
  IF DB_ID(@NewDbName) IS NOT NULL
  BEGIN
    EXEC(N'
      ALTER DATABASE [' + @NewDbName + N'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE [' + @NewDbName + N'];
    ');
  END

  -- Restore with MOVE
  SET @SQL = N'
    RESTORE DATABASE [' + @NewDbName + N']
      FROM DISK = N''' + @FullPath + N'''
      WITH 
        MOVE N''' + @LogicalDataName + N''' 
           TO N''' + @DataFolder + N'\' + @NewDbName + N'.mdf''' + N',
        MOVE N''' + @LogicalLogName + N''' 
           TO N''' + @LogFolder + N'\' + @NewDbName + N'_Log.ldf''' + N',
        REPLACE, STATS = 5;
  ';

  PRINT N'*** Restoring: ' + @NewDbName;
  EXEC sp_executesql @SQL;

  FETCH NEXT FROM cur INTO @FileName, @NewDbName, @LogicalDataName, @LogicalLogName;
END

CLOSE cur;
DEALLOCATE cur;
