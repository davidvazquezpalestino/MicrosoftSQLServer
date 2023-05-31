
IF NOT EXISTS (SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual = -2515)
BEGIN
    SET IDENTITY_INSERT tCTLestatusActual ON;
    INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl)
    VALUES(-2515, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0);
    SET IDENTITY_INSERT tCTLestatusActual OFF;
END;
GO
IF NOT EXISTS (SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual = -2516)
BEGIN
    SET IDENTITY_INSERT tCTLestatusActual ON;
    INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl)
    VALUES(-2516, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0);
    SET IDENTITY_INSERT tCTLestatusActual OFF;
END;
GO
IF NOT EXISTS (SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual = -2517)
BEGIN
    SET IDENTITY_INSERT tCTLestatusActual ON;
    INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl)
    VALUES(-2517, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0);
    SET IDENTITY_INSERT tCTLestatusActual OFF;
END;
GO
IF NOT EXISTS (SELECT IdDivision FROM tCNTdivisiones WHERE IdDivision = -45)
BEGIN
    SET IDENTITY_INSERT tCNTdivisiones ON;
    INSERT INTO tCNTdivisiones(IdDivision, Codigo, Descripcion, RelCatalogosAsignados, IdEstatusActual, IdCatalogoSITI, IdCatalogoSITIclasificacionCreditoDestino)
    VALUES(-45, 'ING-INTERES', 'INGRESOS POR INTERESES', -45, -2517, 0, 0);
    SET IDENTITY_INSERT tCNTdivisiones OFF;
END;
GO
IF NOT EXISTS (SELECT IdEstructuraCatalogo FROM tGRLestructurasCatalogos WHERE IdEstructuraCatalogo = -87)
BEGIN
    SET IDENTITY_INSERT tGRLestructurasCatalogos ON;
    INSERT INTO tGRLestructurasCatalogos(IdEstructuraCatalogo, IdEstructuraContableE, IdClaseD1, IdClaseD2, IdClaseD3, IdClaseD4, IdClaseD5, IdClaseD6, IdTipoDDominio, IdControl)
    VALUES(-87, -18, 0, 0, 0, 0, 0, 0, 141, 0);
    SET IDENTITY_INSERT tGRLestructurasCatalogos OFF;
END;
GO
IF NOT EXISTS (SELECT IdBienServicio FROM dbo.tGRLbienesServicios WHERE IdBienServicio = -2019)
BEGIN
    SET IDENTITY_INSERT tGRLbienesServicios ON;
    INSERT INTO dbo.tGRLbienesServicios(IdBienServicio, IdTipoD, Codigo, Descripcion, DescripcionLarga, CostoEstandar, CostoPromedio, UltimoCosto, PorcentajeDeducible, IdListaDUDM, IdImpuesto, IdImpuestoFronterizo, IdImpuestoCompra, IdImpuestoCompraFronterizo, IdAlmacen, IdEstructuraCatalogo, IdDivision, RelPreciosAsinados, SeCompra, SeVende, RequiereContratacion, IdServicio, MultiApertura, IdEstatusActual, EsComisionApertura, EsGastoCobranza, AplicaPuntoVenta, EsPercepcion, IdTipoDpercepcionDeduccion, IdCuentaABCD, IdAuxiliar, Orden, AplicaGravado, AplicaExento, IdTipoDdeudorPercepcion, Naturaleza, IdTipoDaplicacion, IdTipoDcalculoPersonalizado, IdTipoDefectoContable, IdSATproductoServicio, IdSATunidadMedida, PermiteCambiarPrecioVenta)
    VALUES(-2019, 100, 'INT-ORD', 'INTERES ORDINARIO', 'INTERES MORATORIO', 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, -87, -45, 0, 0, 1, 0, 0, 0, -2515, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1524, 0, 0, 0, 0, 0);
    SET IDENTITY_INSERT tGRLbienesServicios OFF;
END;
GO
IF NOT EXISTS (SELECT IdBienServicio FROM dbo.tGRLbienesServicios WHERE IdBienServicio = -2020)
BEGIN
    SET IDENTITY_INSERT tGRLbienesServicios ON;
    INSERT INTO dbo.tGRLbienesServicios(IdBienServicio, IdTipoD, Codigo, Descripcion, DescripcionLarga, CostoEstandar, CostoPromedio, UltimoCosto, PorcentajeDeducible, IdListaDUDM, IdImpuesto, IdImpuestoFronterizo, IdImpuestoCompra, IdImpuestoCompraFronterizo, IdAlmacen, IdEstructuraCatalogo, IdDivision, RelPreciosAsinados, SeCompra, SeVende, RequiereContratacion, IdServicio, MultiApertura, IdEstatusActual, EsComisionApertura, EsGastoCobranza, AplicaPuntoVenta, EsPercepcion, IdTipoDpercepcionDeduccion, IdCuentaABCD, IdAuxiliar, Orden, AplicaGravado, AplicaExento, IdTipoDdeudorPercepcion, Naturaleza, IdTipoDaplicacion, IdTipoDcalculoPersonalizado, IdTipoDefectoContable, IdSATproductoServicio, IdSATunidadMedida, PermiteCambiarPrecioVenta)
    VALUES(-2020, 100, 'INT-MOR', 'INTERES MORATORIO', 'INTERES MORATORIO', 0.00000000, 0.00000000, 0.00000000, 0.00000000, 0, 1, 0, 0, 0, 0, -87, -45, 0, 0, 1, 0, 0, 0, -2516, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1524, 0, 0, 21, 23, 0);
    SET IDENTITY_INSERT tGRLbienesServicios OFF;
END;
GO

