DECLARE @IdPeriodo INT;

SELECT @IdPeriodo = IdPeriodo
FROM dbo.tCTLperiodos WITH (NOLOCK)
WHERE Codigo = '2021-07';

SELECT Periodo.Codigo AS Período,
    TipoPoliza.Codigo AS [Tipo de Póliza],
    Poliza.Folio AS [Folio Póliza],
    Poliza.Fecha,
    TipoOperacion = TipoOperacion.Descripcion,
    Folio = CONCAT (Operacion.Serie, Operacion.Folio),
    TipoAIC.Descripcion AS Clasificación,
    CuentaContable.Codigo AS [Cuenta Contable],
    CuentaContable.Descripcion AS [Descripción],
    PolizaD.Concepto,
    PolizaD.Referencia,
    [Tipo Ingreso] = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN 'INTERÉS MORATORIO'
                          WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN 'INTERÉS ORDINARIO'
                          ELSE BienServicio.Descripcion
                     END,
    PolizaD.Abono - PolizaD.Cargo AS Importe,
    Tasa = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN ImpuestoTransaccionFinanciera.TasaIVA
                ELSE ImpuestoOperacionD.TasaIVA
           END,
    IVA = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN TransaccionFinanciera.IVAInteresMoratorioPagado
               WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN TransaccionFinanciera.IVAInteresOrdinarioPagado
               ELSE OperacionD.IVA
          END,
    DiferenciaCreditos = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN TransaccionFinanciera.IVAInteresMoratorioPagado
                              WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN TransaccionFinanciera.IVAInteresOrdinarioPagado
                              ELSE 0
                         END - (PolizaD.Abono - PolizaD.Cargo) * ImpuestoTransaccionFinanciera.TasaIVA,
    DiferenciaServicios = OperacionD.IVA - (PolizaD.Abono - PolizaD.Cargo) * ImpuestoOperacionD.TasaIVA,
    Persona.Nombre AS [Socio/cliente],
    Persona.RFC,
    División = Division.Descripcion,
    Sucursal = Sucursal.Descripcion,
    Crédito = CONCAT (Cuenta.Descripcion, ' ', Cuenta.Codigo)
FROM dbo.tCNTpolizasE Poliza WITH (NOLOCK)
INNER JOIN dbo.tCATlistasD TipoPoliza WITH (NOLOCK) ON TipoPoliza.IdListaD = Poliza.IdListaDpoliza
INNER JOIN dbo.tCTLperiodos Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = Poliza.IdPeriodo
INNER JOIN dbo.tCNTpolizasD PolizaD WITH (NOLOCK) ON Poliza.IdPolizaE = PolizaD.IdPolizaE
INNER JOIN dbo.tCNTasientosD AsientoD WITH (NOLOCK) ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
INNER JOIN dbo.tGRLoperaciones Operacion WITH (NOLOCK) ON Operacion.IdOperacion = PolizaD.IdOperacion
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH (NOLOCK) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
INNER JOIN dbo.tCNTcuentas CuentaContable WITH (NOLOCK) ON CuentaContable.IdCuentaContable = PolizaD.IdCuentaContable
INNER JOIN dbo.tAYCcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuenta = PolizaD.IdCuenta
INNER JOIN dbo.tCTLtiposD TipoAIC WITH (NOLOCK) ON TipoAIC.IdTipoD = Cuenta.IdTipoDAIC
INNER JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersona = PolizaD.IdPersona
INNER JOIN dbo.tCNTdivisiones Division WITH (NOLOCK) ON Division.IdDivision = PolizaD.IdDivision
INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH (NOLOCK) ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH (NOLOCK) ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
INNER JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = PolizaD.IdSucursal
INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH (NOLOCK) ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH (NOLOCK) ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = PolizaD.IdBienServicio
WHERE Poliza.IdPeriodo = @IdPeriodo AND Poliza.IdEstatus = 1 AND ((AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') AND AsientoD.IdTipoDDominio = 143) OR (AsientoD.IdTipoDRubro = 2726 OR AsientoD.Campo IN ('Subtotal') AND AsientoD.IdTipoOperacion = 17)) AND AsientoD.IdTipoDRubro NOT IN (1868, 1869, 1870, 1871);
