
SELECT *
--	UPDATE SalarioAnterior SET SalarioAnterior.FechaFin = '2025-04-30'
FROM dbo.tNOMempleadosSalarios SalarioAnterior
INNER JOIN dbo.vPERempleados empleado ON empleado.IdEmpleado = SalarioAnterior.IdEmpleado
INNER JOIN ##Salarios SalarioNuevo ON empleado.Codigo COLLATE DATABASE_DEFAULT = SalarioNuevo.Codigo 
WHERE SalarioAnterior.FechaFin = '1900-01-01' AND SalarioAnterior.IdEmpresaNomina <> 3 
	

INSERT INTO dbo.tNOMempleadosSalarios (IdEmpresaNomina, IdEmpleado, FechaInicio, FechaFin, SalarioDiario, BaseCotizar, SDI )
SELECT SalarioAnterior.IdEmpresaNomina, empleado.IdEmpleado, FechaInicio = '2025-05-01', FechaFin = '1900-01-01', Salario.sd, BaseCotizar = ROUND(ISNULL(Salario.sdi, 0), 2), SDI = ROUND(ISNULL(Salario.sdi, 0), 2)
FROM dbo.tNOMempleadosSalarios SalarioAnterior
INNER JOIN dbo.vPERempleados empleado ON empleado.IdEmpleado = SalarioAnterior.IdEmpleado
INNER JOIN ##Salarios Salario ON empleado.Codigo COLLATE DATABASE_DEFAULT = Salario.Codigo 
WHERE SalarioAnterior.FechaFin = '2025-04-30' AND SalarioAnterior.IdEmpresaNomina <> 3


