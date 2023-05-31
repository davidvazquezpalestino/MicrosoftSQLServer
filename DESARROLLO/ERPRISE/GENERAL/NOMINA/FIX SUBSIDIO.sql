SELECT IdCalculoE, *
FROM dbo.tNOMnominas
WHERE IdEstatus = 1 AND  idnomina IN (511)




SELECT s.*
-- UPDATE cal SET cal.SD = s.SalarioDiario, cal.SDI = s.SDI, cal.SBC = s.BaseCotizar
FROM dbo.tNOMcalculosEmpleados cal
INNER JOIN dbo.vPERempleados emp ON emp.IdEmpleado = cal.IdEmpleado
INNER JOIN dbo.tNOMempleadosSalarios s ON s.IdEmpleado = cal.IdEmpleado
WHERE cal.IdCalculoE IN (504) AND s.FechaFin = '19000101' AND cal.SD = 0;


SELECT xx.*
-- UPDATE cal SET cal.SubsidioCausado = [PERC# EXENTA]
FROM dbo.tNOMcalculosEmpleados cal
INNER JOIN dbo.vPERempleados emp ON emp.IdEmpleado = cal.IdEmpleado
INNER JOIN ##Subsidio xx ON Empleado = emp.Codigo
WHERE IdCalculoE IN (504) AND Concepto = 'SUBCAUSADO';

SELECT Subsidio.*,
       cal.*
-- UPDATE Subsidio SET Subsidio.SubsidioCausado = cal.SubsidioCausado
FROM dbo.tFELcomplementosNomina Complemento WITH( NOLOCK )
INNER JOIN dbo.tNOMnominas nomina ON nomina.IdNomina = Complemento.IdNomina
INNER JOIN dbo.tNOMcalculosEmpleados cal ON cal.IdCalculoE = nomina.IdCalculoE AND cal.IdEmpleado = Complemento.IdEmpleado
INNER JOIN dbo.tFELotrosPagos otro ON otro.IdComplementoNomina = Complemento.IdComplementoNomina
INNER JOIN dbo.tFELsubsidioAlEmpleo Subsidio ON Subsidio.IdOtroPago = otro.IdOtroPago
WHERE nomina.IdCalculoE IN (504) AND cal.SubsidioCausado <> 0;


SELECT Complemento.SalarioDiario,
       Complemento.SalarioDiarioIntegrado,
       Complemento.SalarioBaseCotApor,
       cal.*
-- UPDATE Complemento SET Complemento.SalarioDiario = cal.SD, Complemento.SalarioDiarioIntegrado = cal.SDI, Complemento.SalarioBaseCotApor = cal.SBC
FROM dbo.tFELcomplementosNomina Complemento WITH( NOLOCK )
INNER JOIN dbo.tNOMnominas nomina ON nomina.IdNomina = Complemento.IdNomina
INNER JOIN dbo.tNOMcalculosEmpleados cal ON cal.IdCalculoE = nomina.IdCalculoE AND cal.IdEmpleado = Complemento.IdEmpleado
WHERE nomina.IdNomina IN (511) AND Complemento.SalarioDiario = 0;



