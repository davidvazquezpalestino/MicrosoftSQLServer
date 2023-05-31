IF OBJECT_ID ('tempdb..#INDICES') IS NOT NULL
    DROP TABLE #INDICES ;

CREATE TABLE #INDICES
( [BD] NVARCHAR(128) NOT NULL,
  [INDICETIPO] NVARCHAR(60) NOT NULL,
  [FRAGMENTACION] FLOAT(8) NOT NULL,
  [INDICE] NVARCHAR(128) NOT NULL,
  [TABLA] NVARCHAR(128) NOT NULL ) ;
INSERT INTO #INDICES( BD, INDICETIPO, FRAGMENTACION, INDICE, TABLA )
SELECT DBS.name BASEDEDATOS,
       PS.index_type_desc,
       PS.avg_fragmentation_in_percent,
       IND.name INDICE,
       TAB.name TABLA
  FROM sys.dm_db_index_physical_stats (DB_ID (), NULL, NULL, NULL, NULL) PS
 INNER JOIN sys.databases DBS ON PS.database_id = DBS.database_id
 INNER JOIN sys.indexes IND ON PS.object_id = IND.object_id
 INNER JOIN sys.tables TAB ON TAB.object_id = IND.object_id
 WHERE IND.name IS NOT NULL AND PS.index_id = IND.index_id AND PS.avg_fragmentation_in_percent > 0 ;

SELECT DISTINCT CASE WHEN FRAGMENTACION > 5 AND FRAGMENTACION <= 30 THEN 'ALTER INDEX [' + INDICE + '] ON ' + TABLA + ' REORGANIZE'
                     WHEN FRAGMENTACION > 30 THEN 'ALTER INDEX [' + INDICE + '] ON ' + TABLA + ' REBUILD' ELSE NULL
                END QUERY,
                FRAGMENTACION,
                BD,
                INDICE,
                TABLA
  FROM( SELECT FRAGMENTACION,
               INDICE,
               TABLA,
               BD
          FROM #INDICES
         WHERE FRAGMENTACION > 5 ) A
 ORDER BY FRAGMENTACION DESC ;




