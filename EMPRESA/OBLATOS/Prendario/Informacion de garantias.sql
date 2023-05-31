SELECT Bien.*, Variedad.Descripcion, gar.Cantidad, Bien.porcentaje
-- UPDATE bien SET Bien.Informacion = Variedad.Descripcion, Bien.Peso = gar.Cantidad, Bien.porcentaje = Gar.PorcentajePrestado
FROM dbo.tACTbienesAdjudicados Bien
INNER JOIN dbo.tAYCgarantias Gar ON Gar.IdGarantia = Bien.IdGarantia
INNER JOIN dbo.tCATlistasD Variedad ON Variedad.IdListaD = Gar.IdListaDvariedad
WHERE Bien.Informacion IS NULL

