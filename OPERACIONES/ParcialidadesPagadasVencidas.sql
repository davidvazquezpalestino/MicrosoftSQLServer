DECLARE @IdPeriodo INT 
DECLARE @Fin DATE

SELECT @IdPeriodo = IdPeriodo, @Fin = Fin FROM dbo.tCTLperiodos WHERE Codigo = '2018-05'; 
SELECT  Periodo.IdPeriodo,
		Parcialidad.IdCuenta,
		
		Parcialidad.ParcialidadesPagadas,  
        Historial.ParcialidadesPagadas,

		Parcialidad.ParcialidadesVencidas,
		Historial.PagosVencidos,
		
		Historial.IdEstatus	,
		Cuenta.IdEstatus
--UPDATE Historial SET Historial.ParcialidadesPagadas = Parcialidad.ParcialidadesPagadas					 
FROM dbo.tAYCcuentas Cuenta WITH(NOLOCK)
INNER JOIN dbo.tSDOhistorialDeudoras Historial WITH (NOLOCK) ON Historial.IdCuenta = Cuenta.IdCuenta
INNER JOIN dbo.tCTLperiodos      Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = Historial.IdPeriodo 
INNER JOIN (SELECT Parcialidad.IdCuenta,
				   ParcialidadesPagadas  = SUM(CASE WHEN (parcialidad.CapitalPagado + parcialidad.CapitalCondonado) >= parcialidad.Capital AND parcialidad.Capital != 0 THEN 1 ELSE 0 END),
				   ParcialidadesVencidas = SUM(CASE WHEN (parcialidad.Capital - (parcialidad.CapitalPagado + parcialidad.CapitalCondonado)) > 0 AND Parcialidad.Vencimiento < @Fin THEN 1 ELSE 0 END)				  
			FROM dbo.tRESparcialidades20180531 Parcialidad
			WHERE Parcialidad.IdEstatus = 1 
			GROUP BY Parcialidad.IdCuenta
        ) AS Parcialidad ON Parcialidad.IdCuenta = Historial.IdCuenta
WHERE Historial.IdEstatus = 1 AND Periodo.IdPeriodo = @IdPeriodo AND Historial.ParcialidadesPagadas <> Parcialidad.ParcialidadesPagadas
