Alter Table tDIGarchivos Add Id_new Int Identity(1, 1)
GO

Alter Table tDIGarchivos Drop Column IdArchivo
GO

EXEC sp_rename	'tDIGarchivos.Id_new',
				'IdArchivo',
				'Column'


