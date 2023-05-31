CREATE PROCEDURE dbo.pCNTimportarPoliza
AS

TRUNCATE TABLE dbo.tmpPolizas ;
ALTER TABLE dbo.tmpPolizas ALTER COLUMN cuentacontable BIGINT ;
INSERT INTO dbo.tmpPolizas(numeropolizaexterno, fecha, conceptopoliza, tipo, cuentacontable, concepto, cargo, abono, divisa, sucursal, Partida)
SELECT [numero poliza externo],
       fecha,
       conceptopoliza,
       tipo,
       cuentacontable,
       concepto,
       cargo = ISNULL(cargo, 0),
       abono = ISNULL(abono, 0),
       divisa,
       sucursal,
       Id
FROM ##Polizas ;

ALTER TABLE dbo.tmpPolizas ALTER COLUMN cuentacontable VARCHAR(50) ;
EXECUTE dbo.pLAYvalidarLayout @TipoOperacion = 'VALIDAR', @Id = 168 ;

/*POLIZA INCORRECTA*/
IF EXISTS (SELECT 1 FROM dbo.tmpPolizas WHERE IdEstatus = 39)
BEGIN
    SELECT numeropolizaexterno,
           fecha,
           conceptopoliza,
           tipo,
           cuentacontable,
           centrocostos,
           referencia,
           concepto,
           cargo,
           abono,
           divisa,
           sucursal
    FROM dbo.tmpPolizas
    WHERE IdEstatus = 39 ;
    RETURN ;
END ;


DECLARE @IdPolizaE   INT,
        @Fecha       DATE,
        @Concepto    VARCHAR(80),
        @IdEjercicio INT,
        @IdPeriodo   INT,
        @IdSucursal  INT ;

SELECT TOP 1 @Fecha = fecha,
             @Concepto = conceptopoliza,
             @IdEjercicio = dbo.fGETidEjercicio(fecha),
             @IdPeriodo = dbo.fGETidPeriodo(fecha),
             @IdSucursal = IdSucursal
FROM dbo.tmpPolizas ;


EXECUTE dbo.pCRUDpolizasE @TipoOperacion = 'C',
                          @IdPolizaE = @IdPolizaE OUTPUT,
                          @IdRecurso = 118,
                          @Fecha = @Fecha,
                          @Concepto = @Concepto,
                          @IdEjercicio = @IdEjercicio,
                          @IdPeriodo = @IdPeriodo,
                          @IdSucursal = 1,
                          @IdTipoDOrigen = 802,
                          @IdListaDPoliza = -1,
                          @IdEstatus = 1,
                          @IdUsuarioAlta = -1,
                          @IdUsuarioCambio = -1,
                          @IdTipoDDominio = 150 ;


INSERT INTO dbo.tCNTpolizasD(IdPolizaE, Partida, IdCuentaContable, IdCentroCostos, Referencia, Concepto, Cargo, Abono, IdDivisa, IdSucursal)
SELECT IdPolizaE = @IdPolizaE,
       Partida = Id,
       IdCuentaContable,
       IdCentroCostos,
       referencia,
       concepto,
       cargo,
       abono,
       IdDivisa,
       IdSucursal
FROM dbo.tmpPolizas ;

EXECUTE dbo.pCNTpolizasR @TipoOperacion = 15, @IdPolizaE = @IdPolizaE ;


SELECT IdEstatus = 38, 'LA POLIZA SE IMPORTO CORRECTAMENTE';

