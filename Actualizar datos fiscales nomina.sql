



UPDATE Comprobante SET Comprobante.ReceptorCodigoPostal = Domicilio.CodigoPostal
FROM dbo.tIMPcomprobantesFiscales Comprobante
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = Comprobante.IdPersona
INNER JOIN dbo.tCATdomicilios Domicilio ON Persona.IdRelDomicilios = Domicilio.IdRel
LEFT JOIN dbo.tCTLhistoricoTimbresCFDi Historico ON Historico.IdComprobante = Comprobante.IdComprobante
WHERE IdNomina = 413
      AND Historico.IdComprobante IS NULL
      AND Domicilio.IdEstatus = 1
      AND Comprobante.ReceptorCodigoPostal <> Domicilio.CodigoPostal;


