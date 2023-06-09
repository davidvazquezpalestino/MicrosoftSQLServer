DECLARE @Procedimiento VARCHAR(MAX) = 'pCRUDdetalleImpuesto';
DECLARE @Clase VARCHAR(MAX) = 'detalleImpuesto';

DECLARE @Parametro VARCHAR(MAX);
DECLARE @Tipo VARCHAR(MAX);
DECLARE @Tamanio INT;
DECLARE @Esoutput BIT;
DECLARE @Script VARCHAR(MAX);


DECLARE @Colid INT;
DECLARE @Direccion VARCHAR(MAX);
DECLARE @Prefijo VARCHAR(MAX);
DECLARE @Valor VARCHAR(MAX);

DECLARE @Idsp INT = (
                        SELECT object_id FROM sys.procedures WHERE name = @Procedimiento
                    );
DECLARE @Columnas INT = (
                            SELECT COUNT(o.id)
                            FROM sysobjects o
                                INNER JOIN syscolumns c
                                    ON o.id = c.id
                            WHERE o.id = @Idsp
                        );

DECLARE @LlavePrimaria VARCHAR(100) = ISNULL(
                                      (
                                          SELECT REPLACE(name, '@', '')
                                          FROM sys.parameters
                                          WHERE object_id = OBJECT_ID(@Procedimiento)
                                                AND is_output = 1
                                      ),
                                      'Id'
                                            );



SET @Prefijo = IIF(@Clase = '', 'p', @Clase + '.');

SET @Script = 'SqlParameter[] parametros = new SqlParameter[' + CAST(@Columnas AS VARCHAR) + '];';


DECLARE CUR CURSOR FOR
SELECT c.name,
       tp.name,
       c.length AS tamaño,
       isoutparam AS EsOutput,
       colid
FROM sys.sysobjects o
    INNER JOIN sys.syscolumns c
        ON o.id = c.id
    INNER JOIN sys.systypes tp
        ON c.xtype = tp.xtype
           AND tp.name <> 'uniqueidentifier'
WHERE o.id = @Idsp
ORDER BY colid;

OPEN CUR;
FETCH NEXT FROM CUR
INTO @Parametro,
     @Tipo,
     @Tamanio,
     @Esoutput,
     @Colid;
WHILE @@Fetch_status = 0
BEGIN
    IF NOT @Tipo IN ( 'Varchar', 'Char', 'Text' )
        SET @Tamanio = 0;

    SET @Parametro = RIGHT(@Parametro, LEN(@Parametro) - 1);
    SET @Valor = @Parametro;


    SET @Direccion = IIF(@Esoutput = 1, ',ParameterDirection.InputOutput', '');

    SET @Script
        = @Script + CHAR(10) + 'parametros[' + CAST(@Colid - 1 AS VARCHAR) + '] = BD.NuevoParametro("' + @Parametro
          + '", SqlDbType.' + CASE @Tipo
                                  WHEN 'varchar' THEN
                                      'VarChar'
                                  WHEN 'int' THEN
                                      'Int'
                                  WHEN 'date' THEN
                                      'Date'
                                  WHEN 'datetime' THEN
                                      'Date'
                                  WHEN 'numeric' THEN
                                      'Decimal, Convert.ToByte(18), Convert.ToByte(2)'
                                  WHEN 'bit' THEN
                                      'Bit'
                                  ELSE
                                      ''
                              END + ', ' + IIF(@Tipo = 'Numeric', '', CONCAT(@Tamanio,', ')) 
          + CASE
                WHEN @Parametro IN ( 'TipoOperacion', 'Operacion' ) THEN
                    +@Prefijo + '' + @LlavePrimaria + ' == 0 ? "C" : "U"'
                ELSE
                    @Prefijo + @Valor
            END + @Direccion + ');';

    FETCH NEXT FROM CUR
    INTO @Parametro,
         @Tipo,
         @Tamanio,
         @Esoutput,
         @Colid;
END;
CLOSE CUR;
DEALLOCATE CUR;

SET @Script = @Script + CHAR(10) + CHAR(10);
SET @Script = @Script + 'BD.EjecutarSP("dbo.' + @Procedimiento + '", ref parametros);' + CHAR(10);
SET @Script
    = @Script + '' + @Clase + '.' + @LlavePrimaria + ' = Convert.ToInt32(parametros[1].Value);' + CHAR(10) + CHAR(10);
SET @Script = @Script + 'return true;';

PRINT @Script;

