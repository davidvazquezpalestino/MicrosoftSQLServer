SELECT Periodo = Periodo.Codigo,
       PercepcionesDeducciones = CASE WHEN PercepcionDeduccion.EsPercepcion = 1 THEN 'PERCEPCIONES'
                                      WHEN PercepcionDeduccion.EsPercepcion = 0 THEN 'DEDUCCIONES'
                                      WHEN PercepcionesDeducciones.IdTipoDaplicacion = -1524 THEN 'OBLIGACIONES'
                                      ELSE NULL
                                 END,
       PercepcionDeduccion = PercepcionesDeducciones.Descripcion,
       PercepcionDeduccion.Concepto,
       Importe = PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento + ISNULL(PercepcionDeduccion.Otros, 0),
       Empleado.Nombre
FROM dbo.tNOMnominas Nomina
INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = Nomina.IdOperacion
INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = Operacion.IdPeriodo
INNER JOIN dbo.tNOMnominasEmpleados NominaEmpleado ON NominaEmpleado.IdNomina = Nomina.IdNomina
INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion ON PercepcionDeduccion.RelNominaEmpleado = NominaEmpleado.IdNominaEmpleado
INNER JOIN dbo.tGRLbienesServicios PercepcionesDeducciones ON PercepcionesDeducciones.IdBienServicio = PercepcionDeduccion.IdBienServicio
INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
WHERE Nomina.IdEstatus = 1
ORDER BY PercepcionDeduccion.IdBienServicio ;

