SELECT Periodo = Periodo.Codigo,
       Sucursal = Sucursal.Descripcion,
       Articulo = Articulo.Descripcion,
       Division = Division.Descripcion,
       Activo.DescripcionLarga,
       Depreciacion.Depreciacion,
       Depreciacion.ValorRemanente,
       Depreciacion.VidaRemanente,
       Estatus = Estatus.Descripcion
  FROM dbo.tACTinformacionDepreciacion Depreciacion
  INNER JOIN dbo.tCTLperiodos Periodo ON Depreciacion.IdPeriodo = Periodo.IdPeriodo
  INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = Depreciacion.IdSucursal
  INNER JOIN dbo.tACTactivos Activo ON Activo.IdActivo = Depreciacion.IdActivo
  INNER JOIN dbo.tACTactivosExtendida ActivoExt ON ActivoExt.IdActivo = Activo.IdActivo
  INNER JOIN dbo.tGRLbienesServicios Articulo ON Articulo.IdBienServicio = Activo.IdBienServicio
  INNER JOIN dbo.tCNTdivisiones Division ON Division.IdDivision = Activo.IdDivision
  INNER JOIN dbo.tCTLestatus Estatus ON ActivoExt.IdEstatusDepreciacion = Estatus.IdEstatus ;
