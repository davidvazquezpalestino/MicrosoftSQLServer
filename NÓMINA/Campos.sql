

IF NOT EXISTS(SELECT 1 FROM SYS.COLUMNS Columna WHERE Columna.NAME ='IdOperacion' AND Columna.OBJECT_ID = OBJECT_ID ('tIMPcomprobantesFiscales'))ALTER TABLE dbo.tIMPcomprobantesFiscales ADD IdOperacion INT NOT NULL DEFAULT 0
IF NOT EXISTS(SELECT 1 FROM SYS.COLUMNS Columna WHERE Columna.NAME ='IdAuxiliar' AND Columna.OBJECT_ID = OBJECT_ID ('tIMPcomprobantesFiscales'))ALTER TABLE dbo.tIMPcomprobantesFiscales ADD IdAuxiliar INT NOT NULL DEFAULT 0
