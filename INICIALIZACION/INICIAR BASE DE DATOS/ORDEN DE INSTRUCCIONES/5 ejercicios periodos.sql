USE iERP_G360;

GO	

/*EJERCICIOS Y PERIODOS*/
PRINT 'EJERCICIOS Y PERIODOS REGISTRADOS'
BEGIN
	DECLARE @ini    AS INT = 2022
	DECLARE @act    AS INT = 2100;
	DECLARE @fin    AS INT = @act;
	DECLARE @count  AS INT = @ini;
	DECLARE @inicio AS DATE;

	
	WHILE @count <= @fin
	BEGIN
		--agregamos el ejericio
		SET IDENTITY_INSERT tCTLejercicios ON;
		INSERT INTO tCTLejercicios(IdEjercicio, [Codigo],[Descripcion],[TotalPeriodos],[Inicio],[Fin])
		VALUES (@count ,CONCAT(@count,''), CONCAT(@count,''), 13, DATEFROMPARTS(@count, 1, 1),DATEFROMPARTS(@count, 12, 31) );

		SET @inicio =  DATEFROMPARTS(@count, 1, 1);
	
		-- agregamos los periodos para el ejercicio
		INSERT INTO dbo.tctlperiodos (idejercicio, codigo, descripcion, numero, inicio, fin, esAjuste)	
	
		SELECT (SELECT idejercicio FROM tCTLejercicios WHERE Codigo = CONCAT(@count,'') ), codigo, descripcion, numero, inicio, fin, esAjuste
		FROM ( VALUES 																															
				(concat (@count, '-01'), 'ENERO',	  1,				 @inicio,	DATEADD(DAY, -1, DATEADD(MONTH,1,@inicio)),  0 ),
				(concat (@count, '-02'), 'FEBRERO',	  2, DATEADD(MONTH,1, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,2,@inicio)),  0 ),
				(concat (@count, '-03'), 'MARZO',	  3, DATEADD(MONTH,2, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,3,@inicio)),  0 ),
				(concat (@count, '-04'), 'ABRIL',	  4, DATEADD(MONTH,3, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,4,@inicio)),  0 ),
				(concat (@count, '-05'), 'MAYO',	  5, DATEADD(MONTH,4, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,5,@inicio)),  0 ),
				(concat (@count, '-06'), 'JUNIO',	  6, DATEADD(MONTH,5, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,6,@inicio)),  0 ),
				(concat (@count, '-07'), 'JULIO',	  7, DATEADD(MONTH,6, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,7,@inicio)),  0 ),
				(concat (@count, '-08'), 'AGOSTO',	  8, DATEADD(MONTH,7, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,8,@inicio)),  0 ),
				(concat (@count, '-09'), 'SEPTIEMBRE',9, DATEADD(MONTH,8, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,9,@inicio)),  0 ),
				(concat (@count, '-10'), 'OCTUBRE',	  10,DATEADD(MONTH,9, @inicio),	DATEADD(DAY, -1, DATEADD(MONTH,10,@inicio)), 0 ),
				(concat (@count, '-11'), 'NOVIEMBRE', 11,DATEADD(MONTH,10,@inicio),	DATEADD(DAY, -1, DATEADD(MONTH,11,@inicio)), 0 ),
				(concat (@count, '-12'), 'DICIEMBRE', 12,DATEADD(MONTH,11,@inicio),	DATEADD(DAY, -1, DATEADD(MONTH,12,@inicio)), 0 ),
				(concat (@count, '-13'), 'AJUSTE',	  13,				 @inicio,	DATEADD(DAY, -1, DATEADD(MONTH,12,@inicio)), 1 )) AS periodos (codigo, descripcion, numero, inicio, fin, esAjuste)
	
	
		SET @count = @count + 1	
	END


	INSERT INTO tCTLestatusActual (IdEstatus, IdTipoDDominio, IdControl)
	SELECT  CASE WHEN YEAR(p.Codigo) < YEAR(CURRENT_TIMESTAMP) THEN 35 -- historico antes del actual
				 WHEN YEAR(p.Codigo) = YEAR(CURRENT_TIMESTAMP) THEN 6  -- precierre
				 WHEN YEAR(p.Codigo) > YEAR(CURRENT_TIMESTAMP) THEN 36 -- activo solo el ejercicio actual
				 ELSE 3
			END,  
		IdTipoDDominio = 242, 
		IdControl = IdEjercicio
	FROM tCTLejercicios p
	WHERE  p.IdEjercicio <> 0
	AND NOT EXISTS (SELECT idestatus 
					FROM tCTLestatusActual tca 
					WHERE tca.IdControl = p.IdEjercicio AND tca.IdTipoDDominio = 242)
                                                  
	  UPDATE tc SET IdEstatusActual = tca.IdEstatusActual
	  FROM tCTLejercicios tc
	  INNER JOIN tCTLestatusActual tca ON tc.IdEjercicio = tca.IdControl AND tca.IdTipoDDominio = 242
	  WHERE tc.IdEjercicio <> 0
 
	 UPDATE p SET trimestre = CASE	WHEN Numero IN(1,2,3) THEN 1
									WHEN Numero IN(4,5,6) THEN 2
									WHEN Numero IN(7,8,9) THEN 3
									WHEN Numero IN(10,11,12) THEN 4
									ELSE 0
							  END
	FROM dbo.tCTLperiodos p
	WHERE IdPeriodo > 0

	UPDATE p SET Dias = DATEDIFF(DAY, p.Inicio, p.Fin) + 1
	FROM dbo.tCTLejercicios p WITH (NOLOCK)
	WHERE p.IdEjercicio > 0

 
 END 
 SET IDENTITY_INSERT tCTLejercicios OFF;



 