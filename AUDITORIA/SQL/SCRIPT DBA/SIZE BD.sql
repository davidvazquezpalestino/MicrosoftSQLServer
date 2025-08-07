SELECT [BaseDatos] = DB_NAME (),
       [TipoArchivo] = CASE f.type_desc WHEN 'ROWS' THEN
                                            'DATOS'
                                        WHEN 'LOG' THEN
                                            'LOG'
                                        ELSE
                                            f.type_desc
                       END,
       [NombreLogico] = f.name,
       [RutaFisica] = f.physical_name,
       [EspacioUsadoMegabytes] = CAST (FILEPROPERTY ( f.name, 'SpaceUsed' ) * 8.0 / 1024 AS DECIMAL(18, 2)),
       [EspacioUsadoGigabytes] = CAST (FILEPROPERTY ( f.name, 'SpaceUsed' ) * 8.0 / 1024 / 1024 AS DECIMAL(18, 2))
FROM sys.database_files AS f
ORDER BY CASE f.type_desc WHEN 'ROWS' THEN
                              1
                          WHEN 'LOG' THEN
                              2
                          ELSE
                              3
         END,
         f.name;