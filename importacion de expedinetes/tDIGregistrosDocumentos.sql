/*
   jueves, 16 de julio de 201506:09:53 p. m.
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
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tDIGrequisitos_IdRequisito
GO
ALTER TABLE dbo.tDIGrequisitos SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tDIGdominioTiposDocumentos
GO
ALTER TABLE dbo.tDIGdominioTiposDocumentos SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tDIGarchivos
GO
ALTER TABLE dbo.tDIGarchivos SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tCTLtiposD_IdTipoDDominio
GO
ALTER TABLE dbo.tCTLtiposD SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tCTLsesiones
GO
ALTER TABLE dbo.tCTLsesiones SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosDocumentos_tCTLestatus_IdEstatus
GO
ALTER TABLE dbo.tCTLestatus SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdRegistroArchivo
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdRegistro
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdArchivo
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdTipoDdominio
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdRegistroPadre
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_IdDominioTipoArchivo
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosArchivos_Resumen
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_Recibido
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdEstatus
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdUsuarioAlta
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdRequisitoE
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdSesion
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_Codigo
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_Descripcion
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdPersona
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdOperacion
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_IdTipoOperacion
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_FolioOperacion
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT DF_tDIGregistrosDocumentos_FechaOperacion
GO
CREATE TABLE dbo.Tmp_tDIGregistrosDocumentos
	(
	IdRegistroDocumento int NOT NULL IDENTITY (0, 1),
	IdRegistro int NOT NULL,
	IdArchivo int NOT NULL,
	IdTipoDdominio int NOT NULL,
	IdRegistroDocumentoPadre int NOT NULL,
	IdDominioTipoDocumento int NOT NULL,
	Resumen varchar(150) NOT NULL,
	Recibido bit NOT NULL,
	IdEstatus int NOT NULL,
	IdUsuarioAlta int NOT NULL,
	IdRequisito int NULL,
	IdSesion int NOT NULL,
	Codigo varchar(80) NOT NULL,
	Descripcion varchar(256) NOT NULL,
	IdPersona int NOT NULL,
	IdOperacion int NOT NULL,
	IdTipoOperacion int NOT NULL,
	FolioOperacion int NOT NULL,
	FechaOperacion date NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_IdRegistro DEFAULT ((0)) FOR IdRegistro
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_IdArchivo DEFAULT ((0)) FOR IdArchivo
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_IdTipoDdominio DEFAULT ((0)) FOR IdTipoDdominio
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_IdRegistroPadre DEFAULT ((0)) FOR IdRegistroDocumentoPadre
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_IdDominioTipoArchivo DEFAULT ((0)) FOR IdDominioTipoDocumento
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosArchivos_Resumen DEFAULT ('') FOR Resumen
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_Recibido DEFAULT ((0)) FOR Recibido
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdEstatus DEFAULT ((0)) FOR IdEstatus
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdUsuarioAlta DEFAULT ((0)) FOR IdUsuarioAlta
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdRequisitoE DEFAULT ((0)) FOR IdRequisito
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdSesion DEFAULT ((0)) FOR IdSesion
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_Codigo DEFAULT ('') FOR Codigo
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_Descripcion DEFAULT ('') FOR Descripcion
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdPersona DEFAULT ('0') FOR IdPersona
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdOperacion DEFAULT ('0') FOR IdOperacion
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_IdTipoOperacion DEFAULT ('0') FOR IdTipoOperacion
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_FolioOperacion DEFAULT ('0') FOR FolioOperacion
GO
ALTER TABLE dbo.Tmp_tDIGregistrosDocumentos ADD CONSTRAINT
	DF_tDIGregistrosDocumentos_FechaOperacion DEFAULT ('19000101') FOR FechaOperacion
GO
SET IDENTITY_INSERT dbo.Tmp_tDIGregistrosDocumentos ON
GO
IF EXISTS(SELECT * FROM dbo.tDIGregistrosDocumentos)
	 EXEC('INSERT INTO dbo.Tmp_tDIGregistrosDocumentos (IdRegistroDocumento, IdRegistro, IdArchivo, IdTipoDdominio, IdRegistroDocumentoPadre, IdDominioTipoDocumento, Resumen, Recibido, IdEstatus, IdUsuarioAlta, IdRequisito, IdSesion, Codigo, Descripcion, IdPersona, IdOperacion, IdTipoOperacion, FolioOperacion, FechaOperacion)
		SELECT IdRegistroDocumento, IdRegistro, IdArchivo, IdTipoDdominio, IdRegistroDocumentoPadre, IdDominioTipoDocumento, Resumen, Recibido, IdEstatus, IdUsuarioAlta, IdRequisito, IdSesion, Codigo, Descripcion, IdPersona, IdOperacion, IdTipoOperacion, FolioOperacion, FechaOperacion FROM dbo.tDIGregistrosDocumentos WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_tDIGregistrosDocumentos OFF
GO
ALTER TABLE dbo.tDIGregistrosDocumentos
	DROP CONSTRAINT FK_tDIGregistrosArchivos_tDIGregistrosArchivos
GO
DROP TABLE dbo.tDIGregistrosDocumentos
GO
EXECUTE sp_rename N'dbo.Tmp_tDIGregistrosDocumentos', N'tDIGregistrosDocumentos', 'OBJECT' 
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	PK_tDIGregistrosArchivos PRIMARY KEY CLUSTERED 
	(
	IdRegistroDocumento
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosArchivos_tDIGregistrosArchivos FOREIGN KEY
	(
	IdRegistroDocumentoPadre
	) REFERENCES dbo.tDIGregistrosDocumentos
	(
	IdRegistroDocumento
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tCTLestatus_IdEstatus FOREIGN KEY
	(
	IdEstatus
	) REFERENCES dbo.tCTLestatus
	(
	IdEstatus
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tCTLsesiones FOREIGN KEY
	(
	IdSesion
	) REFERENCES dbo.tCTLsesiones
	(
	IdSesion
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tCTLtiposD_IdTipoDDominio FOREIGN KEY
	(
	IdTipoDdominio
	) REFERENCES dbo.tCTLtiposD
	(
	IdTipoD
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
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
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tDIGdominioTiposDocumentos FOREIGN KEY
	(
	IdDominioTipoDocumento
	) REFERENCES dbo.tDIGdominioTiposDocumentos
	(
	IdDominioTipoDocumento
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tDIGregistrosDocumentos ADD CONSTRAINT
	FK_tDIGregistrosDocumentos_tDIGrequisitos_IdRequisito FOREIGN KEY
	(
	IdRequisito
	) REFERENCES dbo.tDIGrequisitos
	(
	IdRequisito
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [dbo].[trRegistroDocumentos]
   ON  dbo.tDIGregistrosDocumentos 
   AFTER  INSERT,UPDATE
AS 
BEGIN	
	   SET NOCOUNT ON;
		    INSERT INTO [dbo].[tCTLbitacoraEstatus] (IdTipoDDominio, IdDominio, IdEstatusActual, IdEstatus, IdSesion, FechaHora)
			SELECT IdTipoDDominio, IdRegistroDocumento ,0 ,IdEstatus, IdSesion, CURRENT_TIMESTAMP
			FROM inserted
END
GO
COMMIT
