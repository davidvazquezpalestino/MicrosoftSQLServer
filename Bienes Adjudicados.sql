
SELECT *
-- UPDATE Bien SET Bien.Capital = CapitalPagado, Bien.Ordinario = x.InteresOrdinarioPagado, Bien.Moratorio = x.InteresMoratorioPagado
FROM dbo.tACTbienesAdjudicados Bien 
INNER JOIN 
(SELECT a.IdCuenta,
            CapitalPagado = SUM (b.CapitalPagado + b.CapitalPagadoVencido),
            InteresOrdinarioPagado = SUM (b.InteresOrdinarioPagado + b.InteresOrdinarioPagadoVencido),
            InteresMoratorioPagado = SUM (b.InteresMoratorioPagado + b.InteresMoratorioPagadoVencido)
     FROM dbo.tACTbienesAdjudicados a
     INNER JOIN dbo.vSDOtransaccionesFinancierasISNULL b ON b.IdCuenta = a.IdCuenta AND a.FechaAdjudicacion = b.Fecha
     WHERE FechaAdjudicacion > '20200310'
     GROUP BY a.IdCuenta) AS x ON x.IdCuenta = Bien.IdCuenta

