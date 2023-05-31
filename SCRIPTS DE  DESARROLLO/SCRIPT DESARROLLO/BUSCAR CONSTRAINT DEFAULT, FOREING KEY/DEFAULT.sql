DECLARE @Tabla AS VARCHAR(100) = 'tCTLempresas'
DECLARE @Campo AS VARCHAR(100) = 'CalcularMoratoriosBalance'
DECLARE @sql AS VARCHAR(MAX) = (SELECT 'IF EXISTS(SELECT 1 FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID(''' + @Tabla + ''') AND NAME = ''' + name + ''') ' + CHAR(13) + 'ALTER TABLE ' + @Tabla + ' DROP CONSTRAINT ' + name + ' '
								FROM sys.default_constraints d
								WHERE d.parent_object_id = OBJECT_ID('' + @Tabla + '') AND COL_NAME(d.parent_object_id, d.parent_column_id) = @Campo)
EXECUTE (@sql)
PRINT @sql

IF EXISTS (SELECT 1 FROM sys.columns c WHERE c.object_id = OBJECT_ID(@Tabla) AND c.name = @Campo)
	EXECUTE ('ALTER TABLE ' + @Tabla + ' DROP COLUMN ' + @Campo + ' ')
GO

ALTER TABLE dbo.tCTLempresas ADD CalcularMoratoriosBalance BIT NOT NULL CONSTRAINT DF_tCTLempresas_CalcularMoratoriosBalance DEFAULT 1 

