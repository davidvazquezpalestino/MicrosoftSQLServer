DECLARE @Hoy AS date = getdate();

SELECT *
FROM dbo.tmpExcepciones WITH(NOLOCK)
WHERE cast (Fecha as DATE) = @Hoy --AND Excepcion LIKE '%login%'
ORDER BY Fecha DESC

