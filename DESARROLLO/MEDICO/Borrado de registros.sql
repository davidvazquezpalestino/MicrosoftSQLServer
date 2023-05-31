
DELETE FROM Fiscal.DocumentosFiscalesD WHERE IdDocumentoFiscalD > 0
DBCC CHECKIDENT('Fiscal.DocumentosFiscalesD',RESEED, 0)

DELETE FROM Fiscal.DocumentosFiscales WHERE IdDocumentoFiscal > 0
DBCC CHECKIDENT('Fiscal.DocumentosFiscales',RESEED, 0)

DELETE FROM Produccion.DocumentosD WHERE IdDocumentoD > 0
DBCC CHECKIDENT('Produccion.DocumentosD',RESEED, 0)

DELETE FROM Produccion.Documentos WHERE IdDocumento > 0
DBCC CHECKIDENT('Produccion.Documentos',RESEED, 0)

DELETE FROM Ventas.Productos WHERE IdProducto > 0
DBCC CHECKIDENT('Ventas.Productos',RESEED, 0)

DELETE FROM Persona.Clientes WHERE IdCliente > 0
DBCC CHECKIDENT('Persona.Clientes',RESEED, 0)

DELETE FROM Persona.Proveedores WHERE IdProveedor > 0
DBCC CHECKIDENT('Persona.Proveedores',RESEED, 0)

DELETE FROM Persona.Usuarios WHERE IdUsuario > 0
DBCC CHECKIDENT('Persona.Usuarios',RESEED, 0)

DELETE FROM RecursosHumanos.Activos WHERE IdActivo > 0
DBCC CHECKIDENT('RecursosHumanos.Activos',RESEED, 0)

DELETE FROM RecursosHumanos.Empleados WHERE IdEmpleado > 0
DBCC CHECKIDENT('RecursosHumanos.Empleados',RESEED, 0)

DELETE FROM RecursosHumanos.Puestos WHERE IdPuesto > 0
DBCC CHECKIDENT('RecursosHumanos.Puestos',RESEED, 0)

DELETE FROM RecursosHumanos.Departamentos WHERE IdDepartamento > 0
DBCC CHECKIDENT('RecursosHumanos.Departamentos',RESEED, 0)

DELETE FROM dbo.Sesiones WHERE IdSesion > 0
DBCC CHECKIDENT('dbo.Sesiones',RESEED, 0)

DELETE FROM Persona.Personas WHERE IdPersona > 0
DBCC CHECKIDENT('Persona.Personas',RESEED, 0)

DELETE FROM Produccion.Proyectos WHERE IdProyecto > 0
DBCC CHECKIDENT('Produccion.Proyectos',RESEED, 0)

DELETE FROM Inventario.ProductoUnidadMedida WHERE IdProductoUnidadMedida > 0
DBCC CHECKIDENT('Inventario.ProductoUnidadMedida',RESEED, 0)

DELETE FROM Persona.Domicilios WHERE IdDomicilio > 0
DBCC CHECKIDENT('Persona.Domicilios',RESEED, 0)

DELETE FROM Inventario.Almacenes WHERE IdAlmacen > 0
DBCC CHECKIDENT('Inventario.Almacenes',RESEED, 0)

DELETE FROM Catalogo.ListasD WHERE IdListaD > 0
DBCC CHECKIDENT('Catalogo.ListasD',RESEED, 0)

DELETE FROM Catalogo.Empresas WHERE IdEmpresa > 0
DBCC CHECKIDENT('Catalogo.Empresas',RESEED, 0)

DELETE FROM Finanzas.CuentasBancarias WHERE IdCuentaBancaria > 0
DBCC CHECKIDENT('Finanzas.CuentasBancarias',RESEED, 0)





