--SELECT * FROM dbo.vta_fac_enc ORDER BY fecha DESC

SELECT 
       [Clave Unidad SAT] = ISNULL(UnidadMedida.ClaveUnidad, ''),
       [Descripción Unidad] = ISNULL(UnidadMedida.Descripcion, ''),
       [Clave Producto SAT] = ISNULL(ProductoSat.ClaveProductoServicio, ''),
       [SKU, # Serie, Codigo Barras] = Producto.clave,
       [Descripción Producto] = Producto.des,
       [Precio Unitario] = Producto.precio,
	   [Descuento] = 0,
       [Objeto de Impuesto] = CASE Impuesto.tasa WHEN 16 THEN
                                                      '02 - Sí objeto de impuesto.'
                                                 ELSE ''
                              END,
       IVA = Impuesto.tasa / 100,
       IEPS = 0,
       [Retiene 2/3 IVA] = '0 - No',
       [Retiene ISR] = '0 - No',
       [Retiene 4 % IVA] = '0 - No',
       [Retiene 100 % IVA] = '0 - No',
       [Realiza Calculo Inverso] = '0 - No'
FROM dbo.cat_pro Producto
INNER JOIN dbo.tSATproductosServicios ProductoSat ON ProductoSat.IdSATproductoServicio = Producto.IdSATproductoServicio
INNER JOIN dbo.tSATunidadesMedida UnidadMedida ON UnidadMedida.IdSATunidadMedida = Producto.IdSATunidadMedida
INNER JOIN dbo.cat_impto Impuesto ON Impuesto.id_impto = Producto.id_impto
WHERE Producto.status = 1;

SELECT Cliente.clave,
       Cliente.rfc,
       nombre= Cliente.nom1,
       RegimenFiscal = CONCAT (Regimen.RegimenFiscal, '-', Regimen.Descripcion),
       Cliente.curp,
       TaxId = '',
       [Método de Pago] = CONCAT (Metodo.MetodoPago, '-', Metodo.Descripcion),
       [Forma de Pago] = CONCAT (Forma.FormaPago, '-', Forma.Descripcion),
       [Uso de CFDI] = CONCAT (uso.UsoCFDI, '-', uso.Descripcion),
       [Moneda] = moneda.ley2,
       [Condiciones de Pago] = '',
       [Correo] = Cliente.email,
       [Calle] = Cliente.calle,
       [No. Exterior] = Cliente.num_ext,
       [No. Interior] = Cliente.num_int,
       [Colonia] = Cliente.col,
       [Municipio o Alcaldía] = Cliente.deleg,
       [Localidad] = '',
       [Estado] = Cliente.est,
       [Código Postal] = Cliente.cp,
       [País] = ''
FROM dbo.cat_clientes Cliente
INNER JOIN dbo.tSATregimenFiscal Regimen ON Cliente.IdRegimenFiscalSAT = Regimen.IdSATregimenFiscal
INNER JOIN dbo.tSATMetodosPago Metodo ON Metodo.IdSATmetodoPago = Cliente.IdMetodoPagoSAT
INNER JOIN dbo.tSATformasPago Forma ON Cliente.IdFormaPagoSAT = Forma.IdSATformaPago
INNER JOIN dbo.tSATusoCFDI uso ON Cliente.IdUsoCFDI = uso.IdSATusoCFDI
INNER JOIN dbo.mon_monedas moneda ON moneda.id_moneda = Cliente.id_mda
WHERE Cliente.status = 1 AND Cliente.clave <> '0';
