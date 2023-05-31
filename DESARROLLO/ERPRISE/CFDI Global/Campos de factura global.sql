

IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='tGRLoperaciones' AND COLUMN_NAME= 'IdOperacionFactura')
ALTER TABLE dbo.tGRLoperaciones ADD IdOperacionFactura INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT OBJECT_ID FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID ('tGRLoperaciones') AND name = 'FK_tGRLoperaciones_IdOperacionFactura')
ALTER TABLE dbo.tGRLoperaciones ADD CONSTRAINT FK_tGRLoperaciones_IdOperacionFactura FOREIGN KEY (IdOperacionFactura) REFERENCES tGRLoperaciones ( IdOperacion );

IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tFELfacturaGlobalIngresos' AND COLUMN_NAME='IdOperacionFactura')
ALTER TABLE tFELfacturaGlobalIngresos ADD IdOperacionFactura INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT object_id FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID('tFELfacturaGlobalIngresos')AND name='FK_tFELfacturaGlobalIngresos_IdOperacionFactura')
ALTER TABLE dbo.tFELfacturaGlobalIngresos ADD CONSTRAINT FK_tFELfacturaGlobalIngresos_IdOperacionFactura FOREIGN KEY(IdOperacionFactura)REFERENCES dbo.tGRLoperaciones(IdOperacion);
