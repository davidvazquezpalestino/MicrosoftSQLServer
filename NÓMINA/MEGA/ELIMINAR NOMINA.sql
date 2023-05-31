
-- BEGIN TRANSACTION 
-- COMMIT TRANSACTION 
DECLARE @IdComprobante INT = (SELECT TOP 1 IdComprobante FROM dbo.tIMPcomprobantesFiscales WHERE Folio = 3579);

DELETE Subsidio
FROM dbo.tFELsubsidioAlEmpleo Subsidio
WHERE EXISTS (SELECT Complemento.IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              INNER JOIN dbo.tFELotrosPagos Pago ON Pago.IdComplementoNomina = Complemento.IdComplementoNomina
              WHERE Pago.IdOtroPago = Subsidio.IdOtroPago AND Complemento.IdComprobante = @IdComprobante);

DELETE Pago
FROM dbo.tFELotrosPagos Pago
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Pago.IdComplementoNomina AND IdComprobante = @IdComprobante);

DELETE Percepcion
FROM dbo.tFELpercepciones Percepcion
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Percepcion.IdComplementoNomina AND IdComprobante = @IdComprobante);

DELETE Deduccion
FROM dbo.tFELdeducciones Deduccion
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Deduccion.IdComplementoNomina AND IdComprobante = @IdComprobante);


DELETE
FROM dbo.tIMPcomprobantesFiscalesD
WHERE IdComprobante = @IdComprobante;

DELETE
FROM dbo.tNOMnominasPercepcionesDeducciones
WHERE IdComprobante = @IdComprobante;

DELETE
FROM dbo.tCTLhistoricoTimbresCFDi
WHERE IdComprobante = @IdComprobante;

DELETE
FROM dbo.tCTLbitacoraCfdi
WHERE IdComprobante = @IdComprobante;



DELETE Nomina
FROM dbo.tNOMnominas Nomina
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdNomina = Nomina.IdNomina
WHERE Complemento.IdComprobante = @IdComprobante;

DELETE
FROM dbo.tFELcomplementosNomina
WHERE IdComprobante = @IdComprobante;

DELETE
FROM dbo.tIMPcomprobantesFiscales
WHERE IdComprobante = @IdComprobante;

