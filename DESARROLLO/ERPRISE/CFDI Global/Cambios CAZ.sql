IF NOT EXISTS(SELECT 1 FROM sys.columns c WHERE c.name ='IdComplemento' AND c.object_id = object_id ('tIMPcomprobantesFiscalesD'))
BEGIN
	ALTER TABLE dbo.tIMPcomprobantesFiscalesD ADD IdComplemento INT NOT NULL DEFAULT 0
END

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  09/07/2020
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vInformacionCFDiConceptos'))
	DROP VIEW dbo.vInformacionCFDiConceptos
GO

CREATE VIEW [dbo].[vInformacionCFDiConceptos]
	AS
SELECT Concepto.IdComprobanteD,
	   Concepto.IdComplemento,
	   Concepto.Cantidad,
       Concepto.UDM AS unidad,
       Concepto.Codigo AS noIdentificacion,
       Concepto.Descripcion,
       Concepto.PrecioUnitario AS valorUnitario,
       Concepto.Importe,
	   Concepto.Subtotal,
       Concepto.IdComprobante AS id_fac,
       Concepto.IVA AS monto_iva,
       0 AS monto_iva_bse,
       0 AS tasa,
       0 AS Propina,
       Concepto.IdComprobanteDOrigen AS id_part_pad,
       Concepto.IdComprobanteD AS IdPartida,
       Concepto.Notas,
       Concepto.NumeroIdentificacion,
       Concepto.MontoDescuento,
       ClaveProductoServicio = IIF(Comprobante.RFCEmisor = 'XAXX010101000', '01010101', ProductoServicio.ClaveProductoServicio),
       ClaveUnidad = IIF(Comprobante.RFCEmisor = 'XAXX010101000','ACT', unidadMedida.ClaveUnidad),

	   ProductoServicioDescripcion = CONCAT(ProductoServicio.ClaveProductoServicio, ' - ', ProductoServicio.Descripcion),
	   ClaveUnidadDescripcion = CONCAT(unidadMedida.ClaveUnidad, ' - ', unidadMedida.Nombre)

FROM tIMPcomprobantesFiscalesD Concepto  WITH (NOLOCK) 
INNER JOIN dbo.tIMPcomprobantesFiscales Comprobante WITH(NOLOCK) ON Comprobante.IdComprobante = Concepto.IdComprobante
LEFT JOIN dbo.tSATproductosServicios ProductoServicio ON ProductoServicio.IdSATproductoServicio = Concepto.IdProductoServicio
LEFT JOIN dbo.tSATunidadesMedida unidadMedida ON Concepto.IdUnidadMedida = unidadMedida.IdSATunidadMedida


GO




--[pLSTdatosConceptos]------------------------------------------------------------------------------------------------------------------------
ALTER PROC [dbo].[pLSTdatosConceptos]
@TipoOperacion AS varchar(10) = 'LST',
@IdFactura AS INT=0,
@IdPartida AS INT=0
AS
    IF @TipoOperacion='LST'
    BEGIN 
        SELECT IdComprobanteD, IdComplemento, cantidad, unidad, noIdentificacion, descripcion, valorUnitario, importe,
	       id_fac, monto_iva, monto_iva_bse, tasa,Propina,[IdPartida],Notas, NumeroIdentificacion, MontoDescuento, ClaveProductoServicio, ClaveUnidad
	    FROM vInformacionCFDiConceptos 
		WHERE id_fac=@IdFactura
    END 

    IF @TipoOperacion='LSTPART'
    BEGIN
        SELECT IdComprobanteD,IdComplemento, cantidad, unidad, noIdentificacion, descripcion, valorUnitario, importe,
	       id_fac, monto_iva, monto_iva_bse, tasa,Propina,[id_part_pad],[IdPartida], Notas, MontoDescuento, ClaveProductoServicio, ClaveUnidad
	    FROM vInformacionCFDiConceptos 
		WHERE [id_part_pad]=@IdPartida AND id_part_pad!=0
    END

GO
/*FIX*/



DECLARE @IdComprobante INT = 42095 ;

UPDATE hh
SET hh.Importe = ROUND(Base * TasaCuota, 2)
FROM dbo.tFELdetalleImpuesto hh
WHERE IdComprobante = @IdComprobante AND Importe <> ROUND(Base * TasaCuota, 2) ;


UPDATE imp
SET imp.Impuesto = x.Importe
FROM dbo.tIMPimpuestosComprobantes imp
INNER JOIN (SELECT imp.IdImpuestoComprobante,
                   imp.TipoFactor,
                   imp.TasaCuota,
                   Impuesto = SUM(imp.Impuesto),
                   Importe = SUM(det.Importe)
            FROM dbo.tIMPimpuestosComprobantes imp
            INNER JOIN dbo.tFELdetalleImpuesto det ON det.IdComprobante = imp.IdComprobante AND det.TipoFactor = imp.TipoFactor AND det.TasaCuota = imp.TasaCuota
            WHERE det.IdComprobante = @IdComprobante
            GROUP BY imp.IdImpuestoComprobante,
                     imp.TipoFactor,
                     imp.TasaCuota) AS x ON x.IdImpuestoComprobante = imp.IdImpuestoComprobante
WHERE imp.IdComprobante = @IdComprobante AND imp.Impuesto <> x.Importe ;

UPDATE com
SET com.ImpuestosTrasladados = imp.Impuesto
FROM dbo.tIMPcomprobantesFiscales com
INNER JOIN dbo.tIMPimpuestosComprobantes imp ON imp.IdComprobante = com.IdComprobante
WHERE imp.IdComprobante = @IdComprobante AND imp.TasaCuota = .16 ;


UPDATE com
SET com.Total = com.Subtotal + com.ImpuestosTrasladados
FROM dbo.tIMPcomprobantesFiscales com
INNER JOIN dbo.tIMPimpuestosComprobantes imp ON imp.IdComprobante = com.IdComprobante
WHERE imp.IdComprobante = @IdComprobante AND imp.TasaCuota = .16 ;
