# SQL Server settings

Define those in the `SqlServer.json` file

- `ServerInstance`
- `Username`
- `Password`


# Restore databases from backups

Drop backups into a folder: `c:\Projects\XMC.Factory\local-containers\docker\data\sql`

Example:
- `rssb.core.bak`
- `rssb.master.bak`


# Attach existing databases

Make sure the below files exist under `c:\Projects\XMC.Factory\local-containers\docker\data\sql` folder:

- `Sitecore.CoreOld_Primary.ldf`
- `Sitecore.CoreOld_Primary.mdf`
- `Sitecore.Old_Primary.ldf`
- `Sitecore.Old_Primary.mdf`

Execute: `Attach-Databases.ps1`
