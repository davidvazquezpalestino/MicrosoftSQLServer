DECLARE @IdTipoE AS INT  = 149;

select CONCAT('En',REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Descripcion,' ',''),'�','a'),'�','e'),'�','i'),'�','o'),'�','u'))
from tCTLtiposE
WHERE IdTipoE = @IdTipoE

SELECT  enumerador = CONCAT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Descripcion,' de ',''),' ',''),'�','a'),'�','e'),'�','i'),'�','o'),'�','u'),' = ', IdTipoD)
FROM tCTLtiposD
WHERE IdEstatus=1 and IdTipoE = @IdTipoE
ORDER BY IdTipoD

