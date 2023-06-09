DECLARE	@Procedimiento varchar(max) = 'pCRUDcomprobanteRelacionado',
		@Tipooperacion varchar(max) = 'C',
		@Clase varchar(max) = 'comprobanteRelacionado';

DECLARE @Parametro varchar(max)
DECLARE @Tipo varchar(max)
DECLARE @Tamano int
DECLARE @Esoutput bit
DECLARE @Script varchar(max)
DECLARE @Columnas int
DECLARE @Idsp int = 0
DECLARE @Colid int
DECLARE @Direccion varchar(max)
DECLARE @Prefijo varchar(max)
DECLARE @Valor varchar(max)

SET @Idsp = (SELECT id FROM sysobjects WHERE name = @Procedimiento AND xtype = 'P')
SET @Columnas = (SELECT COUNT(*) - 1 FROM sysobjects o JOIN syscolumns c ON o.id = c.id WHERE o.id = @Idsp)
IF @Clase = ''
SET @Prefijo = 'p' ELSE SET @Prefijo = @Clase + '.'
SET @Script = 'Dim args(' + CAST(@Columnas AS VARCHAR) + ') As SqlParameter'

DECLARE CUR CURSOR FOR SELECT	c.name,
								tp.name,
								c.length AS tamaño,
								isoutparam AS EsOutput,
								colid 
						FROM sysobjects o INNER JOIN syscolumns c ON o.id = c.id INNER JOIN systypes tp ON c.xtype = tp.xtype WHERE o.id = @Idsp
ORDER BY colid
OPEN CUR;
FETCH NEXT FROM CUR
INTO @Parametro, @Tipo, @Tamano, @Esoutput, @Colid
WHILE @@Fetch_status = 0
BEGIN
	IF NOT @Tipo IN ('Varchar', 'Char', 'Text')
		SET @Tamano = 0
		SET @Parametro = RIGHT(@Parametro, LEN(@Parametro) - 1)
		SET @Valor = @Parametro
		PRINT @Tipo
IF @Esoutput = 1 SET @Direccion = ',ParameterDirection.InputOutput' ELSE SET @Direccion = ''	SET @Script = @Script + CHAR(10) + 'args(' + CAST(@Colid - 1 AS VARCHAR) + ') = BD.NuevoParametro("' + @Parametro
	+ '", SqlDbType.' + CASE @Tipo	WHEN 'varchar'	THEN 'VarChar'
									WHEN 'int'	THEN 'Int'
									WHEN 'bigint' THEN 'Int'
									WHEN 'date'	THEN 'Date'
									WHEN 'datetime' THEN 'Date'
									WHEN 'numeric'	THEN 'Decimal'
									WHEN 'bit'		THEN 'Bit'

	END + ', '
	+ CAST(@Tamano AS VARCHAR) + ','
	+ CASE	WHEN @Parametro = 'TipoOperacion' THEN 'If('+@Prefijo + 'Id = 0 , "C", "U")'
			ELSE @Prefijo + @Valor
	END
	+ @Direccion + ')'
	PRINT @Script
	FETCH NEXT FROM CUR
	INTO @Parametro, @Tipo, @Tamano, @Esoutput, @Colid
	END
	CLOSE CUR
DEALLOCATE CUR

SET @Script = @Script + CHAR(10)
SET @Script = @Script + 'BD.EjecutarSP("[dbo].' + @Procedimiento + '", args)' + CHAR(10)
SET @Script = @Script + '' + @Clase + '.Id = Cint(args(1).Value)' + CHAR(10)
SET @Script = @Script + 'return true'
PRINT @Script