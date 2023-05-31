
SELECT Campo = CASE
				WHEN DATA_TYPE IN ('varchar') THEN 'Isnull(tAYCasignacionCarteraD.' + COLUMN_NAME + ','') AS AsignacionCarteraD' + COLUMN_NAME + ','
				WHEN DATA_TYPE IN ('int', 'numeric') THEN 'Isnull(tAYCasignacionCarteraD.' + COLUMN_NAME + ',0) AS AsignacionCarteraD' + COLUMN_NAME + ' ,'
				WHEN DATA_TYPE IN ('date', 'datetime') THEN 'Isnull(tAYCasignacionCarteraD.' + COLUMN_NAME + ',''19000101'') AS AsignacionCarteraD' + COLUMN_NAME + ','
			END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tAYCasignacionCarteraD'