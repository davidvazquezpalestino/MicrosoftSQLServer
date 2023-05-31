DELETE FROM ##AplicacionCreditos
WHERE cuenta IS NULL;

BEGIN TRAN APLICACION;

-- 	ROLLBACK TRAN APLICACION
--
--	COMMIT TRAN APLICACION;
DECLARE @fecha DATE = '20220413';
DECLARE @idperiodo INT = dbo.fGETidPeriodo (@fecha);
DECLARE @idOperacion INT = 0;
DECLARE @IdSucursal AS INT;

SELECT @IdSucursal = IdSucursal
FROM dbo.tCTLsucursales
WHERE EsMatriz = 1;

EXEC dbo.pACToperaciones @TipoOperacion = 'INSERT',
    @idOperacion = @idOperacion OUTPUT, -- int
    @IdTipoOperacion = 43, -- PAGOS REFERENCIADOS
    @IdSucursal = @IdSucursal,
    @idPeriodo = @idperiodo, -- int
    @IdSesion = 0, -- int
    @Fecha = @fecha OUTPUT,
    --Le mandamos la fecha de trabajo como fecha de la operación
    @fechaTrabajo = @fecha,
    @Concepto = 'APLICACIÓN DE PAGOS',
    @Validar = 0; -- date

PRINT @idOperacion;

DECLARE @cadena VARCHAR(MAX) = '',
    @cadenaApl  VARCHAR(MAX) = '';

