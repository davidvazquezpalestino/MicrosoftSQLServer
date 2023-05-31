CREATE FUNCTION [dbo].[fCFDIglobal](@IdPeriodo INT)
RETURNS TABLE
AS
RETURN(

      SELECT
          --Identificadores
          Operacion.IdOperacion, IdTransaccionFinanciera = Transaccion.IdTransaccion, Periodo.IdPeriodo, Cuenta.IdCuenta, Impuesto.IdImpuesto,
          --Concepto
          Concepto = 'INTERÉSES',
          --InteresOrdinario
          Transaccion.InteresOrdinarioPagado, Transaccion.InteresOrdinarioPagadoVencido, Transaccion.IVAInteresOrdinarioPagado,
          --InteresMoratorio
          Transaccion.InteresMoratorioPagado, Transaccion.InteresMoratorioPagadoVencido, Transaccion.IVAInteresMoratorioPagado,
          --Cargos
          Transaccion.CargosPagados, Transaccion.IVACargosPagado,
          --Ventas
          IdBienServicio  =  0, VentaSubTotal = 0, VentaIVA = 0
      FROM dbo.tGRLoperaciones Operacion WITH(NOLOCK)
      INNER JOIN dbo.vSDOtransaccionesFinancierasISNULL Transaccion WITH(NOLOCK)ON Transaccion.IdOperacion = Operacion.IdOperacion
      INNER JOIN dbo.tAYCcuentas Cuenta WITH(NOLOCK)ON Cuenta.IdCuenta = Transaccion.IdCuenta
      INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Periodo.IdPeriodo = Operacion.IdPeriodo
      INNER JOIN dbo.tIMPimpuestos Impuesto WITH(NOLOCK)ON Impuesto.IdImpuesto = Transaccion.IdImpuesto
      INNER JOIN dbo.tCTLestatus Estatus WITH(NOLOCK)ON Estatus.IdEstatus = Cuenta.IdEstatus
      WHERE Transaccion.IdEstatus = 1 AND Cuenta.IdTipoDProducto = 143 AND Periodo.IdPeriodo = @IdPeriodo AND(Transaccion.InteresOrdinarioPagado+Transaccion.InteresOrdinarioPagadoVencido+Transaccion.InteresMoratorioPagado+Transaccion.InteresMoratorioPagadoVencido)>0
      UNION ALL
      --GASTOS DE COBRANZA
      SELECT
          --Identificadores
          operacion.IdOperacion, IdTransaccionFinanciera = Transaccion.IdTransaccion, Periodo.IdPeriodo, cuenta.IdCuenta, Transaccion.IdImpuesto,
          --Concepto
          Concepto = Bien.Descripcion,
          --InteresOrdinario
          Transaccion.InteresOrdinarioPagado, Transaccion.InteresOrdinarioPagadoVencido, Transaccion.IVAInteresOrdinarioPagado,
          --InteresMoratorio
          Transaccion.InteresMoratorioPagado, Transaccion.InteresMoratorioPagadoVencido, Transaccion.IVAInteresMoratorioPagado,
          --Cargos
          Transaccion.CargosPagados, Transaccion.IVACargosPagado,
          --Venta
          Bien.IdBienServicio, VentaSubTotal = 0, VentaIVA = 0
      FROM dbo.tGRLoperaciones operacion
      INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Periodo.IdPeriodo = operacion.IdPeriodo
      INNER JOIN dbo.vSDOtransaccionesFinancierasISNULL Transaccion WITH(NOLOCK)ON Transaccion.IdOperacion = operacion.IdOperacion AND Transaccion.IdEstatus = 1
      INNER JOIN dbo.tAYCcuentas cuenta WITH(NOLOCK)ON cuenta.IdCuenta = Transaccion.IdCuenta AND cuenta.IdTipoDProducto = 143
      INNER JOIN dbo.tGRLbienesServicios Bien WITH(NOLOCK)ON Bien.IdBienServicio = Transaccion.IdBienServicio
      WHERE operacion.IdPeriodo = @IdPeriodo AND(Transaccion.CargosPagados)! = 0
      -- VENTAS
      UNION ALL
      SELECT
          --Identificadores
          operacion.IdOperacion, IdTransaccionFinanciera = 0, Periodo.IdPeriodo, IdCuenta = 0, OperacionesD.IdImpuesto,
          --Concepto
          Concepto = Bien.Descripcion,
          --InteresOrdinario
          InteresOrdinarioPagado = 0, InteresOrdinarioPagadoVencido = 0, IVAInteresOrdinarioPagado = 0,
          --InteresMoratorio
          InteresMoratorioPagado = 0, InteresMoratorioPagadoVencido = 0, IVAInteresMoratorioPagado = 0,
          --Cargos
          CargosPagados = 0, IVACargosPagado = 0,
          --Venta
          Bien.IdBienServicio, VentaSubTotal = OperacionesD.Subtotal, VentaIVA = operacion.IVA
      FROM dbo.tGRLoperaciones operacion WITH(NOLOCK)
      INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Periodo.IdPeriodo = operacion.IdPeriodo
      INNER JOIN dbo.tGRLoperacionesD OperacionesD WITH(NOLOCK)ON OperacionesD.RelOperacionD = operacion.IdOperacion
      INNER JOIN dbo.tGRLoperaciones operacionPadre WITH(NOLOCK)ON operacionPadre.IdOperacion = operacion.IdOperacionPadre
      INNER JOIN dbo.tGRLbienesServicios Bien WITH(NOLOCK)ON Bien.IdBienServicio = OperacionesD.IdBienServicio
      WHERE operacion.IdTipoOperacion = 17 AND OperacionesD.IdTipoSubOperacion = 17 AND operacionPadre.IdPeriodo = @IdPeriodo AND OperacionesD.IdEstatus = 1 AND operacionPadre.IdEstatus = 1 AND operacion.SubTotal>0 AND operacion.IdOperacion ! = operacionPadre.IdOperacion);
