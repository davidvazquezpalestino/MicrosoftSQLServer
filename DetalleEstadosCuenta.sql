SELECT Operacion.IdOperacion,
       Operacion.IdPeriodo,
       Cuenta.IdCuenta,
       Cuenta.IdSocio,
       Impuesto = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN ImpuestoTransaccionFinanciera.IdImpuesto
                       ELSE ImpuestoOperacionD.IdImpuesto
                  END,
       TransaccionFinanciera.IdTransaccion,
       BienServicio.IdBienServicio,
       OperacionD.IdOperacionD,
       Subtotal = PolizaD.Abono - PolizaD.Cargo,
       IVA = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN TransaccionFinanciera.IVAInteresMoratorioPagado
                  WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN TransaccionFinanciera.IVAInteresOrdinarioPagado
                  ELSE OperacionD.IVA
             END
FROM dbo.tCNTpolizasE Poliza WITH (NOLOCK)
INNER JOIN dbo.tCTLperiodos Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = Poliza.IdPeriodo
INNER JOIN dbo.tCNTpolizasD PolizaD WITH (NOLOCK) ON Poliza.IdPolizaE = PolizaD.IdPolizaE
INNER JOIN dbo.tCNTasientosD AsientoD WITH (NOLOCK) ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
INNER JOIN dbo.tGRLoperaciones Operacion WITH (NOLOCK) ON Operacion.IdOperacion = PolizaD.IdOperacion
--INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH (NOLOCK) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
INNER JOIN dbo.tAYCcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuenta = PolizaD.IdCuenta
INNER JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersona = PolizaD.IdPersona
--INNER JOIN dbo.tCNTdivisiones Division WITH (NOLOCK) ON Division.IdDivision = PolizaD.IdDivision
INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH (NOLOCK) ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH (NOLOCK) ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
--INNER JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = PolizaD.IdSucursal
INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH (NOLOCK) ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH (NOLOCK) ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN -2019
                                                                                                    WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN -2020
                                                                                                    ELSE PolizaD.IdBienServicio
                                                                                               END
WHERE Poliza.IdPeriodo = 365 AND
    Poliza.IdEstatus = 1 AND
                         ((AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') AND
                              AsientoD.IdTipoDDominio = 143) OR
                                                             (AsientoD.IdTipoDRubro = 2726 OR
                                                                 AsientoD.Campo IN ('Subtotal') AND
                                                                 AsientoD.IdTipoOperacion = 17)) AND
    AsientoD.IdTipoDRubro NOT IN (1868, 1869, 1870, 1871) AND
    Operacion.IdPersona = 150572;