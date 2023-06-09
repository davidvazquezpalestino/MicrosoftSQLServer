SELECT
	s.session_id,
	s.login_name,
	s.host_name,
	s.status,
	s.program_name,
	s.cpu_time,
	(SELECT
			text
		FROM sys.dm_exec_sql_text(c.most_recent_sql_handle))
	AS query_text
FROM	sys.dm_exec_sessions s,
		sys.dm_exec_connections c
WHERE s.session_id = c.session_id
AND s.session_id > 50
ORDER BY s.last_request_start_time DESC