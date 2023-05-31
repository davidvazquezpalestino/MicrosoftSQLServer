

SELECT * FROM dbo.tACTinformacionDepreciacion


UPDATE dbo.tACTinformacionDepreciacion SET IdSucursal = 0 WHERE IdSucursal IS NULL
UPDATE dbo.tACTinformacionDepreciacion SET IdActivo = 0 WHERE IdActivo IS NULL
UPDATE dbo.tACTinformacionDepreciacion SET IdPeriodo = 0 WHERE IdPeriodo IS NULL
UPDATE dbo.tACTinformacionDepreciacion SET IdTipoDmetodo = 0 WHERE IdTipoDmetodo IS NULL
UPDATE dbo.tACTinformacionDepreciacion SET IdEstatus = 0 WHERE IdTipoDmetodo IS NULL


ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdSucursal INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdSucursal DEFAULT 0 FOR IdSucursal
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdSucursal FOREIGN KEY (IdSucursal) REFERENCES dbo.tCTLsucursales(IdSucursal)

ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdPeriodo INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdPeriodo DEFAULT 0 FOR IdPeriodo
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdPeriodo FOREIGN KEY(IdPeriodo) REFERENCES dbo.tCTLperiodos(IdPeriodo)

ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdActivo INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdActivo DEFAULT 0 FOR IdActivo
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdActivo FOREIGN KEY(IdActivo) REFERENCES dbo.tACTactivos(IdActivo)

ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdTipoDmetodo INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdTipoDmetodo DEFAULT 0 FOR IdTipoDmetodo
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdTipoDmetodo FOREIGN KEY(IdTipoDmetodo) REFERENCES dbo.tCTLtiposD(IdTipoDmetodo)

ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdEstatus INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdEstatus DEFAULT 0 FOR IdEstatus
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdEstatus FOREIGN KEY(IdEstatus) REFERENCES dbo.tCTLestatus(IdEstatus)

ALTER TABLE dbo.tACTinformacionDepreciacion ALTER COLUMN IdEstatus INT NOT NULL 
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT DF_tACTinformacionDepreciacion_IdTipoDmetodo DEFAULT 0 FOR IdTipoDmetodo
ALTER TABLE dbo.tACTinformacionDepreciacion ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdTipoDmetodo FOREIGN KEY(IdTipoDmetodo) REFERENCES dbo.tCTLtiposD(IdTipoDmetodo)


	
ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN IdOperacionD 
ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN IdOperacion 

ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN IdTipoDvalorDepreciado	
ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN IdTipoDvidaDepreciada

ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN VidaDepreciacionAcumulada	
ALTER TABLE dbo.tACTinformacionDepreciacion DROP COLUMN VidaDepreciacionCalculada



UPDATE x SET x.IdTipoOperacion = 536
FROM dbo.tACTinformacionDepreciacion x 
WHERE Entrada IS NOT NULL 

ALTER TABLE dbo.tACTinformacionDepreciacion ADD IdTipoOperacion INT NOT NULL DEFAULT 0

EXECUTE sys.sp_rename @objname = N'tACTinformacionDepreciacion.Entrada',
    @newname = 'Ajuste',
    @objtype = 'Column'
