DECLARE @TABLE_NAME AS NVARCHAR(MAX),
    @COLUMN_NAME    AS NVARCHAR(MAX) ;

	
DECLARE foreach CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
SELECT TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tCNTpolizasD' AND COLUMN_NAME IN ('IdTransaccionImpuesto') ;


SET NOCOUNT ON ;

OPEN foreach ;
FETCH NEXT FROM foreach
INTO @TABLE_NAME,
    @COLUMN_NAME ;
WHILE @@fetch_status = 0
BEGIN


    DECLARE @query AS NVARCHAR(MAX) = ( SELECT TOP( 1 )'IF EXISTS(SELECT * FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID(''' + @TABLE_NAME + ''') AND NAME = ''' + fk.name + ''') ' + CHAR (13) + 'ALTER TABLE ' + @TABLE_NAME + ' DROP CONSTRAINT ' + fk.name + ' '
                                        FROM sys.foreign_keys fk
                                        INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                                        WHERE fk.parent_object_id = OBJECT_ID (@TABLE_NAME) AND COL_NAME (fk.parent_object_id, parent_column_id) = @COLUMN_NAME
                                        ORDER BY fk.name ) ;



    IF @query IS NOT NULL
        EXECUTE sp_executesql @query = @query ;
		

    FETCH NEXT FROM foreach
    INTO @TABLE_NAME,
        @COLUMN_NAME ;
END ;
CLOSE foreach ;
DEALLOCATE foreach ;
