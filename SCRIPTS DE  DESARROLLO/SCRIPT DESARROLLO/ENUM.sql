DECLARE @IdTipoE AS INT  = 149;

select CONCAT('En',REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Descripcion,' ',''),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'))
from tCTLtiposE
WHERE IdTipoE = @IdTipoE

SELECT  enumerador = CONCAT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Descripcion,' de ',''),' ',''),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),' = ', IdTipoD)
FROM tCTLtiposD
WHERE IdEstatus=1 and IdTipoE = @IdTipoE
ORDER BY IdTipoD

