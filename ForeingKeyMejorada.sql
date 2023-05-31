	DECLARE @TableName AS VARCHAR(MAX) = '';

	DROP TABLE IF EXISTS #LlavesPrimarias;
	CREATE TABLE #LlavesPrimarias ( Tabla VARCHAR(100), Columna VARCHAR(250) );

	INSERT INTO #LlavesPrimarias(Tabla, Columna)
	SELECT Objeto.name, Columna.name
	FROM sys.objects       Objeto WITH(NOLOCK)
	INNER JOIN sys.columns Columna ON Objeto.object_id = Columna.object_id
	WHERE system_type_id = 56 AND column_id = 1 AND type = 'U' AND NOT Columna.name = 'Id';

	DROP TABLE IF EXISTS #LlavesForaneas;
	CREATE TABLE #LlavesForaneas ( Tabla VARCHAR(100), Columna VARCHAR(250), LlaveForanea VARCHAR(250) );

	INSERT INTO #LlavesForaneas(Tabla, Columna, LlaveForanea)
	SELECT FK.TABLE_NAME, CU.COLUMN_NAME, FK.TABLE_NAME + '_' + CU.COLUMN_NAME
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C WITH(NOLOCK)
	INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK WITH(NOLOCK)ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
	INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK WITH(NOLOCK)ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE  CU WITH(NOLOCK)ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
	INNER JOIN( SELECT i1.TABLE_NAME, i2.COLUMN_NAME, i2.TABLE_NAME AS z
				FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS      i1 WITH(NOLOCK)
				INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 WITH(NOLOCK)ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
				WHERE i1.CONSTRAINT_TYPE = 'PRIMARY KEY' ) PT ON PT.TABLE_NAME = PK.TABLE_NAME
	WHERE( ( NOT @TableName = '' AND FK.TABLE_NAME = @TableName ) OR @TableName = '' );


	DROP TABLE IF EXISTS #CamposTabla;
	CREATE TABLE #CamposTabla (Tabla VARCHAR(100), Columna VARCHAR(250));

	INSERT INTO #CamposTabla(Tabla, Columna)
	SELECT Objeto.name, 
		   Columna.name
	FROM SYS.OBJECTS        Objeto WITH(NOLOCK)
	INNER JOIN SYS.COLUMNS Columna WITH(NOLOCK)ON Objeto.object_id = Columna.object_id
	WHERE system_type_id = 56 AND type = 'U' AND NOT column_id = 1 AND ( ( NOT @TableName = '' AND Objeto.name COLLATE DATABASE_DEFAULT = @TableName COLLATE DATABASE_DEFAULT) OR @TableName = '') AND (Objeto.name + Columna.name) NOT IN ( SELECT Tabla + Columna FROM #LlavesForaneas );

	DROP TABLE IF EXISTS #Scripts;
	CREATE TABLE #Scripts
	(
	TablaExterna VARCHAR(100),
	ColumnaExterna VARCHAR(100),
	TablaPrincipal VARCHAR(100),
	ColumnaPrincipal VARCHAR(100),
	Script VARCHAR(MAX),
	ExisteNombre VARCHAR(12)
	);

	INSERT INTO #Scripts(TablaExterna, ColumnaExterna, TablaPrincipal, ColumnaPrincipal, Script, ExisteNombre)
	SELECT #CamposTabla.Tabla,
		   #CamposTabla.Columna,
		   #LlavesPrimarias.Tabla,
		   #LlavesPrimarias.Columna,
		   'IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID(''' + @TableName + ''')AND name = ''FK_' + #CamposTabla.Tabla + '_'
		   + #CamposTabla.Columna + ''')
						ALTER TABLE [dbo].['                                                           + #CamposTabla.Tabla + '] ADD CONSTRAINT FK_'
		   + #CamposTabla.Tabla + '_' + #CamposTabla.Columna + '' + CASE
																		WHEN NOT #LlavesPrimarias.Columna = #CamposTabla.Columna THEN
																			REPLACE (#CamposTabla.Columna, #LlavesPrimarias.Columna, '')
																		ELSE
																			''
																	END + ' ' + 'FOREIGN KEY(' + #CamposTabla.Columna + ') REFERENCES [dbo].['
		   + #LlavesPrimarias.Tabla + '] (' + #LlavesPrimarias.Columna + ')' + CHAR (10) + 'GO',
		   ISNULL (
		   (
		   SELECT 'SI'
		   FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		   WHERE CONSTRAINT_NAME COLLATE DATABASE_DEFAULT = ('FK_' + #CamposTabla.Tabla + '_' + #LlavesPrimarias.Tabla
									+ CASE
										  WHEN NOT #LlavesPrimarias.Columna COLLATE DATABASE_DEFAULT = #CamposTabla.Columna COLLATE DATABASE_DEFAULT THEN
											  REPLACE (#CamposTabla.Columna, #LlavesPrimarias.Columna, '')
										  ELSE
											  ''
									  END
								   ) 
		   )COLLATE DATABASE_DEFAULT,
		   'No'
				  )
	FROM #CamposTabla, #LlavesPrimarias
	WHERE #CamposTabla.Columna LIKE (#LlavesPrimarias.Columna + '%') 

	SELECT TablaExterna, ColumnaExterna, TablaPrincipal, ColumnaPrincipal, Script, ExisteNombre
	FROM #Scripts
	WHERE TablaExterna = @TableName
	ORDER BY ColumnaPrincipal;
