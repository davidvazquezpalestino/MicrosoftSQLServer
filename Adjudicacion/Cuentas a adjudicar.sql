DECLARE @FechaTrabajo DATE = CURRENT_TIMESTAMP --DATEADD(DAY, 3, CURRENT_TIMESTAMP);


DROP TABLE IF EXISTS #tmpACTcuentas;
CREATE TABLE tempdb..#tmpACTcuentas ( [IdOperacion] int, [fechaAdjudicacion] date, [IdSucursal] int, [IdCuenta] int, [IdSocio] int, [MontoPrestadoCuenta] decimal(23,8), [Capital] decimal(23,8), [Ordinario] decimal(38,6), [Moratorio] decimal(38,6), [Impuestos] decimal(38,6), [Total] decimal(38,2), [diasMora] int )


INSERT INTO #tmpACTcuentas ([idOperacion], [fechaAdjudicacion], [idsucursal], [idcuenta], [idSocio], [MontoPrestadoCuenta], [capital], [Ordinario], [Moratorio], [impuestos], [total], [diasMora])

SELECT IdOperacion = 0,
    @FechaTrabajo,
    cta.IdSucursal,
    f.IdCuenta,
    cta.IdSocio,
    cta.MontoEntregado,
    f.Capital,
    f.InteresOrdinario,
    f.InteresMoratorio,
    f.Impuestos,
    Total = f.TotalALiquidar,
    f.MoraMaxima
FROM dbo.fAYCcalcularCarteraOperacion (@FechaTrabajo, 2, 0, 0, 'DEVPAG') f
JOIN dbo.tAYCcuentas cta WITH( NOLOCK )ON cta.IdEstatus IN (1) AND cta.IdProductoFinanciero = 1163 AND cta.IdCuenta = f.IdCuenta --AND cta.IdCuenta IN (962704) 
JOIN dbo.tAYCproductosFinancieros pro WITH( NOLOCK )ON pro.EsPrendario = 1 AND pro.IdProductoFinanciero = cta.IdProductoFinanciero
WHERE f.MoraMaxima >= 10
ORDER BY cta.IdSucursal,
    cta.Codigo;

/* variables */
DECLARE @IdCuenta INT,
    @IdSocio      INT;

DECLARE creditosPrendarios CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT cta.IdCuenta,
    cta.IdSocio
FROM dbo.tAYCcuentas cta WITH( NOLOCK )
INNER JOIN dbo.tAYCproductosFinancieros pro WITH( NOLOCK )ON pro.IdProductoFinanciero = cta.IdProductoFinanciero
WHERE cta.EsPrendario = 1 AND cta.IdEstatus = 1;

OPEN creditosPrendarios;

FETCH NEXT FROM creditosPrendarios
INTO @IdCuenta,
    @IdSocio;

WHILE @@FETCH_STATUS = 0
    BEGIN
		INSERT INTO #tmpACTcuentas ([idOperacion], [fechaAdjudicacion], [idsucursal], [idcuenta], [idSocio], [MontoPrestadoCuenta], [capital], [Ordinario], [Moratorio], [impuestos], [total], [diasMora])

        SELECT IdOperacion = 0,
            @FechaTrabajo,
            cta.IdSucursal,
            f.IdCuenta,
            cta.IdSocio,
            cta.MontoEntregado,
            f.Capital,
            f.InteresOrdinario,
            f.InteresMoratorio,
            f.Impuestos,
            Total = f.TotalALiquidar,
            f.MoraMaxima
        FROM dbo.fAYCcalcularCarteraOperacion (CURRENT_TIMESTAMP, 2, @IdCuenta, @IdSocio, 'DEVPAG') f
        JOIN dbo.tAYCcuentas cta WITH( NOLOCK )ON cta.IdEstatus IN (1) AND cta.IdProductoFinanciero = 3047 AND cta.IdCuenta = f.IdCuenta
        JOIN dbo.tAYCproductosFinancieros pro WITH( NOLOCK )ON pro.EsPrendario = 1 AND pro.IdProductoFinanciero = cta.IdProductoFinanciero
        WHERE cta.IdCuenta = @IdCuenta AND ( f.DiasMoraInteres >= 89 OR f.DiasMoraCapital >= 29 );

        FETCH NEXT FROM creditosPrendarios
        INTO @IdCuenta,
            @IdSocio;
    END;

CLOSE creditosPrendarios;
DEALLOCATE creditosPrendarios;


SELECT *
FROM #tmpACTcuentas