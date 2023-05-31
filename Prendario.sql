SELECT OperacionPadre.Folio,
       c.IdCuenta,
       act.IdActivo,
       c.Cuenta,
       c.Socio,
       c.Nombre,
       b.FechaAdjudicacion,
       act.DescripcionLarga,
       Detalle.IdOperacionD,
       TipoOperacion.Descripcion
FROM dbo.vAYCcuentaBasica c WITH(NOLOCK)
INNER JOIN dbo.tACTbienesAdjudicados b WITH(NOLOCK) ON b.IdCuenta = c.IdCuenta
INNER JOIN dbo.tACTactivos act WITH(NOLOCK) ON act.IdActivo = b.IdActivo
INNER JOIN dbo.tALMtransacciones tra WITH(NOLOCK) ON tra.IdActivo = b.IdActivo
LEFT JOIN dbo.tGRLoperacionesD Detalle WITH(NOLOCK) ON Detalle.IdActivo = tra.IdActivo
LEFT JOIN dbo.tCTLtiposOperacion TipoOperacion WITH(NOLOCK) ON TipoOperacion.IdTipoOperacion = Detalle.IdTipoSubOperacion
LEFT JOIN dbo.tGRLoperaciones Operacion WITH(NOLOCK) ON Operacion.IdOperacion = Detalle.RelOperacionD
LEFT JOIN dbo.tGRLoperaciones OperacionPadre WITH(NOLOCK) ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
WHERE c.Cuenta IN ( '00000067016', '00000083853', '40400015805', '40400020350', '40400021798', '40400027482',
                    '40400049228', '40400055986', '40400055987', '40400202795', '40400217245', '40400274864',
                    '40400288631', '40400291734', '40400319727', '40400320817', '00000064526' )
ORDER BY Detalle.IdTipoSubOperacion


