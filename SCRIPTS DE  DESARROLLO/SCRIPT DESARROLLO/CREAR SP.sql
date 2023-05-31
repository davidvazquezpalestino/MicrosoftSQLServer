SET NOCOUNT ON;


DECLARE @TableName VARCHAR(100) = 'tFELcomplementoPagos';
DECLARE @Entidad VARCHAR(100) = 'complementoPago';
DECLARE @ProcedimientoAlmacenado VARCHAR(max);
DECLARE @ParametrosConcatenados AS VARCHAR(MAX);
DECLARE @ColumnasConcatenadas AS VARCHAR(MAX);
DECLARE @ColumnasConcatenadasInsert AS VARCHAR(MAX);
DECLARE @ColumnasConcatenadasUpdate AS VARCHAR(MAX);
DECLARE @Id VARCHAR(100)

DECLARE @Parametros AS TABLE
(
   ColumnName VARCHAR(100),
   IsIdentity BIT,
   Orden INT
);

INSERT INTO @Parametros
(
    ColumnName, IsIdentity, Orden
)

SELECT '@Operacion VARCHAR(5) = NULL' AS Parametro,IsIdentity = 0, Orden = 0
UNION
SELECT 
Parametro = CONCAT(COLUMN_NAME,
                 ' ',
                 UPPER(DATA_TYPE),
                 CASE
                     WHEN DATA_TYPE IN ( 'sql_variant', 'text', 'ntext', 'xml' ) THEN
                         ''
                     WHEN DATA_TYPE IN ( 'DECIMAL', 'NUMERIC' ) THEN
                         '(' + CAST(NUMERIC_PRECISION AS VARCHAR) + ', ' + CAST(NUMERIC_SCALE AS VARCHAR) + ')'
                     ELSE
                         COALESCE('(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR) END + ')', '')
                 END,
                 IIF(IS_NULLABLE = 'NO', '', ' = NULL')
             ), 
IsIdentity = IIF(COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1, 1,0 ),
Orden = ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE <> 'uniqueidentifier' AND TABLE_NAME = @TableName


SELECT @ParametrosConcatenados = COALESCE(@ParametrosConcatenados + ', ' + CHAR(13), '') + CONCAT('@',ColumnName)
FROM @Parametros
ORDER BY Orden


SELECT @ColumnasConcatenadas = COALESCE(@ColumnasConcatenadas + ', ', '') + COLUMN_NAME,
	   @ColumnasConcatenadasInsert = COALESCE(@ColumnasConcatenadasInsert + ', ', '') + CONCAT('@',COLUMN_NAME),
	   @ColumnasConcatenadasUpdate = COALESCE(@ColumnasConcatenadasUpdate + ', ', '') + CONCAT(COLUMN_NAME, ' = ', '@', COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName AND COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 0 
ORDER BY ORDINAL_POSITION

SELECT @Id = COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName AND (COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1 OR ORDINAL_POSITION = 0)


SET @ProcedimientoAlmacenado = CONCAT('CREATE PROCEDURE pCRUD', @Entidad, CHAR(13))
SET @ProcedimientoAlmacenado = @ProcedimientoAlmacenado + @ParametrosConcatenados
SET @ProcedimientoAlmacenado = @ProcedimientoAlmacenado + CHAR(13) +'AS 
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;
IF @Operacion = ''C''
BEGIN
	INSERT INTO '+ @TableName + ' ('+@ColumnasConcatenadas+')
	VALUES('+@ColumnasConcatenadasInsert+')
	SET '+@Id+' = SCOPE_IDENTITY()
END

IF @Operacion = ''R''
BEGIN
	SELECT '+@ColumnasConcatenadas+'
    FROM '+ @TableName + ' 
	WHERE '+@Id+' = @'+@Id+'
END

IF @Operacion = ''U''
BEGIN
	UPDATE '+ @TableName + ' SET '+@ColumnasConcatenadasUpdate+'
	FROM '+ @TableName + '
	WHERE '+@Id+' = @'+@Id+'
END

IF @Operacion = ''D''
BEGIN
	DELETE FROM '+ @TableName + '
	WHERE '+@Id+' = @'+@Id+'
END

'

PRINT @ProcedimientoAlmacenado

