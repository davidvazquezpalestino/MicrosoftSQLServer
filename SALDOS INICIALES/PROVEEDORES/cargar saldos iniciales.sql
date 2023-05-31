--COMMIT TRANSACTION 

IF OBJECT_ID('tempdb..#tmpSaldoInicialesProveedores') IS NOT NULL
    DROP TABLE #tmpSaldoInicialesProveedores

CREATE TABLE #tmpSaldoInicialesProveedores 
(
    [Proveedor] VARCHAR(13),
    [Fecha] DATE,
    [Concepto] VARCHAR(80),
    [Referencia] VARCHAR(18),
    [Auxiliar] VARCHAR(20),
    [Monto] DECIMAL(18, 2), 
	IdAuxiliar INT
);


INSERT INTO #tmpSaldoInicialesProveedores ( Proveedor, Fecha, Concepto, Referencia, Auxiliar, IdAuxiliar, Monto )
SELECT Proveedor, CAST(Fecha AS DATE), Concepto, Referencia = ISNULL(Folio,''),	Auxiliar, Auxiliar.IdAuxiliar,Saldo
FROM ##proveedores Proveedor
INNER JOIN dbo.tCNTauxiliares Auxiliar ON Auxiliar.Codigo COLLATE DATABASE_DEFAULT = Proveedor.Auxiliar COLLATE DATABASE_DEFAULT


DECLARE @Fecha AS DATE = (SELECT TOP 1 CAST(Fecha AS DATE) FROM ##proveedores)

INSERT INTO tSDOsaldos ( Codigo, Descripcion, IdPersona, IdEmisorProveedor, IdAuxiliar, IdDivisa, FactorDivisa, Naturaleza, IdSucursal, IdEstructuraContable, Factor, IdTipoDDominioCatalogo, IdEstatus )
SELECT     Proveedor.Codigo,
           Auxiliar.Descripcion,
           Proveedor.IdPersona,
           Proveedor.IdEmisorProveedor,
           Auxiliar.IdAuxiliar,
           IdDivisa               = 1,
           FactorDivisa           = 1,
           Naturaleza             = Auxiliar.Naturaleza,
           IdSucursal             = 1,
           IdEstructuraContable   = Estructura.ides,
           Factor                 = 1,
           IdTipoDDominioCatalogo = 137,
           IdEstatus              = 1
FROM       #tmpSaldoInicialesProveedores SaldoInicial
INNER JOIN dbo.tSCSemisoresProveedores   Proveedor ON Proveedor.Codigo COLLATE DATABASE_DEFAULT = SaldoInicial.Proveedor COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tGRLestructurasCatalogos Estructura ON Estructura.IdEstructuraCatalogo = Proveedor.IdEstructuraCatalogo
INNER JOIN dbo.tCNTauxiliares            Auxiliar ON Auxiliar.IdAuxiliar = SaldoInicial.IdAuxiliar
WHERE      NOT EXISTS ( SELECT 1
                        FROM   dbo.tSDOsaldos s WITH ( NOLOCK )
                        WHERE s.IdEstatus = 1 AND s.IdEmisorProveedor = Proveedor.IdEmisorProveedor AND s.IdAuxiliar = Auxiliar.IdAuxiliar );


DECLARE @IdOperacionPadre INT;

INSERT INTO tGRLoperaciones ( IdRecurso, Serie, Folio, IdTipoOperacion, Fecha, Concepto, IdPeriodo, IdSucursal, Referencia, IdDivisa, FactorDivisa, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, RequierePoliza, TienePoliza, IdListaDPoliza)
SELECT IdRecurso       = 0,
       Serie           = '',
       Folio           = 1,
       IdTipoOperacion = 15,
       Fecha           = @Fecha,
       Concepto        = 'SDI PROVEEDORES',
       IdPeriodo       = dbo.fGETidPeriodo(@Fecha),
       IdSucursal      = 1,
       Referencia      = @Fecha,
       IdDivisa        = 1,
       FactorDivisa    = 1,
       IdEstatus       = 1,
       IdUsuarioAlta   = -1,
       Alta            = GETDATE(),
       IdTipoDdominio  = 0,
       IdSesion        = 0,
       RequierePoliza  = 0,
       TienePoliza     = 0,
       IdListaDPoliza  = -1

SET @IdOperacionPadre = SCOPE_IDENTITY();
PRINT @IdOperacionPadre;

UPDATE dbo.tGRLoperaciones
SET    IdOperacionPadre = @IdOperacionPadre,
       RelOperaciones = @IdOperacionPadre
WHERE  IdOperacion = @IdOperacionPadre;


INSERT INTO dbo.tSDOtransacciones (IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdAuxiliar, IdDivisa, FactorDivisa, TipoMovimiento, MontoSubOperacion, Naturaleza, TotalCargos, TotalAbonos, CambioNeto, SubTotalGenerado, SubTotalPagado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, EsPrincipal, RetiroABCD, IdEstatus )
SELECT TOP 1 Idoperacion        = @IdOperacionPadre,
       IdTipoSubOperacion = CASE WHEN a.IdAuxiliar = -46 THEN
                                     521
								 WHEN a.IdAuxiliar = -30 THEN
								     518
                                ELSE
                                    521
                            END,
       Fecha              = tmp.Fecha,
       Descripcion        = 'SALDOS INICIALES',
       IdSaldoDestino     = sdo.IdSaldo,
       a.IdAuxiliar,
       IdDivisa           = 1,
       FactorDivisa       = 1,
       TipoMovimiento     = 2,
       MontoSubOperacion  = tmp.Monto,
       a.Naturaleza,
       TotalCargos        = tmp.Monto,
       TotalAbonos        = 0,
       CambioNeto         = tmp.Monto,
       SubTotalGenerado   = tmp.Monto,
       SubTotalPagado     = 0,
       Concepto           = tmp.Concepto,
       Referencia         = tmp.Referencia,
       sdo.IdSucursal,
       sdo.IdEstructuraContable,
       su.IdCentroCostos,
       EsPrincipal        = 1,
       tmp.Monto,
       1
FROM   #tmpSaldoInicialesProveedores tmp
JOIN   dbo.tCNTauxiliares            a ON a.IdAuxiliar = tmp.IdAuxiliar
JOIN   dbo.tSCSemisoresProveedores   pro ON pro.Codigo COLLATE DATABASE_DEFAULT = tmp.Proveedor COLLATE DATABASE_DEFAULT
JOIN   dbo.tSDOsaldos                sdo ON sdo.IdCuenta = 0 AND sdo.IdEstatus = 1 AND sdo.IdEmisorProveedor = pro.IdEmisorProveedor AND sdo.IdAuxiliar = a.IdAuxiliar
JOIN   dbo.tCTLsucursales            su ON su.IdSucursal = sdo.IdSucursal;



--EXECUTE dbo.pSDOactualizarSaldoBaseTransacciones @Operacion = 2 -- int




