--SELECT *
--FROM dbo.tACTactivosExtendida

DECLARE @tabla as varchar(max)= '';

	WITH cPrimaryKeys(tabla, columna)
	AS (	SELECT SO.NAME, SC.NAME
			FROM sys.objects SO WITH(NOLOCK) 
			INNER JOIN sys.columns SC ON SO.OBJECT_ID = SC.OBJECT_ID 
			WHERE system_type_id =56 AND column_id = 1 AND type = 'U' AND not SC.NAME='Id' 
				
		),
		 cForeingkeys(tabla, columna, forenkeys)
	AS (	SELECT fk.TABLE_NAME,cu.COLUMN_NAME, fk.TABLE_NAME+cu.COLUMN_NAME
					FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C WITH(NOLOCK)
					 INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK WITH(NOLOCK) ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
					 INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK WITH(NOLOCK) ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
					 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU WITH(NOLOCK) ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
					 INNER JOIN (	SELECT i1.TABLE_NAME , i2.COLUMN_NAME, i2.TABLE_NAME as z
									FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1 WITH(NOLOCK) 
									INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 WITH(NOLOCK) ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
									WHERE i1.CONSTRAINT_TYPE = 'PRIMARY KEY' ) PT ON PT.TABLE_NAME = PK.TABLE_NAME 
			WHERE ((NOT @tabla = '' AND fk.TABLE_NAME = @tabla) OR @tabla = '')
		),
		cCamposTabla(tabla, columna)
	AS (	SELECT SO.NAME, SC.NAME
			FROM sys.objects SO WITH(NOLOCK) INNER JOIN sys.columns SC WITH(NOLOCK) ON SO.OBJECT_ID = SC.OBJECT_ID
			WHERE system_type_id =56 AND type = 'U' AND not column_id = 1 
				AND ((NOT @tabla = '' AND SO.NAME = @tabla) OR @tabla = '')
				AND (SO.NAME+SC.NAME) not in (select tabla+columna from cForeingkeys)
		),
		cScripts(fk_tabla, fk_columna, pk_tabla, pk_columna, script, ExisteNombre)
	AS (	SELECT cCamposTabla.Tabla, cCamposTabla.Columna,cPrimaryKeys.tabla, cPrimaryKeys.Columna,
				'IF NOT EXISTS(SELECT 1 FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID('''+@tabla+''')AND name = ''FK_'+ cCamposTabla.tabla+'_' +cCamposTabla.columna+''')
ALTER TABLE [dbo].[' + cCamposTabla.tabla+'] ADD CONSTRAINT FK_'+ cCamposTabla.tabla+'_'+cCamposTabla.columna+'' + case when not cPrimaryKeys.columna = cCamposTabla.columna then replace (cCamposTabla.columna,cPrimaryKeys.columna,'')  else '' end +' '+'FOREIGN KEY('+ cCamposTabla.columna+') REFERENCES [dbo].['+ cPrimaryKeys.tabla+'] ('+ cPrimaryKeys.columna+')'+Char(10)+'GO'
			,ISNULL((SELECT 'SI' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME  = ('FK_'+ cCamposTabla.tabla+'_'+ cPrimaryKeys.tabla + 
												case when not cPrimaryKeys.columna=cCamposTabla.columna then replace (cCamposTabla.columna,cPrimaryKeys.columna,'')  
												      else '' end )),'No')
			FROM cCamposTabla, cPrimaryKeys
			WHERE cCamposTabla.columna like ( cPrimaryKeys.columna+ '%') 
				AND NOT (cCamposTabla.columna ='IdEstatusActual' AND cPrimaryKeys.columna ='IdEstatus' ) 
				AND NOT (cCamposTabla.columna ='IdCuentaABCD' AND cPrimaryKeys.columna ='IdCuenta' )
				AND NOT (cPrimaryKeys.tabla='tGRLcuentasABCDEXT' AND cPrimaryKeys.columna='IdCuentaABCD')
				AND NOT (cPrimaryKeys.tabla='tSDOsaldosCuentasAcreedoras' AND cPrimaryKeys.columna='IdCuenta')
				AND NOT (cPrimaryKeys.tabla='tAYCproductosFinancierosRequisitos' AND cPrimaryKeys.columna='IdRequisito')
				AND NOT (cPrimaryKeys.tabla='tCTLresumenDominio' AND cPrimaryKeys.columna='IdRegistro')
		)
	SELECT cScripts.fk_tabla, cScripts.fk_columna, cScripts.pk_tabla, cScripts.pk_columna, cScripts.script, cScripts.ExisteNombre 
	FROM cScripts
	WHERE fk_tabla = @tabla
	ORDER BY pk_columna--,fk_tabla

	
	
