USE iERP_G360
-- Enable all the constraint in database
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

--Enable all the triggfers in database
EXEC sp_msforeachtable "ALTER TABLE ? ENABLE TRIGGER ALL"



SELECT *
--	UPDATE a SET a.IdEstatusActual = 0
FROM dbo.tCATlistasD a
LEFT JOIN dbo.tCTLestatusActual m ON m.IdEstatusActual = a.IdEstatusActual
WHERE m.IdEstatusActual IS NULL


DELETE FROM dbo.tSDOhistorialAcreedoras