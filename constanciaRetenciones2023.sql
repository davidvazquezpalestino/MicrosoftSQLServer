
INSERT INTO dbo.tFELcomplementoConstanciaRetencionesIntereses (IdConstanciaRetencion, Version, SistemaFinanciero, Retiro, OperacionesDerivadas, MontoNominal, MontoReal, Perdida )

SELECT cr.IdConstanciaRetencion, Version ='1.0', SistemaFinanciero = 'SI', Retiro = 'NO', OperacionesDerivadas ='NO'
FROM dbo.tFELconstanciaRetenciones cr
INNER JOIN ##Retenciones tr ON cr.ReceptorRfc = tr.ReceptorRfc COLLATE DATABASE_DEFAULT
WHERE cr.IdEjercicio = 30

