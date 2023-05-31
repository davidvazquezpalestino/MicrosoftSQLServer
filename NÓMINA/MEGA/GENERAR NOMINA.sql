
/*====================================================================================
	2.- SE REGISTRA LA RELACION DE PERCEPCIONES DEDUCCIONES A LAS NÓMINAS RELACIONADAS.
===================================================================================== */
INSERT INTO dbo.tNOMnominasPercepcionesDeducciones ( IdNomina, IdEmpleado, IdEmpresaNomina, IdBienServicio, EsPercepcion, PercepcionDeduccion, Concepto, IdTipoDpercepcionDeduccion, ImporteGravado, ImporteExento, Importe, Otros, IdCuentaABCD, IdAuxiliar, IdDivision, Orden )
SELECT Nomina.IdNomina,
       Calculo.IdEmpleado,
       CalculoE.IdEmpresaNomina,
       Calculo.IdBienServicio,
       BienServicio.EsPercepcion,
       BienServicio.Codigo,
       BienServicio.Descripcion,
       BienServicio.IdTipoDpercepcionDeduccion,
       Calculo.ImporteGravado,
       Calculo.ImporteExento,
       Importe = CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2688 THEN -- DEDUCCIÓN
                           ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                      ELSE 0
                 END,
       --APLICA PARA SUBSIDIO, PRESTAMOS Y VIATICOS
       Otros = CASE WHEN BienServicio.IdTipoDpercepcionDeduccionPago = 2689 THEN -- OTROS PAGOS
                         ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                    ELSE 0
               END,
       BienServicio.IdCuentaABCD,
       BienServicio.IdAuxiliar,
       BienServicio.IdDivision,
       Orden = ROW_NUMBER () OVER ( ORDER BY Calculo.IdEmpleado,
                                             CASE BienServicio.IdTipoDpercepcionDeduccionPago WHEN 2687 THEN -- PERCEPCIÓN
                                                                                                   1
                                                                                              WHEN 2688 THEN -- DEDUCCIÓN
                                                                                                   2
                                                                                              WHEN 2689 THEN -- OTRO PAGO
                                                                                                   3
                                                                                              ELSE 4 -- OTRO
                                             END,
                                             Calculo.IdBienServicio )
FROM dbo.tNOMcalculos Calculo WITH ( NOLOCK )
INNER JOIN dbo.tNOMcalculosE CalculoE WITH ( NOLOCK ) ON CalculoE.IdCalculoE = Calculo.IdCalculoE
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH ( NOLOCK ) ON BienServicio.IdBienServicio = Calculo.IdBienServicio
INNER JOIN dbo.tNOMnominas Nomina WITH ( NOLOCK ) ON Nomina.IdCalculoE = Calculo.IdCalculoE
WHERE BienServicio.IdTipoD = 1452 AND Calculo.IdCalculoE = @IdCalculoE


EXECUTE dbo.pCOMgrabarComprobanteFiscalNomina @IdNomina = @IdNomina; -- int
