DECLARE @IdNomina INT = 471;

BEGIN TRANSACTION;

UPDATE n
SET n.IdEstatus = 18
FROM dbo.tNOMnominas n
WHERE IdNomina = @IdNomina;

UPDATE x
SET x.IdEstatus = 18
FROM dbo.tNOMnominasEmpleados x WITH( NOLOCK )
WHERE IdNomina = @IdNomina;

UPDATE CalculoE
SET CalculoE.IdEstatus = 18
FROM dbo.tNOMnominas Nomina WITH( NOLOCK )
INNER JOIN dbo.tNOMcalculosE CalculoE WITH( NOLOCK )ON Nomina.IdCalculoE = CalculoE.IdCalculoE
WHERE Nomina.IdNomina = @IdNomina;

UPDATE Calculo
SET Calculo.IdEstatus = 18
FROM dbo.tNOMnominas Nomina WITH( NOLOCK )
INNER JOIN dbo.tNOMcalculosE CalculoE WITH( NOLOCK )ON Nomina.IdCalculoE = CalculoE.IdCalculoE
INNER JOIN dbo.tNOMcalculos Calculo WITH( NOLOCK )ON Calculo.IdCalculoE = CalculoE.IdCalculoE
WHERE Nomina.IdNomina = @IdNomina;

UPDATE Comprobante SET Comprobante.IdEstatus = 18
FROM dbo.tIMPcomprobantesFiscales Comprobante
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdComprobante = Comprobante.IdComprobante
WHERE Complemento.IdNomina = @IdNomina;


--COMMIT TRANSACTION 


--ROLLBACK TRANSACTION 

