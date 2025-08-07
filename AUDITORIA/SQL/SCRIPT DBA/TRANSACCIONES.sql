SELECT tx_sess.session_id,
       sess.login_name AS [Login Name],
       DB_NAME ( tx_db.database_id ) AS [Database],
       tx_db.database_transaction_begin_time AS [Begin Time],
       tx_db.database_transaction_log_bytes_used AS [Log Bytes],
       tx_db.database_transaction_log_bytes_reserved AS [Log Reserved],
       sql_text.text AS [Last T-SQL Text],
       query_plan.query_plan AS [Last Plan]
FROM sys.dm_tran_database_transactions AS tx_db
INNER JOIN sys.dm_tran_session_transactions AS tx_sess ON tx_sess.transaction_id = tx_db.transaction_id
INNER JOIN sys.dm_exec_sessions AS sess ON sess.session_id = tx_sess.session_id
INNER JOIN sys.dm_exec_connections AS conn ON conn.session_id = tx_sess.session_id
LEFT JOIN sys.dm_exec_requests AS req ON req.session_id = tx_sess.session_id
OUTER APPLY sys.dm_exec_sql_text ( conn.most_recent_sql_handle ) AS sql_text
OUTER APPLY sys.dm_exec_query_plan ( req.plan_handle ) AS query_plan
ORDER BY tx_db.database_transaction_begin_time ASC;
