
SELECT 
      spid,
      intelixDEV.dbo.sysprocesses.status,
      hostname,
      program_name,
      cmd,
      cpu,
      physical_io,
      blocked,
      intelixDEV.dbo.sysdatabases.name,
      loginame
FROM   
      intelixDEV.dbo.sysprocesses INNER JOIN
      intelixDEV.dbo.sysdatabases ON
            sys.sysprocesses.dbid = sys.sysdatabases.dbid
ORDER BY spid
