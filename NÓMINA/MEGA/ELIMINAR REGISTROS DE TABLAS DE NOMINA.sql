USE IERP_KFT_NOMINA
GO

DELETE FROM dbo.tFELsubsidioAlEmpleo WHERE IdSubsidioAlEmpleo > 0;
DBCC CHECKIDENT(tFELsubsidioAlEmpleo, RESEED, 0)

DELETE FROM dbo.tFELotrosPagos WHERE IdOtroPago > 0
DBCC CHECKIDENT(tFELotrosPagos, RESEED, 0)

DELETE FROM dbo.tFELpercepciones WHERE IdPercepcion > 0
DBCC CHECKIDENT(tFELpercepciones, RESEED, 0)

DELETE FROM dbo.tFELdeducciones WHERE IdDeduccion > 0
DBCC CHECKIDENT(tFELdeducciones, RESEED, 0)

DELETE FROM dbo.tFELcomplementosNomina WHERE IdComplementoNomina > 0
DBCC CHECKIDENT(tFELcomplementosNomina, RESEED, 0)

DELETE FROM dbo.tIMPcomprobantesFiscalesD WHERE IdComprobanteD > 0
DBCC CHECKIDENT(tIMPcomprobantesFiscalesD, RESEED, 0)

DELETE FROM dbo.tNOMnominasPercepcionesDeducciones WHERE IdNominaPercepcionDeduccion > 0
DBCC CHECKIDENT(tNOMnominasPercepcionesDeducciones, RESEED, 0)

DELETE FROM dbo.tCTLhistoricoTimbresCFDi WHERE IdHistoricoTimbradoCDFi > 0
DBCC CHECKIDENT(tCTLhistoricoTimbresCFDi, RESEED, 0)

DELETE FROM dbo.tCTLhistoricoCancelacionesCFDi WHERE IdHistoricoTimbradoCDFi > 0
DBCC CHECKIDENT(tCTLhistoricoCancelacionesCFDi, RESEED, 0)

DELETE FROM dbo.tCTLbitacoraCfdi WHERE Id > 0
DBCC CHECKIDENT(tCTLbitacoraCfdi, RESEED, 0)

DELETE FROM dbo.tIMPcomprobantesFiscales WHERE IdComprobante > 0
DBCC CHECKIDENT(tIMPcomprobantesFiscales, RESEED, 0)

DELETE FROM dbo.tNOMnominasEmpleados WHERE IdNominaEmpleado > 0
DBCC CHECKIDENT(tNOMnominasEmpleados, RESEED, 0)

DELETE FROM dbo.tNOMnominas WHERE IdNomina > 0
DBCC CHECKIDENT(tNOMnominas, RESEED, 0)



--UPDATE dbo.tNOMcalculosE SET IdEstatus = 13 WHERE IdEstatus = 7

DISABLE TRIGGER dbo.trValidarDelete_tNOMcalculosEmpleados ON dbo.tNOMcalculosEmpleados;
DISABLE TRIGGER dbo.trValidarDelete_tNOMcalculos ON dbo.tNOMcalculos;

DELETE FROM dbo.tNOMcalculosEmpleados WHERE IdCalculoEmpleado > 0
DELETE FROM dbo.tNOMcalculos WHERE IdCalculoD > 0
DELETE FROM dbo.tNOMcalculosE WHERE IdCalculoE > 0 


