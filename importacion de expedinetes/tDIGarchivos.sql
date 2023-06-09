/*
   jueves, 16 de julio de 201505:59:44 p. m.
   Usuario: SA
   Servidor: 192.168.1.1\DEV
   Base de datos: iERP_CAZ_Produccion
   Aplicación: 
*/

/* Para evitar posibles problemas de pérdida de datos, debe revisar este script detalladamente antes de ejecutarlo fuera del contexto del diseñador de base de datos.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT FK_tDIGarchivos_tCTLsesiones
GO
ALTER TABLE dbo.tCTLsesiones SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT FK_tDIGarchivos_tCTLestatus
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT FK_tDIGarchivos_tCTLestatus1
GO
ALTER TABLE dbo.tCTLestatus SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT FK_tDIGarchivos_tCATlistasD
GO
ALTER TABLE dbo.tCATlistasD SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdArchivo
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdArchivoPadre
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Nombre
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Fecha
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdListaD
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Longitud
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_EsAutogenerado
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Vigencia
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Version
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdEstatusSincronizacion
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdEstatus
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_IdSesion
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF_tDIGarchivos_Extension
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT DF__tDIGarchi__EsArc__131E989A
GO
CREATE TABLE dbo.Tmp_tDIGarchivos
	(
	IdArchivo int NOT NULL IDENTITY (0, 1),
	IdArchivoPadre int NOT NULL,
	Nombre varchar(250) NOT NULL,
	Fecha date NOT NULL,
	IdListaD int NOT NULL,
	Longitud bigint NOT NULL,
	EsAutogenerado bit NOT NULL,
	Vigencia date NOT NULL,
	Version int NOT NULL,
	IdEstatusSincronizacion int NOT NULL,
	IdEstatus int NOT NULL,
	IdSesion int NOT NULL,
	Extension varchar(12) NOT NULL,
	EsArchivoPadre bit NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tDIGarchivos SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_IdArchivoPadre DEFAULT ((0)) FOR IdArchivoPadre
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Nombre DEFAULT ('') FOR Nombre
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Fecha DEFAULT ('19000101') FOR Fecha
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_IdListaD DEFAULT ((0)) FOR IdListaD
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Longitud DEFAULT ((0)) FOR Longitud
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_EsAutogenerado DEFAULT ((0)) FOR EsAutogenerado
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Vigencia DEFAULT ('19000101') FOR Vigencia
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Version DEFAULT ((0)) FOR Version
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_IdEstatusSincronizacion DEFAULT ((0)) FOR IdEstatusSincronizacion
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_IdEstatus DEFAULT ((0)) FOR IdEstatus
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_IdSesion DEFAULT ((0)) FOR IdSesion
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF_tDIGarchivos_Extension DEFAULT ('') FOR Extension
GO
ALTER TABLE dbo.Tmp_tDIGarchivos ADD CONSTRAINT
	DF__tDIGarchi__EsArc__131E989A DEFAULT ((0)) FOR EsArchivoPadre
GO
SET IDENTITY_INSERT dbo.Tmp_tDIGarchivos ON
GO
IF EXISTS(SELECT * FROM dbo.tDIGarchivos)
	 EXEC('INSERT INTO dbo.Tmp_tDIGarchivos (IdArchivo, IdArchivoPadre, Nombre, Fecha, IdListaD, Longitud, EsAutogenerado, Vigencia, Version, IdEstatusSincronizacion, IdEstatus, IdSesion, Extension, EsArchivoPadre)
		SELECT IdArchivo, IdArchivoPadre, Nombre, Fecha, IdListaD, Longitud, EsAutogenerado, Vigencia, Version, IdEstatusSincronizacion, IdEstatus, IdSesion, Extension, EsArchivoPadre FROM dbo.tDIGarchivos WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_tDIGarchivos OFF
GO
ALTER TABLE dbo.tDIGarchivos
	DROP CONSTRAINT FK_tDIGarchivos_tDIGarchivos
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tDIGarchivos
GO
DROP TABLE dbo.tDIGarchivos
GO
EXECUTE sp_rename N'dbo.Tmp_tDIGarchivos', N'tDIGarchivos', 'OBJECT' 
GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	PK_tDIGarchivos PRIMARY KEY CLUSTERED 
	(
	IdArchivo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	FK_tDIGarchivos_tCATlistasD FOREIGN KEY
	(
	IdListaD
	) REFERENCES dbo.tCATlistasD
	(
	IdListaD
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	FK_tDIGarchivos_tCTLestatus FOREIGN KEY
	(
	IdEstatus
	) REFERENCES dbo.tCTLestatus
	(
	IdEstatus
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	FK_tDIGarchivos_tCTLestatus1 FOREIGN KEY
	(
	IdEstatusSincronizacion
	) REFERENCES dbo.tCTLestatus
	(
	IdEstatus
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	FK_tDIGarchivos_tCTLsesiones FOREIGN KEY
	(
	IdSesion
	) REFERENCES dbo.tCTLsesiones
	(
	IdSesion
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGarchivos ADD CONSTRAINT
	FK_tDIGarchivos_tDIGarchivos FOREIGN KEY
	(
	IdArchivoPadre
	) REFERENCES dbo.tDIGarchivos
	(
	IdArchivo
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [dbo].[trArchivosBitacoraEstatus]
	   ON  dbo.tDIGarchivos
	   AFTER  INSERT, UPDATE
	AS 
	BEGIN
		INSERT INTO [dbo].[tCTLbitacoraEstatus] (IdTipoDDominio, IdDominio, IdEstatusActual, IdEstatus, IdSesion, FechaHora)
		SELECT 	0, IdArchivo,0, IdEstatus, IdSesion, CURRENT_TIMESTAMP
		FROM inserted
	END
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tDIGarchivos FOREIGN KEY
	(
	IdArchivo
	) REFERENCES dbo.tDIGarchivos
	(
	IdArchivo
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGregistrosDocumentos SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
