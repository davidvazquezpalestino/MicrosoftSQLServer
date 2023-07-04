DECLARE @IdPeriodo INT = 382;

--INSERT INTO dbo.tFELfacturaGlobalIngresos ( IdOperacion, IdPeriodo, IdTransaccionFinanciera, IdOperacionD, IdImpuesto, InteresOrdinario, IVAInteresOrdinario, InteresMoratorio, 
--											IVAInteresMoratorio, IdBienServicio, Importe, IVAVenta, Subtotal, IVA, IdCuenta, IdPersona )
SELECT Operacion.IdOperacion,
       Poliza.IdPeriodo,
       TransaccionFinanciera.IdTransaccion,
       OperacionD.IdOperacionD,
       PolizaD.IdImpuesto,
       InteresOrdinario = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                                    TransaccionFinanciera.InteresOrdinarioPagado + TransaccionFinanciera.InteresOrdinarioPagadoVencido
                               ELSE 0
                          END,
       IVAInteresOrdinario = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                       TransaccionFinanciera.IVAInteresOrdinarioPagado
                                  ELSE 0
                             END,
       InteresMoratorio = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                    TransaccionFinanciera.InteresMoratorioPagado + TransaccionFinanciera.InteresMoratorioPagadoVencido
                               ELSE 0
                          END,
       IVAInteresMoratorio = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                       TransaccionFinanciera.IVAInteresMoratorioPagado
                                  ELSE 0
                             END,
       IdBienServicio = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                                  -2019
                             WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                  -2020
                             ELSE BienServicio.IdBienServicio
                        END,
       --Importe =PolizaD.Abono - PolizaD.Cargo,
       Importe = CASE OperacionD.IdOperacionD WHEN 0 THEN
                                                   0
                                              ELSE OperacionD.ImporteSinDescuento
                 END,
       IVAVenta = CASE OperacionD.IdOperacionD WHEN 0 THEN
                                                    0
                                               ELSE OperacionD.IVA
                  END,
       Subtotal = CASE OperacionD.IdOperacionD WHEN 0 THEN
                                                    0
                                               ELSE OperacionD.Subtotal
                  END,
       IVA = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                       TransaccionFinanciera.IVAInteresMoratorioPagado
                  WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                       TransaccionFinanciera.IVAInteresOrdinarioPagado
                  ELSE OperacionD.IVA
             END,
       IdCuenta = Cuenta.IdCuenta,
       Cuenta.IdSocio,
       Poliza.IdPolizaE
FROM dbo.tCNTpolizasE Poliza WITH ( NOLOCK )
INNER JOIN dbo.tCATlistasD TipoPoliza WITH ( NOLOCK ) ON TipoPoliza.IdListaD = Poliza.IdListaDpoliza
INNER JOIN dbo.tCTLperiodos Periodo WITH ( NOLOCK ) ON Periodo.IdPeriodo = Poliza.IdPeriodo
INNER JOIN dbo.tCNTpolizasD PolizaD WITH ( NOLOCK ) ON Poliza.IdPolizaE = PolizaD.IdPolizaE
INNER JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = PolizaD.IdOperacion
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
INNER JOIN dbo.tCNTcuentas CuentaContable WITH ( NOLOCK ) ON CuentaContable.IdCuentaContable = PolizaD.IdCuentaContable
INNER JOIN dbo.tAYCcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuenta = PolizaD.IdCuenta
INNER JOIN dbo.tCTLtiposD TipoAIC WITH ( NOLOCK ) ON TipoAIC.IdTipoD = Cuenta.IdTipoDAIC
INNER JOIN dbo.tGRLpersonas Persona WITH ( NOLOCK ) ON Persona.IdPersona = PolizaD.IdPersona
INNER JOIN dbo.tCNTdivisiones Division WITH ( NOLOCK ) ON Division.IdDivision = PolizaD.IdDivision
INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH ( NOLOCK ) ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH ( NOLOCK ) ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
INNER JOIN dbo.tCTLsucursales Sucursal WITH ( NOLOCK ) ON Sucursal.IdSucursal = PolizaD.IdSucursal
INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH ( NOLOCK ) ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH ( NOLOCK ) ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH ( NOLOCK ) ON BienServicio.IdBienServicio = PolizaD.IdBienServicio
WHERE Poliza.IdPeriodo = @IdPeriodo AND Poliza.IdEstatus = 1 AND (( AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') AND AsientoD.IdTipoDDominio = 143 ) OR ( AsientoD.IdTipoDRubro = 2726 OR AsientoD.Campo IN ('Subtotal') AND AsientoD.IdTipoOperacion = 17 )) AND ( TransaccionFinanciera.IdTransaccion <> 0 OR OperacionD.IdOperacionD <> 0 ) AND OperacionD.IdOperacionD <> 0;
