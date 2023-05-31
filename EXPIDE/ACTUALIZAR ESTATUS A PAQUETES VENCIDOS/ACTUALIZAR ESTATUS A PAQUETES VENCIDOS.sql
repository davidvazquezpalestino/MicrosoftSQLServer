USE ServiciosIntelix;

DECLARE @Fecha AS DATE = CURRENT_TIMESTAMP

SELECT  QUERY = 'UPDATE tVENclientesPaquetesFolios SET IdEstatus = 5 WHERE IdClientePaqueteFolios = ' + CONCAT(IdClientePaqueteFolios, '') + ' ',
		IdClientePaqueteFolios,
	    Timbres, 
		TimbresDisponibles,
		FinVigencia	
FROM tVENclientesPaquetesFolios WITH (NOLOCK)
WHERE FinVigencia < @Fecha AND IdEstatus = 1

