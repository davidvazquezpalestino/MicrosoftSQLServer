DECLARE @IdRFCemisor as integer = 4529;

SELECT	*
FROM tCTLusuarios
WHERE IdCliente = (SELECT IdCliente 
						FROM tFELRFCs WHERE IdRFC = @IdRFCemisor)