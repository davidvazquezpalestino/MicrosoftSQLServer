SELECT Eje.IdEjercicio,
    Per.IdPeriodo,
    UPVT.Periodo,
    UPVT.INPC
FROM ( SELECT [EJERCICIO],
           [ENERO],
           [FEBRERO],
           [MARZO],
           [ABRIL],
           [MAYO],
           [JUNIO],
           [JULIO],
           [AGOSTO],
           [SEPTIEMBRE],
           [OCTUBRE],
           [NOVIEMBRE],
           [DICIEMBRE]
       FROM ##INPC ) P
    UNPIVOT ( INPC
              FOR Periodo IN ( [ENERO], [FEBRERO], [MARZO], [ABRIL], [MAYO], [JUNIO], [JULIO], [AGOSTO], [SEPTIEMBRE], [OCTUBRE], [NOVIEMBRE], [DICIEMBRE] )) AS UPVT
INNER JOIN dbo.tCTLejercicios Eje ON Eje.Codigo = Ejercicio
INNER JOIN dbo.tCTLperiodos Per ON Per.IdEjercicio = Eje.IdEjercicio AND Per.Descripcion = UPVT.Periodo;
