

DECLARE @Idrfcemisor AS integer = 4529

SELECT concat(r.Nombre,' ',r.ApellidoPaterno,' ',r.ApellidoMaterno),
'UPDATE dbo.tFELempleados SET IdTipoDperiodicidad = ' + Cast(IdTipoDperiodicidad AS varchar(20)) +' WHERE IdRFC = ' + Cast(e.IdRFC AS varchar(20)) + ' AND IdRFCemisor = ' + Cast(e.IdRFCemisor AS varchar(20)) + ' '
FROM dbo.tFELRFCs r
INNER JOIN dbo.tFELempleados e
	ON r.IdRFC = e.IdRFC
WHERE r.IdRFCemisor = @Idrfcemisor



