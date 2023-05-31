/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/04/2019
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFELfacturaGlobalIngresosResumen'))
	DROP VIEW dbo.vFELfacturaGlobalIngresosResumen
GO

CREATE VIEW dbo.vFELfacturaGlobalIngresosResumen
AS
SELECT  Resumen.IdBienServicio,
		Resumen.IdImpuesto,
		Concepto = Bien.Descripcion,
		Resumen.Precio,
		PrecioConImpuestos = Precio + ROUND ((Resumen.Precio * Impuesto.TasaIVA), 2),
		Impuestos = ROUND ((Resumen.Precio * Impuesto.TasaIVA), 2)
	FROM(SELECT IdBienServicio     = -2020, --INTERESES MORATORIOS
				Comprobante.IdImpuesto,
				Precio             = SUM (InteresMoratorio),
				PrecioConImpuestos = SUM (InteresMoratorio) + SUM (IVAInteresMoratorio),
				Impuestos          = SUM (IVAInteresMoratorio)			   
		 FROM dbo.tFELfacturaGlobalIngresos Comprobante
		 WHERE InteresMoratorio > 0 
		 GROUP BY Comprobante.IdImpuesto
		 UNION
		 SELECT IdBienServicio     = -2019, --INTERESES ORDINARIOS
		 	    IdImpuesto		   = IdImpuesto,
		 	    Precio             = SUM (InteresOrdinario),
		 	    PrecioConImpuestos = SUM (InteresOrdinario) + SUM (IVAInteresOrdinario),
		 	    Impuestos          = SUM (IVAInteresOrdinario)
		 FROM dbo.tFELfacturaGlobalIngresos
		 WHERE InteresOrdinario > 0
		 GROUP BY IdImpuesto
		 UNION
		 SELECT IdBienServicio, --CARGOS
		 	    IdImpuesto		   = IdImpuesto,
		 	    Precio             = SUM (CargosPagados),
		 	    PrecioConImpuestos = SUM (CargosPagados) + SUM (IVACargosPagado),
		 	    Impuestos          = SUM (IVACargosPagado)
		 FROM dbo.tFELfacturaGlobalIngresos
		 WHERE CargosPagados > 0
		 GROUP BY IdBienServicio, IdImpuesto
		 UNION
		 SELECT  IdBienServicio, -- VENTAS
		 		IdImpuesto, 
		 		Precio				= SUM (Subtotal), 
		 		PrecioConImpuestos  = SUM (Subtotal) + SUM (IVAVenta), 
		 		Impuestos			= SUM (IVAVenta)
		 FROM dbo.tFELfacturaGlobalIngresos
		 WHERE Subtotal > 0
		 GROUP BY IdBienServicio, IdImpuesto) AS Resumen
INNER JOIN dbo.tGRLbienesServicios Bien ON Bien.IdBienServicio = Resumen.IdBienServicio
INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Resumen.IdImpuesto;

GO


