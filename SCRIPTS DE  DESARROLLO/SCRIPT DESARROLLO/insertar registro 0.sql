SELECT  char(13) + 'IF NOT EXISTS (SELECT * FROM ' + SO.NAME +' WHERE '+ SC.NAME +' = 0) '+ char(13) +'BEGIN '+ char(13) +'	PRINT ''Error en la tabla ' + SO.NAME +', no existe el registro 0.'' '+ char(13) +'	SET IDENTITY_INSERT [' + SO.NAME +'] ON;'+ char(13) +'	INSERT INTO ['+ SO.NAME +'] ('+ SC.NAME +')   VALUES (0);'+ char(13) +'	SET IDENTITY_INSERT [' + SO.NAME +'] OFF;'+ char(13) +'END' as script
FROM SYS.OBJECTS SO 
INNER JOIN SYS.COLUMNS SC ON SO.OBJECT_ID = SC.OBJECT_ID
WHERE SO.NAME LIKE 'T%' AND COLUMN_ID = 1







