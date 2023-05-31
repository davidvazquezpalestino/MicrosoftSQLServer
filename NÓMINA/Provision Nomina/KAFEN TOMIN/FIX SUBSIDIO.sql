SELECT *
FROM dbo.tNOMnominas
WHERE IdEstatus = 1 AND  IdCalculoE IN (776,778,782)



SELECT *
-- UPDATE cal SET cal.SubsidioCausado = [PERC# EXENTA]
FROM dbo.tNOMcalculosEmpleados cal
INNER JOIN dbo.vPERempleados emp ON emp.IdEmpleado = cal.IdEmpleado
WHERE IdCalculoE IN (776,778,782) AND cal.SubsidioCausado <> 0

SELECT Subsidio.*,
       cal.*
-- UPDATE Subsidio SET Subsidio.SubsidioCausado = cal.SubsidioCausado
FROM dbo.tFELcomplementosNomina Complemento WITH( NOLOCK )
INNER JOIN dbo.tNOMnominas nomina ON nomina.IdNomina = Complemento.IdNomina
INNER JOIN dbo.tNOMcalculosEmpleados cal ON cal.IdCalculoE = nomina.IdCalculoE AND cal.IdEmpleado = Complemento.IdEmpleado
INNER JOIN dbo.tFELotrosPagos otro ON otro.IdComplementoNomina = Complemento.IdComplementoNomina
INNER JOIN dbo.tFELsubsidioAlEmpleo Subsidio ON Subsidio.IdOtroPago = otro.IdOtroPago
WHERE nomina.IdCalculoE IN (776,778,782) AND cal.SubsidioCausado <> 0 AND Complemento.IdEmpleado = 26;


SELECT Complemento.SalarioDiario,
       Complemento.SalarioDiarioIntegrado,
       Complemento.SalarioBaseCotApor,
       cal.*
-- UPDATE Complemento SET Complemento.SalarioDiario = cal.SD, Complemento.SalarioDiarioIntegrado = cal.SDI, Complemento.SalarioBaseCotApor = cal.SBC
FROM dbo.tFELcomplementosNomina Complemento WITH( NOLOCK )
INNER JOIN dbo.tNOMnominas nomina ON nomina.IdNomina = Complemento.IdNomina
INNER JOIN dbo.tNOMcalculosEmpleados cal ON cal.IdCalculoE = nomina.IdCalculoE AND cal.IdEmpleado = Complemento.IdEmpleado
WHERE nomina.IdNomina IN (511) AND Complemento.SalarioDiario = 0;



