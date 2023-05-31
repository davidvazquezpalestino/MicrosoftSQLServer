
/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  19/02/2019
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFELfacturaGlobalIngresos'))
	DROP VIEW dbo.vFELfacturaGlobalIngresos
GO


CREATE VIEW dbo.vFELfacturaGlobalIngresos
AS
SELECT FacturaGlobal.IdOperacion,
       FacturaGlobal.IdPeriodo,
       FacturaGlobal.IdImpuesto,
       FacturaGlobal.InteresOrdinario,
       FacturaGlobal.IVAInteresOrdinario,
       FacturaGlobal.InteresMoratorio,
       FacturaGlobal.IVAInteresMoratorio,
       FacturaGlobal.CargosPagados,
       FacturaGlobal.IVACargosPagado,
       FacturaGlobal.IdBienServicio,
       FacturaGlobal.Subtotal,
       FacturaGlobal.IVAVenta,
       Concepto = CASE
                      WHEN FacturaGlobal.InteresOrdinario > 0 THEN
                          UPPER(CONCAT('Interés Ordinario', ' ', Impuesto.Descripcion))
                      WHEN FacturaGlobal.InteresMoratorio > 0 THEN
                          UPPER(CONCAT('Interés Moratorio', ' ', Impuesto.Descripcion))
                      WHEN FacturaGlobal.CargosPagados > 0 THEN
                          UPPER(CONCAT(Bien.Descripcion, ' ', Impuesto.Descripcion))
                      ELSE
                          UPPER(CONCAT(Bien.Descripcion, ' ', Impuesto.Descripcion))
                  END,
       Orden    = CASE
                      WHEN FacturaGlobal.InteresOrdinario > 0 THEN
                          1
                      WHEN FacturaGlobal.InteresMoratorio > 0 THEN
                          2
                      WHEN FacturaGlobal.CargosPagados > 0 THEN
                          3
                      WHEN ( InteresOrdinario + InteresMoratorio + CargosPagados ) = 0 THEN
                          4
                      ELSE
                          5
                  END,
       Bien.IdDivision
FROM dbo.tFELfacturaGlobalIngresos FacturaGlobal
INNER JOIN dbo.tIMPimpuestos       Impuesto WITH ( NOLOCK ) ON Impuesto.IdImpuesto = FacturaGlobal.IdImpuesto
INNER JOIN dbo.tGRLbienesServicios Bien WITH ( NOLOCK ) ON Bien.IdBienServicio = FacturaGlobal.IdBienServicio
WHERE FacturaGlobal.IdOperacionFactura = 0


GO


