								 
DECLARE @Tabla AS VARCHAR(1024) = 'tSDOcargosDescuentos'
SELECT	TablaPrincipal	     = TablaPrincipal.name, 
		ColumnaPrincipal     = ColumnaPrincipal.name ,
		TablaReferenciada    = TablaReferenciada.name, 				
		ColumnaReferenciada  = ColumnaReferenciado.name,						
		AgregarLlaveForanea  = CONCAT('ALTER TABLE dbo.', TablaReferenciada.name, ' ADD CONSTRAINT FK_',TablaReferenciada.name,'_',TablaPrincipal.name,'_',ColumnaReferenciado.name,' FOREIGN KEY (',ColumnaReferenciado.name,')', 'REFERENCES ', TablaPrincipal.name, '(',ColumnaPrincipal.name,');' ),
		EliminarLlaveForanea  = CONCAT('ALTER TABLE dbo.', TablaReferenciada.name, ' DROP CONSTRAINT ', LlaveForanea.name),
		EliminarColumnaLlaveForanea = CONCAT('ALTER TABLE dbo.', TablaReferenciada.name, ' DROP COLUMN ', ColumnaReferenciado.name) 

FROM sysobjects			   LlaveForanea
INNER JOIN sysobjects TablaReferenciada ON LlaveForanea.parent_obj=TablaReferenciada.id
INNER JOIN sysreferences	 Referencia ON LlaveForanea.id=Referencia.constid
INNER JOIN sysobjects	 TablaPrincipal ON Referencia.rkeyid=TablaPrincipal.id
INNER JOIN syscolumns	 ColumnaPrincipal ON Referencia.rkeyid=ColumnaPrincipal.id AND Referencia.rkey1=ColumnaPrincipal.colid
INNER JOIN syscolumns ColumnaReferenciado ON Referencia.fkeyid=ColumnaReferenciado.id AND Referencia.fkey1=ColumnaReferenciado.colid
WHERE TablaPrincipal.name = @Tabla AND LlaveForanea.type='F';

