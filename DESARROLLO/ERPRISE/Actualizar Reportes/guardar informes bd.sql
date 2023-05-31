SELECT  'UPDATE c SET UltimaModificacion = CURRENT_TIMESTAMP, c. Binarios = (SELECT  BulkColumn FROM OPENROWSET (BULK N''C:\ReportesIntelix\'
        + IIF(c.TipoReporte = 'Formatos', 'Formatos', 'Informes') + '\'
        + c.NombreArchivo + ''' , SINGLE_BLOB)as BulkColumn)
FROM tCTLinformesVersion c
WHERE IdInformeVersion = ' + CONCAT(c.IdInformeVersion, '') + '
 ' AS BulkColumn
FROM    tCTLinformesVersion c
WHERE   IdInformeVersion <> 0
     ORDER BY c.IdInformeVersion
GO



