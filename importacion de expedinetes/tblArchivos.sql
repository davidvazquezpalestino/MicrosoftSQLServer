DROP TABLE dbo.tblArchivos

GO

CREATE TABLE dbo.tblArchivos(
	IdArchivo int IDENTITY(1,1) NOT NULL,
	Nombre varchar(100) NULL,
	Extension varchar(50) NULL,
	Fecha date NULL,	
	Longitud numeric(23, 8) NULL,
	IdEstatusSincronizacion int NULL,
	IdEstatus int NULL,
	IdRegistro int NULL,
	documento char(20) NULL,
	persona varchar(100) NULL,
	socio char(20) NULL,
	EsAutogenerado bit not null default 1,
	pathFile nvarchar(250),
	IdRequisito int,
	IdRequisitoD int,
	IdListaD int NULL,
	IdTipoDdominio int,
	version int,
	sincronizo bit
) 
GO

SET ANSI_PADDING OFF
GO

ALTER TABLE dbo.tblArchivos ADD  CONSTRAINT DF_tblArchivos_Fecha  DEFAULT (getdate()) FOR Fecha
GO


