USE IERP_SOTRES_NOMINA;

-- Disable all the constraint in database
EXEC sp_msforeachtable @command1 = "ALTER TABLE ? NOCHECK CONSTRAINT all"

--Disable all triggers en database
EXEC sp_msforeachtable @command1 = "ALTER TABLE ? DISABLE TRIGGER ALL"


