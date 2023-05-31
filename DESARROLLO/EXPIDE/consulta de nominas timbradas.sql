SELECT   complemento.IdComprobante,
[Serie Folio] = CONCAT(comprobante.Serie, '-',comprobante.Folio) ,
         complemento.NumEmpleado ,
         comprobante.NombreReceptor ,
         complemento.SalarioDiario ,
         complemento.SalarioBaseCotApor ,
         complemento.SalarioDiarioIntegrado ,
         comprobante.MetodoPago ,
         complemento.FechaInicialPago ,
         complemento.FechaFinalPago ,
         complemento.FechaPago ,
         complemento.NumDiasPagados ,
         complemento.TotalPercepciones ,
         complemento.TotalOtroPago ,
         complemento.TotalDeducciones,
		 comprobante.Total, 
		 historico.UUID,
		 Estatus = estatus.Descripcion
FROM     dbo.tFELcomprobantes comprobante
INNER JOIN dbo.tFELcomplementosNomina complemento ON complemento.IdComprobante = comprobante.IdComprobante
INNER JOIN dbo.tCTLhistoricoTimbresCFDi historico ON historico.IdComprobante = comprobante.IdComprobante
INNER JOIN dbo.tCTLestatus estatus ON estatus.IdEstatus = comprobante.IdEstatus
WHERE NOT comprobante.IdEstatus IN(3,4,5,7) AND comprobante.IdRFCemisor = 41330 AND comprobante.Total = 0
ORDER BY complemento.FechaPago, comprobante.NombreReceptor;

