
DECLARE @IdComprobante INT = (SELECT TOP 1 IdComprobante FROM dbo.tIMPcomprobantesFiscales WHERE Folio = 2681);

SELECT *
FROM dbo.tFELsubsidioAlEmpleo Subsidio
WHERE EXISTS (SELECT Complemento.IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              INNER JOIN dbo.tFELotrosPagos Pago ON Pago.IdComplementoNomina = Complemento.IdComplementoNomina
              WHERE Pago.IdOtroPago = Subsidio.IdOtroPago AND Complemento.IdComprobante = @IdComprobante);

SELECT *
FROM dbo.tFELotrosPagos Pago
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Pago.IdComplementoNomina AND IdComprobante = @IdComprobante);

SELECT *
FROM dbo.tFELpercepciones Percepcion
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Percepcion.IdComplementoNomina AND IdComprobante = @IdComprobante);

SELECT *
FROM dbo.tFELdeducciones Deduccion
WHERE EXISTS (SELECT IdComprobante
              FROM dbo.tFELcomplementosNomina Complemento
              WHERE Complemento.IdComplementoNomina = Deduccion.IdComplementoNomina AND IdComprobante = @IdComprobante);

SELECT *
FROM dbo.tFELcomplementosNomina
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tIMPcomprobantesFiscalesD
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tNOMnominasPercepcionesDeducciones
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tCTLhistoricoTimbresCFDi
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tCTLbitacoraCfdi
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tIMPcomprobantesFiscales
WHERE IdComprobante = @IdComprobante;

SELECT *
FROM dbo.tNOMnominas Nomina
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdNomina = Nomina.IdNomina
WHERE Complemento.IdComprobante = @IdComprobante;

