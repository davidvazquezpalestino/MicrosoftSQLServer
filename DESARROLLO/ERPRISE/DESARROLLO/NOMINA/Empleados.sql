

CREATE TABLE dbo.Tmp_tFELempleados(
IdEmpleado INT NOT NULL PRIMARY KEY(IdEmpleado),
IdRFC INT NULL,
IdRFCemisor INT NULL,
RegistroPatronal VARCHAR(20) NULL,
IdTipoDregimen INT NULL,
NumSeguridadSocial VARCHAR(30) NULL,
IdBancoSAT INT NULL,
CLABE VARCHAR(20) NULL,
FechaInicioRelLaboral date NULL,
IdPuesto INT NULL,
IdTipoDcontrato INT NULL,
IdTipoDjornada INT NULL,
IdTipoDperiodicidad INT NULL,
SalarioBaseCotApor NUMERIC(18, 2) NULL,
SalarioDiario NUMERIC(18, 2) NULL,
SalarioDiarioINTegrado NUMERIC(18, 2) NULL,
IdTipoDriesgoSAT INT NULL,
IdEstadoPrestaServicio INT NULL,
Sindicalizado BIT NULL
) 
GO
ALTER TABLE dbo.Tmp_tFELempleados SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT 1 FROM dbo.tFELempleados)
	 EXEC('INSERT INTO dbo.Tmp_tFELempleados (IdEmpleado, IdRFC, IdRFCemisor, RegistroPatronal, IdTipoDregimen, NumSeguridadSocial, IdBancoSAT, CLABE, FechaInicioRelLaboral, IdPuesto, IdTipoDcontrato, IdTipoDjornada, IdTipoDperiodicidad, SalarioBaseCotApor, SalarioDiario, IdTipoDriesgoSAT, IdEstadoPrestaServicio)
		SELECT IdEmpleado, IdRFC, IdRFCemisor, RegistroPatronal, IdTipoDregimen, NumSeguridadSocial, IdBancoSAT, CLABE, FechaInicioRelLaboral, IdPuesto, IdTipoDcontrato, IdTipoDjornada, IdTipoDperiodicidad, SalarioBaseCotApor, SalarioDiario, IdTipoDriesgoSAT, IdEstadoPrestaServicio FROM dbo.tFELempleados WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.tFELempleados
GO
EXECUTE sp_rename N'dbo.Tmp_tFELempleados', N'tFELempleados', 'OBJECT' 
GO
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLestados_IdEstadoPrestaServicio FOREIGN KEY(IdEstadoPrestaServicio) REFERENCES dbo.tCTLestados(IdEstado) 	
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tSATbancosSAT FOREIGN KEY(IdBancoSAT) REFERENCES dbo.tSATbancos(IdBanco)	
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tPERpuestos FOREIGN KEY(IdPuesto) REFERENCES dbo.tPERpuestos(IdPuesto)
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLtiposDregimen FOREIGN KEY(IdTipoDregimen) REFERENCES dbo.tCTLtiposD(IdTipoD) 
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLtiposDcontrato FOREIGN KEY(IdTipoDcontrato) REFERENCES dbo.tCTLtiposD(IdTipoD) 	
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLtiposDjornada FOREIGN KEY(IdTipoDjornada) REFERENCES dbo.tCTLtiposD(IdTipoD) 
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLtiposDperiodicidad FOREIGN KEY(IdTipoDperiodicidad) REFERENCES dbo.tCTLtiposD(IdTipoD) 
GO
ALTER TABLE dbo.tFELempleados ADD CONSTRAINT FK_tFELempleados_tCTLtiposDriesgoSAT FOREIGN KEY(IdTipoDriesgoSAT) REFERENCES dbo.tCTLtiposD(IdTipoD) 
GO


UPDATE Fel SET Fel.IdEmpleado = Per.IdEmpleado
FROM dbo.tPERempleados Per
INNER JOIN dbo.tFELempleados Fel ON Fel.IdRFC = per.IdPersonaFisica


