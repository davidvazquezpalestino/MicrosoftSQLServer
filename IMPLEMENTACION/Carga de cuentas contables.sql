BEGIN TRANSACTION;

ALTER TABLE ##CuentasContables
ADD IdCuenta INT NULL,
    IdCuentaPadre INT NULL,
    IdTipo INT NULL,
    IdCuentaSITI INT NULL,
    IdTipoDNaturaleza INT NULL;

ALTER TABLE ##CuentasContables
ADD CONSTRAINT DF_IdCuenta DEFAULT 0 FOR IdCuenta;

ALTER TABLE ##CuentasContables
ADD CONSTRAINT DF_IdCuentaPadre DEFAULT 0 FOR IdCuentaPadre;
GO

DELETE FROM ##CuentasContables
WHERE Cuenta IS NULL;

UPDATE ##CuentasContables
SET Cuenta = REPLACE (Cuenta, '-', '')
WHERE Cuenta IS NOT NULL;

UPDATE ##CuentasContables
SET CuentaPadre = REPLACE (CuentaPadre, '-', '')
WHERE CuentaPadre IS NOT NULL;

UPDATE cuenta
SET IdCuenta = tmp.Id
FROM ##CuentasContables cuenta
INNER JOIN
(SELECT Id = ROW_NUMBER () OVER (ORDER BY Cuenta),
     Cuenta
 FROM ##CuentasContables) tmp ON cuenta.Cuenta = tmp.Cuenta;

UPDATE a
SET IdCuentaPadre = ISNULL (b.IdCuenta, 0),
    a.descripcion = LTRIM (a.Descripcion),
    Nivel = ISNULL (a.Nivel, 0)
FROM ##CuentasContables a
LEFT JOIN ##CuentasContables b ON a.CuentaPadre = b.Cuenta;

UPDATE cta
SET IdTipo = tipo.IdTipoD
FROM ##CuentasContables cta
INNER JOIN dbo.tCTLtiposD tipo ON cta.Tipo = tipo.Descripcion
WHERE tipo.IdTipoE = 14;

UPDATE cta
SET IdTipoDNaturaleza = tipo.IdTipoD
FROM ##CuentasContables cta
INNER JOIN dbo.tCTLtiposD tipo ON cta.Naturaleza = tipo.Descripcion
WHERE tipo.IdTipoE = 22;

UPDATE a
SET a.IdCuentaSITI = b.IdCatalogoSITI
FROM ##CuentasContables a
INNER JOIN dbo.tSITcatalogos b ON a.CuentaSITI = b.Clave
WHERE b.IdTipoE = 222;

IF EXISTS
(SELECT 1
 FROM ##CuentasContables
 WHERE IdCuentaPadre = 0 AND CuentaPadre <> '')
BEGIN
    SELECT *
    FROM ##CuentasContables
    WHERE IdCuentaPadre = 0 AND CuentaPadre <> '';

    ROLLBACK;

    RETURN;
END;

ALTER TABLE dbo.tCNTcuentas NOCHECK CONSTRAINT ALL;

SET IDENTITY_INSERT dbo.tCNTcuentas ON;

INSERT INTO dbo.tCNTcuentas (IdCuentaContable, Codigo, Descripcion, IdCuentaContablePadre, IdTipoD, IdTipoDNaturaleza, IdDivisa, EsAfectable, EsMayor, Nivel, IdCatalogoSITI)
SELECT IdCuenta,
    Cuenta = CAST(Cuenta AS BIGINT),
    Descripcion,
    IdCuentaPadre,
    ISNULL (IdTipo, 0),
    IdTipoDNaturaleza,
    IdDivisa = 1,
    EsAfectable = IIF(ISNULL (EsMayor, 0) = 1, 0, 1),
    EsMayor = ISNULL (EsMayor, 0),
    Nivel = ISNULL (Nivel, 0),
    IdCuentaSITI = ISNULL (IdCuentaSITI, 0)
FROM ##CuentasContables;

EXECUTE dbo.pOrganizarCuentas @tipoOperacion = 'OC';

UPDATE c
SET c.Nivel = Jerarquia.GetLevel ()
FROM dbo.tCNTcuentas c
WHERE c.IdCuentaContable <> 0;

SET IDENTITY_INSERT dbo.tCNTcuentas OFF;

ALTER TABLE dbo.tCNTcuentas CHECK CONSTRAINT ALL;

SELECT *
FROM dbo.tCNTcuentas WITH (NOLOCK)
WHERE IdCuentaContablePadre = 0;

SELECT *
FROM dbo.tCNTcuentas WITH (NOLOCK);

--	ROLLBACK TRANSACTION;



