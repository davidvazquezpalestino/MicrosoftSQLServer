SELECT DB_NAME ( s.database_id ) AS DBName,
       COUNT ( * ) AS NumberOfConnections,
       s.login_name AS LoginName,
       MAX ( s.login_time ) AS LastLogin
FROM sys.dm_exec_sessions AS s
WHERE s.database_id IS NOT NULL
GROUP BY s.database_id,
         s.login_name
ORDER BY NumberOfConnections DESC;