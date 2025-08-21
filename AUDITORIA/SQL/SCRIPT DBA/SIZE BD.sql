SELECT DatabaseName = DB_NAME (),
       FileType = CASE f.type_desc WHEN 'ROWS' THEN
                                       'DATA'
                                   WHEN 'LOG' THEN
                                       'LOG'
                                   ELSE
                                       f.type_desc
                  END,
       LogicalFileName = f.name,
       PhysicalFilePath = f.physical_name,
       Megabytes = CAST (FILEPROPERTY ( f.name, 'SpaceUsed' ) * 8.0 / 1024 AS DECIMAL(18, 2)),
       Gigabytes = CAST (FILEPROPERTY ( f.name, 'SpaceUsed' ) * 8.0 / 1024 / 1024 AS DECIMAL(18, 2))
FROM sys.database_files AS f
ORDER BY CASE f.type_desc WHEN 'ROWS' THEN
                              1
                          WHEN 'LOG' THEN
                              2
                          ELSE
                              3
         END,
         f.name;