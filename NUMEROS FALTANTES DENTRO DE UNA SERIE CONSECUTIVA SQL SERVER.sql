SELECT IdEstatusActual = T1.IdEstatusActual - 1,
       CONCAT ('SET IDENTITY_INSERT dbo.tCTLestatusActual ON;', CHAR (13), 'INSERT INTO dbo.tCTLestatusActual (IdEstatusActual, IdEstatus, IdTipoDDominio)', CHAR (13), 'SELECT IdEstatusActual = ', T1.IdEstatusActual - 1, ', IdEstatus = 1, ', 'IdTipoDDominio = ', CHAR (13), 'SET IDENTITY_INSERT dbo.tCTLestatusActual OFF;')
FROM dbo.tCTLestatusActual T1
WHERE T1.IdEstatusActual < 0
      AND NOT EXISTS ( SELECT NULL
                       FROM dbo.tCTLestatusActual T2
                       WHERE T2.IdEstatusActual = T1.IdEstatusActual - 1 )
ORDER BY T1.IdEstatusActual;

SELECT IdBienServicio = T1.IdBienServicio - 1,
       CONCAT ('SET IDENTITY_INSERT dbo.tGRLbienesServicios ON;', CHAR (13), 'INSERT INTO dbo.tGRLbienesServicios (IdBienServicio, IdTipoD, Codigo, Descripcion, DescripcionLarga, IdEstatusActual)', CHAR (13), 'SELECT IdBienServicio = ', T1.IdBienServicio - 1, ', IdTipoD = , Codigo, Descripcion, DescripcionLarga, IdEstatusActual = ', CHAR (13), 'SET IDENTITY_INSERT dbo.tGRLbienesServicios OFF;')
FROM dbo.tGRLbienesServicios T1
WHERE T1.IdBienServicio < 0
      AND NOT EXISTS ( SELECT NULL
                       FROM dbo.tGRLbienesServicios T2
                       WHERE T2.IdBienServicio = T1.IdBienServicio - 1 )
ORDER BY T1.IdBienServicio;

