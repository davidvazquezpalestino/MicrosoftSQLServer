SELECT dbo.fGETidPeriodo (CURRENT_TIMESTAMP) - 1;

DECLARE @IdPeriodo INT = 418;

INSERT INTO dbo.tFELfacturaGlobalIngresos ( IdOperacion, IdPeriodo, IdTransaccionFinanciera, IdOperacionD, IdImpuesto, InteresOrdinario, IVAInteresOrdinario, InteresMoratorio, IVAInteresMoratorio, IdBienServicio, Importe, IVAVenta, Subtotal, IVA )
SELECT Operacion.IdOperacion,
       Periodo.IdPeriodo,
       PolizaD.IdTransaccionFinanciera,
       OperacionD.IdOperacionD,
       IdImpuesto = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                              ImpuestoTransaccionFinanciera.IdImpuesto
                        ELSE  ImpuestoOperacionD.IdImpuesto
                    END,
       InteresOrdinario = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagado') THEN
                                    ISNULL (TransaccionFinanciera.InteresOrdinarioPagado, 0) + ISNULL (TransaccionFinanciera.InteresOrdinarioPagadoVencido, 0)
                              ELSE  0
                          END,
       IVAInteresOrdinario = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                                       TransaccionFinanciera.IVAInteresOrdinarioPagado
                                 ELSE  0
                             END,
       InteresMoratorio = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                    ISNULL (TransaccionFinanciera.InteresMoratorioPagado, 0) + ISNULL (TransaccionFinanciera.InteresMoratorioPagadoVencido, 0)
                              ELSE  0
                          END,
       IVAInteresMoratorio = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                       TransaccionFinanciera.IVAInteresMoratorioPagado
                                 ELSE  0
                             END,
       IdBienServicio = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                  -2020
                            WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                                 -2019
                            ELSE BienServicio.IdBienServicio
                        END,
       Importe = OperacionD.Subtotal,
       IVAVenta = OperacionD.IVA,
       Subtotal = PolizaD.Abono - PolizaD.Cargo,
       IVA = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                       TransaccionFinanciera.IVAInteresMoratorioPagado
                 WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                      TransaccionFinanciera.IVAInteresOrdinarioPagado
                 ELSE OperacionD.IVA
             END 

FROM dbo.tCNTpolizasE Poliza WITH ( NOLOCK )
INNER JOIN dbo.tCTLperiodos Periodo WITH ( NOLOCK ) ON Periodo.IdPeriodo = Poliza.IdPeriodo
INNER JOIN dbo.tCNTpolizasD PolizaD WITH ( NOLOCK ) ON Poliza.IdPolizaE = PolizaD.IdPolizaE
INNER JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = PolizaD.IdOperacion
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
INNER JOIN dbo.tAYCcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuenta = PolizaD.IdCuenta
INNER JOIN dbo.tGRLpersonas Persona WITH ( NOLOCK ) ON Persona.IdPersona = PolizaD.IdPersona
INNER JOIN dbo.tCNTdivisiones Division WITH ( NOLOCK ) ON Division.IdDivision = PolizaD.IdDivision
INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH ( NOLOCK ) ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH ( NOLOCK ) ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
INNER JOIN dbo.tCTLsucursales Sucursal WITH ( NOLOCK ) ON Sucursal.IdSucursal = PolizaD.IdSucursal
INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH ( NOLOCK ) ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH ( NOLOCK ) ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH ( NOLOCK ) ON BienServicio.IdBienServicio = PolizaD.IdBienServicio
WHERE Poliza.IdPeriodo = @IdPeriodo
AND   Poliza.IdEstatus = 1
AND   ( ( AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido')
      AND AsientoD.IdTipoDDominio = 143 )
     OR ( AsientoD.IdTipoDRubro = 2726
       OR AsientoD.Campo IN ('Subtotal')
      AND AsientoD.IdTipoOperacion = 17 ))
AND   AsientoD.IdTipoDRubro NOT IN (1870, 1871)
AND   NOT EXISTS ( SELECT 1
                   FROM dbo.tFELfacturaGlobalIngresos g
                   WHERE TransaccionFinanciera.IdTransaccion = g.IdTransaccionFinanciera
                   AND   OperacionD.IdOperacionD = g.IdOperacionD )
AND   NOT EXISTS ( SELECT 1 -- EXCLUIMOS LAS CUENTAS QUE YA SE TIMBRARON EN EL PERIODO
                   FROM dbo.tFELestadoCuentaBancario EstadoCuenta
                   WHERE Cuenta.IdCuenta = EstadoCuenta.IdCuenta
                   AND   EstadoCuenta.IdPeriodo = @IdPeriodo );

DECLARE @IdComprobante INT;

EXECUTE dbo.pFELgenerarFacturaGlobal @IdPeriodo = 418, -- int
                                     @IdSucursal = 1, -- int
                                     @FechaTrabajo = '2025-02-28', -- date
                                     @IdComprobante = @IdComprobante OUTPUT; -- int

SELECT @IdComprobante;