SELECT @cadena = @cadena + CONCAT (' EXEC dbo.pAYCaplicacionPagoCredito @IdCuenta = ', c.IdCuenta, ', @IdSocio = ', c.IdSocio, ',
									    @FechaTrabajo = ''', @fecha, ''', @Decimales = 2,
									    @CodigoOperacion = ''DEVPAG'', @MontoAplicacion = ', ROUND (t.Monto, 2), ', @GenerarMovimiento = 1, @GenerarOperacion = 0,
									    @IdOperacion = ', @idOperacion, ', 
										@IdTipoOperacion = 500, @Concepto = ''APLICACIÓN DE PAGO DE CRÉDITO'', @Referencia =''', referencia, ''', @IdSesion = 0;')
FROM ##AplicacionCreditos t
JOIN dbo.tAYCcuentas c ON c.Codigo = CONCAT (t.Cuenta COLLATE DATABASE_DEFAULT, '')
WHERE ISNULL (t.Cuenta, '') <> '';

SELECT @cadena;

SELECT @cadenaApl = @cadenaApl + CONCAT ('	EXEC dbo.pSDOafectaSaldoTransaccionesFinancierasOperacion @TipoOperacion = '''', @IdOperacion = ', idoperacionPadre, ', @Factor = 1;', '	EXEC dbo.pAYCactualizarSaldoParcialidades @IdOperacion = ', idoperacionPadre, ';', '	EXEC dbo.pAYCactualizarPrimerVencimientoPendiente @IdOperacion = ', idoperacionPadre, ';')
FROM (VALUES (@idOperacion)) AS tmp (idoperacionPadre);

PRINT CURRENT_TIMESTAMP;
PRINT 'GENERAMOS LAS TRANSACCIONES';

DECLARE @excepciones TABLE
(
    tipo VARCHAR(200),
    msg VARCHAR(MAX)
);

/*CREAMOS LAS TRANSACCIONES FINANCIERAS*/
BEGIN TRY -- @cadena
    PRINT @cadena;

    EXEC (@cadena);

    BEGIN TRY -- @cadenaApl
        PRINT 'afectamos el saldo';
        PRINT @cadenaApl;

        EXEC (@cadenaApl);

        BEGIN TRY
            PRINT 'VALIDAMOS LOS PAGOS DE CRÉDITOS';

            EXEC dbo.pCTLvalidarAplicacionPlanPagosSaldo @TipoOperacion = 'PROVCART', -- varchar(20)
                @IdCuenta = 0, -- int
                @IdOperacion = @idOperacion; -- int
        END TRY
        BEGIN CATCH
            INSERT INTO @excepciones (tipo, msg)
            VALUES ('VALIDAMOS LA OPERACION ', ERROR_MESSAGE ());
        END CATCH;
    END TRY
    BEGIN CATCH
        INSERT INTO @excepciones (tipo, msg)
        VALUES ('AFECTA-SALDO', ERROR_MESSAGE ());
    END CATCH;
END TRY
BEGIN CATCH
    INSERT INTO @excepciones (tipo, msg)
    VALUES ('GENERAR-TRANSACCIONES', ERROR_MESSAGE ());
END CATCH;

UPDATE x
SET x.IdEstatus = 1
FROM dbo.tGRLoperaciones x
WHERE IdTipoOperacion = 43 AND IdOperacion IN (@idOperacion);

INSERT INTO dbo.tSDOtransacciones (IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdTipoDDominioDestino, IdAuxiliar, IdDivisa, FactorDivisa, TipoMovimiento, MontoSubOperacion, Naturaleza, TotalCargos, TotalAbonos, CambioNeto, SubTotalGenerado, SubTotalPagado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, IdMovimiento, IdEstatus, Alta, UltimoCambio)
SELECT IdOperacion = Operacion.IdOperacion,
    IdTipoSubOperacion = 500,
    Fecha = Operacion.Fecha,
    Descripcion = 'PAGO DE NÓMINA',
    IdSaldoDestino = Saldo.IdSaldo,
    IdTipoDDominioDestino = 851,
    IdAuxiliar = Saldo.IdAuxiliar,
    IdDivisa = 1,
    FactorDivisa = 1,
    TipoMovimiento = 2,
    MontoSubOperacion = Pagos.total,
    Naturaleza = 1,
    TotalCargos = Pagos.total,
    TotalAbonos = 0,
    CambioNeto = Pagos.total,
    SubTotalGenerado = Pagos.total,
    SubTotalPagado = 0,
    Concepto = Saldo.Descripcion,
    Referencia = Periodo.Codigo,
    IdSucursal = Saldo.IdSucursal,
    IdEstructuraContableE = Saldo.IdEstructuraContable,
    IdCentroCostos = Sucursal.IdCentroCostos,
    IdMovimiento = -1,
    IdEstatus = 1,
    Alta = GETDATE (),
    UltimoCambio = GETDATE ()
FROM dbo.tGRLoperaciones Operacion WITH (NOLOCK)
JOIN dbo.tCTLperiodos Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = Operacion.IdPeriodo
JOIN dbo.tSDOsaldos Saldo WITH (NOLOCK) ON Saldo.IdSaldo = 203618 --1054854
JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = Saldo.IdSucursal
JOIN (SELECT IdOperacion = @idOperacion, total = SUM (Monto) FROM ##AplicacionCreditos) AS Pagos ON Pagos.IdOperacion = Operacion.IdOperacion
WHERE Operacion.IdOperacion = @idOperacion AND Operacion.IdTipoOperacion = 43 AND NOT EXISTS (   SELECT Transaccion.IdOperacion
                                                                                                 FROM dbo.tSDOtransacciones Transaccion WITH (NOLOCK)
                                                                                                 WHERE Transaccion.IdEstatus = 1 AND Transaccion.IdOperacion = Operacion.IdOperacion AND Transaccion.IdSaldoDestino = Saldo.IdSaldo);

UPDATE Operacion
SET IdEstatus = 1
FROM dbo.tGRLoperaciones Operacion WITH (NOLOCK)
WHERE Operacion.IdOperacion = @idOperacion AND IdTipoOperacion = 43 AND IdOperacionPadre = @idOperacion;

EXEC dbo.pIMPgenerarTransaccionesImpuestos @IdOperacionPadre = @idOperacion;

EXEC dbo.pCNTrecontabilizacionOperacion @IdOperacion = @idOperacion;

SELECT IdOperacion,
    Fecha,
    TotalPagado = SUM (ISNULL (Transaccion.CapitalPagado, 0) + ISNULL (Transaccion.CapitalPagadoVencido, 0) + ISNULL (Transaccion.InteresOrdinarioPagado, 0) + ISNULL (Transaccion.InteresOrdinarioPagadoVencido, 0) + ISNULL (Transaccion.InteresMoratorioPagado, 0) + ISNULL (Transaccion.InteresMoratorioPagadoVencido, 0) + ISNULL (Transaccion.IVAInteresOrdinarioPagado, 0) + ISNULL (Transaccion.IVAInteresMoratorioPagado, 0) + ISNULL (Transaccion.CargosPagados, 0) + ISNULL (Transaccion.IVACargosPagado, 0)),
    COUNT (*)
FROM dbo.tSDOtransaccionesFinancieras Transaccion WITH (NOLOCK)
WHERE IdOperacion = @idOperacion
GROUP BY Transaccion.IdOperacion,
    Transaccion.Fecha;

SELECT Parcialidad.IdParcialidad,
    TF.IdCuenta,
    app.Monto,
    Parcialidad.Inicio,
    Parcialidad.Vencimiento,
    Parcialidad.EstaPagada,
    Diff = Parcialidad.Capital - Parcialidad.CapitalPagado,
    Parcialidad.CapitalPagado,
    Parcialidad.InteresOrdinario,
    Parcialidad.InteresMoratorio,
    Parcialidad.InteresOrdinarioPagado,
    Parcialidad.InteresMoratorioPagado,
    Parcialidad.IVAInteresOrdinario,
    Parcialidad.IVAInteresOrdinarioPagado,
    Parcialidad.IVAInteresMoratorio,
    Parcialidad.IVAInteresMoratorioPagado
FROM dbo.tSDOtransaccionesFinancieras TF WITH (NOLOCK)
INNER JOIN dbo.tAYCparcialidades Parcialidad WITH (NOLOCK) ON TF.IdCuenta = Parcialidad.IdCuenta
INNER JOIN dbo.tAYCcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuenta = TF.IdCuenta
INNER JOIN ##AplicacionCreditos app WITH (NOLOCK) ON Cuenta.Codigo = app.Cuenta COLLATE DATABASE_DEFAULT
WHERE TF.IdOperacion = @idOperacion AND TF.Fecha BETWEEN Parcialidad.Inicio AND Parcialidad.Vencimiento
ORDER BY Parcialidad.Capital - Parcialidad.CapitalPagado,
    Parcialidad.IdCuenta,
    Parcialidad.IdParcialidad;

--SELECT Partida = ROW_NUMBER () OVER (PARTITION BY Transaccion.IdCuenta ORDER BY Operacion.Fecha, Transaccion.IdTransaccion), Operacion.IdOperacion, Transaccion.IdTransaccion, Operacion.IdTipoOperacion, Transaccion.IdCuenta, Transaccion.Fecha, Transaccion.CapitalGenerado, CapitalPagado = ISNULL(Transaccion.CapitalPagado, 0)+ISNULL(Transaccion.CapitalPagadoVencido, 0), InteresOrdinarioPagado = ISNULL(Transaccion.InteresOrdinarioPagado, 0)+ISNULL(Transaccion.InteresOrdinarioPagadoVencido, 0), InteresMoratorioPagado = ISNULL(Transaccion.InteresMoratorioPagado, 0)+ISNULL(Transaccion.InteresMoratorioPagadoVencido, 0), IVAPagado = ISNULL(Transaccion.IVAInteresOrdinarioPagado, 0)+ISNULL(Transaccion.IVAInteresMoratorioPagado, 0), Transaccion.TotalPagado
--FROM ##AplicacionCreditos app
--INNER JOIN dbo.tAYCcuentas cta ON cta.Codigo = app.Cuenta COLLATE DATABASE_DEFAULT
--LEFT JOIN dbo.tSDOtransaccionesFinancieras Transaccion WITH( NOLOCK ) ON Transaccion.IdCuenta = cta.IdCuenta
--LEFT JOIN dbo.tGRLoperaciones Operacion WITH( NOLOCK )ON Operacion.IdOperacion = Transaccion.IdOperacion
--WHERE Transaccion.IdEstatus = 1 AND Operacion.IdOperacionPadre = @idOperacion
GO