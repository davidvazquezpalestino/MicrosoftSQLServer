DECLARE @IdRecurso INT = 824;
--Desde el nivel inferior al superior;
WITH Recursos
AS (   SELECT IdRecurso,
              Descripcion,
              IdRecursoPadre,
              Partida = 1,
              IdModulo,
              Orden,
              Jerarquia
       FROM dbo.tCTLrecursos
       WHERE IdEstatus = 1 AND IdRecurso = @IdRecurso
       UNION ALL
       -- Aquí va la recursividad
       SELECT Recurso.IdRecurso,
              Recurso.Descripcion,
              Recurso.IdRecursoPadre,
              BuscaRecurso.Partida + 1,
              Recurso.IdModulo,
              Recurso.Orden,
              Recurso.Jerarquia
       FROM dbo.tCTLrecursos AS Recurso
       INNER JOIN Recursos AS BuscaRecurso ON Recurso.IdRecursoPadre = BuscaRecurso.IdRecurso
       WHERE BuscaRecurso.IdRecurso > 0 AND Recurso.IdEstatus = 1)
SELECT r.IdRecursoPadre,
       r.IdRecurso,
       r.Orden,
       Arbol = CONCAT (SPACE (r.Partida * 3), '+  ', r.Descripcion)
FROM Recursos r
INNER JOIN dbo.tCTLrecursos Recurso ON Recurso.IdRecurso = r.IdRecurso
WHERE r.IdRecurso > 0
ORDER BY r.Jerarquia.GetLevel ();


