
SELECT BaseDatos = rs.destination_database_name, 
	   FechaRestauracion = MAX(rs.restore_date)
FROM msdb..restorehistory rs
WHERE rs.destination_database_name = DB_NAME(DB_ID())
GROUP BY rs.destination_database_name
ORDER BY FechaRestauracion DESC;
