
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdAlmacen')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdAlmacen FOREIGN KEY(IdAlmacen) REFERENCES [dbo].[tALMalmacenes] (IdAlmacen)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdBienServicio')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdBienServicio FOREIGN KEY(IdBienServicio) REFERENCES [dbo].[tGRLbienesServicios] (IdBienServicio)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdCentroCostos')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdCentroCostos FOREIGN KEY(IdCentroCostos) REFERENCES [dbo].[tCNTcentrosCostos] (IdCentroCostos)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdClasificacionD')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdClasificacionD FOREIGN KEY(IdClasificacionD) REFERENCES [dbo].[tACTclasificacionesD] (IdClasificacionD)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdEstatus')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdEstatus FOREIGN KEY(IdEstatus) REFERENCES [dbo].[tCTLestatus] (IdEstatus)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdEstructuraContableE')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdEstructuraContableE FOREIGN KEY(IdEstructuraContableE) REFERENCES [dbo].[tCNTestructurasContablesE] (IdEstructuraContableE)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdObservacionE')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdObservacionE FOREIGN KEY(IdObservacionE) REFERENCES [dbo].[tCTLobservacionesE] (IdObservacionE)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdObservacionEDominio')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdObservacionEDominio FOREIGN KEY(IdObservacionEDominio) REFERENCES [dbo].[tCTLobservacionesE] (IdObservacionE)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdOperacionDorigen')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdOperacionDorigen FOREIGN KEY(IdOperacionDorigen) REFERENCES [dbo].[tGRLoperacionesD] (IdOperacionD)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdProyecto')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdProyecto FOREIGN KEY(IdProyecto) REFERENCES [dbo].[tPRYproyectos] (IdProyecto)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdSesion')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdSesion FOREIGN KEY(IdSesion) REFERENCES [dbo].[tCTLsesiones] (IdSesion)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdSucursal')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdSucursal FOREIGN KEY(IdSucursal) REFERENCES [dbo].[tCTLsucursales] (IdSucursal)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdUsuarioAlta')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdUsuarioAlta FOREIGN KEY(IdUsuarioAlta) REFERENCES [dbo].[tCTLusuarios] (IdUsuario)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdUsuarioCambio')
ALTER TABLE [dbo].[tACTactivos] ADD CONSTRAINT FK_tACTactivos_IdUsuarioCambio FOREIGN KEY(IdUsuarioCambio) REFERENCES [dbo].[tCTLusuarios] (IdUsuario)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivos')AND name = 'FK_tACTactivos_IdDivision')
ALTER TABLE dbo.tACTactivos ADD CONSTRAINT FK_tACTactivos_IdDivision FOREIGN KEY (IdDivision) REFERENCES dbo.tCNTdivisiones (IdDivision)
GO

GO
---------------------------------------- tACTactivosExtendida ----------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdActivo')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdActivo FOREIGN KEY(IdActivo) REFERENCES [dbo].[tACTactivos] (IdActivo)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdEmisorProveedor')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdEmisorProveedor FOREIGN KEY(IdEmisorProveedor) REFERENCES [dbo].[tSCSemisoresProveedores] (IdEmisorProveedor)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdEmpleadoAsignado')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdEmpleadoAsignado FOREIGN KEY(IdEmpleadoAsignado) REFERENCES [dbo].[tPERempleados] (IdEmpleado)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdEstatusDepreciacion')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdEstatusDepreciacion FOREIGN KEY(IdEstatusDepreciacion) REFERENCES [dbo].[tCTLestatus] (IdEstatus)

IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdTipoDvalorDepreciado')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdTipoDvalorDepreciado FOREIGN KEY(IdTipoDvalorDepreciado) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdTipoDvidaDepreciada')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdTipoDvidaDepreciada FOREIGN KEY(IdTipoDvidaDepreciada) REFERENCES [dbo].[tCTLtiposD] (IdTipoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdTipoDClasificacion')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdTipoDClasificacion FOREIGN KEY(IdTipoDClasificacion) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdTipoDmetodo')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdTipoDmetodo FOREIGN KEY(IdTipoDmetodo) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTactivosExtendida')AND name = 'FK_tACTactivosExtendida_IdTipoDActivo')
ALTER TABLE [dbo].[tACTactivosExtendida] ADD CONSTRAINT FK_tACTactivosExtendida_IdTipoDActivo FOREIGN KEY(IdTipoDActivo) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO

----------------------- tACTinformacionDepreciacion ---------------------------
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdPeriodo') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdPeriodo FOREIGN KEY(IdPeriodo) REFERENCES [dbo].[tCTLperiodos] (IdPeriodo)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdActivo') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdActivo FOREIGN KEY(IdActivo) REFERENCES [dbo].[tACTactivos] (IdActivo)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdEstatus') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdEstatus FOREIGN KEY(IdEstatus) REFERENCES [dbo].[tCTLestatus] (IdEstatus)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdOperacion') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdOperacion FOREIGN KEY(IdOperacion) REFERENCES [dbo].[tGRLoperaciones] (IdOperacion)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdOperacionD') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdOperacionD FOREIGN KEY(IdOperacionD) REFERENCES [dbo].[tGRLoperacionesD] (IdOperacionD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdTipoDmetodo') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdTipoDmetodo FOREIGN KEY(IdTipoDmetodo) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdTipoDvalorDepreciado') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdTipoDvalorDepreciado FOREIGN KEY(IdTipoDvalorDepreciado) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO
IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('tACTinformacionDepreciacion')AND name = 'FK_tACTinformacionDepreciacion_IdTipoDvidaDepreciada') 
	ALTER TABLE [dbo].[tACTinformacionDepreciacion] ADD CONSTRAINT FK_tACTinformacionDepreciacion_IdTipoDvidaDepreciada FOREIGN KEY(IdTipoDvidaDepreciada) REFERENCES [dbo].[tCTLtiposD] (IdTIpoD)
GO



