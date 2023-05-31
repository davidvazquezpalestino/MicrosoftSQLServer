
/*CATEGORIAS DE PRODUCTOS*/
INSERT INTO Catalogo.ListasD ( IdTipoE, Codigo, Descripcion, IdEstatus )
SELECT IdTipoE = 5,
       Codigo = CONCAT ('00', ROW_NUMBER () OVER ( ORDER BY Categoria )),
       Categoria,
       IdEstatus = 1
FROM ##Productos
WHERE Categoria IS NOT NULL
GROUP BY Categoria;

/*PRODUCTOS*/
INSERT INTO Ventas.Productos ( Codigo, Descripcion, Costo, MargenGanancia, Precio, PrecioConImpuesto, IdProductoUnidadMedida, IdListaDCategoria, IdMetodoCosteo, IdImpuesto, Inventariable, IdAlmacen, Reorden, IdProductoFacturacion, IdUnidadMedidaFacturacion, InventarioMinimo, InventarioMaximo, IdSesion, IdEstatus )
SELECT Codigo = RIGHT(p.Codigo, 3),
       p.Descripcion,
       Costo,
       MargenVenta,
       PrecioVenta,
       PrecioConImpuesto = PrecioVenta * 1.16,
       IdProductoUnidadMedida = ISNULL (udm.IdProductoUnidadMedida, 0),
       l.IdListaD,
       IdMetodoCosteo = 12,
       IdImpuesto = 1,
       Inventariable = 1,
       IdAlmacen = -1,
       Reorden = 5,
       IdProductoFacturacion = 0,
       IdUnidadMedidaFacturacion = 0,
       InventarioMinimo = 1,
       InventarioMaximo = 100,
       IdSesion = 0,
       IdEstatus = 1
FROM ##Productos p
LEFT JOIN Catalogo.ListasD l ON l.Descripcion = p.Categoria
LEFT JOIN Ventas.ProductoUnidadMedida udm ON udm.Nombre = UniadMedida
WHERE p.Descripcion IS NOT NULL AND NOT EXISTS ( SELECT 1
                                                 FROM Ventas.Productos pro
                                                 WHERE pro.Codigo = RIGHT(p.Codigo, 3));

DELETE FROM Inventario.ProductoTransacciones
WHERE IdProductoInventario > 0;

DELETE FROM Produccion.DocumentosD
WHERE IdDocumentoD > 0;

DELETE FROM Produccion.Documentos
WHERE IdDocumento > 0;

DBCC CHECKIDENT('Produccion.DocumentosD', RESEED, -1);

DBCC CHECKIDENT('Produccion.Documentos', RESEED, 0);

DECLARE @IdDocumento INT = 0;

INSERT INTO Produccion.Documentos ( IdTipoDocumento, Fecha, IdAlmacenEntrada, IdEstatus )
VALUES ( 3, GETDATE (), -1, 1 );

SET @IdDocumento = SCOPE_IDENTITY ();

INSERT INTO Produccion.DocumentosD ( IdDocumento, IdProducto, Partida, Costo, PrecioUnitario, Cantidad, MontoDescuento, Entrada, Salida, IdImpuesto, IdAlmacen, IVA, FechaAlta, IdEstatus )
SELECT IdDocumento = 1,
       IdProducto,
       Partida = ROW_NUMBER () OVER ( ORDER BY IdProducto ),
       Costo,
       Precio,
       Cantidad = 1000,
       MontoDescuento = 0,
       Entrada = 10,
       Salida = 0,
       IdImpuesto = 1,
       IdAlmacen = -1,
       0,
       FechaAlta = CURRENT_TIMESTAMP,
       IdEstatus = 1
FROM Ventas.Productos
WHERE IdProducto > 10;

INSERT INTO Inventario.ProductoTransacciones ( IdProducto, IdTipoDocumento, IdDocumentoD, IdAlmacen, Entrada, Salida, Costo, CostoPromedio, Existencia, Fecha, IdEstatus )
SELECT Producto.IdProducto,
       IdTipoDocumento = 3,
       DocumentoD.IdDocumentoD,
       DocumentoD.IdAlmacen,
       DocumentoD.Entrada,
       DocumentoD.Salida,
       DocumentoD.Costo,
       DocumentoD.Costo,
       DocumentoD.Entrada,
       Fecha = CURRENT_TIMESTAMP,
       IdEstatus = 1
FROM Ventas.Productos Producto
INNER JOIN Produccion.DocumentosD DocumentoD ON DocumentoD.IdProducto = Producto.IdProducto
INNER JOIN Produccion.Documentos Documento ON Documento.IdDocumento = DocumentoD.IdDocumento
WHERE Producto.IdProducto > 0 AND Documento.IdTipoDocumento = 3;



INSERT INTO Inventario.ProductoAlmacenes ( IdProducto, IdAlmacen, Existencia, UltimoCosto, CostoPromedio, IdUltimoDocumentoD )
SELECT IdProducto, IdAlmacen, Entrada, Costo, Costo, IdDocumentoD
FROM Produccion.DocumentosD
WHERE IdDocumento = 1

EXECUTE dbo.pActualizarExistenciasProductoAlmacen;
