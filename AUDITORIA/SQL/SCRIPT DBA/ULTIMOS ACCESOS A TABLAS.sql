


SELECT  tab.name AS TableName ,
        SUM(user_seeks) AS user_seeks ,
        SUM(user_scans) AS user_scans ,
        SUM(user_lookups) AS user_lookups ,
        AVG(user_updates) AS user_updates ,
        MAX(last_user_seek) AS last_user_seek ,
        MAX(last_user_scan) AS last_user_scan ,
        MAX(last_user_lookup) AS last_user_lookup ,
        MAX(last_user_update) AS last_user_update
FROM    sys.dm_db_index_usage_stats ius
        JOIN sys.tables tab ON ( tab.object_id = ius.object_id )
WHERE   database_id = DB_ID(N'iERP_CAZ')
GROUP BY tab.name
ORDER BY last_user_scan DESC;