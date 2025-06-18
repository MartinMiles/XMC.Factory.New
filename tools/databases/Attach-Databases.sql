EXEC sys.sp_configure N'contained database authentication', N'1'
go
exec ('RECONFIGURE WITH OVERRIDE')
go


CREATE DATABASE [Sitecore.Old]
  ON (FILENAME = 'C:\data\Sitecore.Old.mdf'),
     (FILENAME = 'C:\data\Sitecore.Old_Log.ldf')
  FOR ATTACH;

CREATE DATABASE [Sitecore.CoreOld]
  ON (FILENAME = 'C:\data\Sitecore.CoreOld.mdf'),
     (FILENAME = 'C:\data\Sitecore.CoreOld_Log.ldf')
  FOR ATTACH;
