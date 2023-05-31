SELECT CONCAT ('EXECUTE dbo.pDependencias @Tabla = ''tFELotrosPagos'', @Valor = ''', Pago.IdOtroPago, ''';
EXECUTE dbo.pDependencias @Tabla = ''tFELcomplementosNomina'', @Valor = ''', Complemento.IdComplementoNomina, ''';
EXECUTE dbo.pDependencias @Tabla = ''tFELcomprobantes'', @Valor = ''', Comprobante.IdComprobante, ''';')
FROM dbo.tFELcomprobantes Comprobante
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdComprobante = Comprobante.IdComprobante
INNER JOIN dbo.tFELotrosPagos Pago ON Pago.IdComplementoNomina = Complemento.IdComplementoNomina
WHERE IdRFCemisor = 3654;