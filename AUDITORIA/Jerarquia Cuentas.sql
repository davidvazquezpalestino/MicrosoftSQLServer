DECLARE @Cuenta VARCHAR(50) = '1130000000000';

WITH
cuentasCTE AS (SELECT IdCuentaContable,
                      Orden = 1
               FROM dbo.tCNTcuentas
               WHERE Codigo = @Cuenta
               UNION ALL
               SELECT cuenta.IdCuentaContable,
                      tmp.Orden + 2
               FROM dbo.tCNTcuentas cuenta
               INNER JOIN cuentasCTE tmp ON cuenta.IdCuentaContablePadre = tmp.IdCuentaContable)
SELECT Cuenta.IdCuentaContable,
       Cuenta.IdCuentaContablePadre,
       Codigo = CONCAT (SPACE (tmp.Orden), '+ ', Cuenta.Codigo),
       Descripcion = CONCAT (SPACE (tmp.Orden), '+ ', Cuenta.Descripcion),
       Naturaleza = TipoNaturaleza.Descripcion,
       [Cuenta de Mayor] = IIF(Cuenta.EsMayor = 1, 'SI', 'NO'),
       [Cuenta Afectable] = IIF(Cuenta.EsAfectable = 1, 'SI', 'NO')
FROM cuentasCTE tmp
INNER JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
INNER JOIN dbo.tCTLtiposD TipoNaturaleza ON TipoNaturaleza.IdTipoD = Cuenta.IdTipoDNaturaleza
ORDER BY Cuenta.IdCuentaContable,
         Cuenta.IdCuentaContablePadre;
