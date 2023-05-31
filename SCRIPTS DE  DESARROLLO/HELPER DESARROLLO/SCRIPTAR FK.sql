SELECT
	'alter table ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' with check check constraint ' + fk.name + ';'
FROM sys.foreign_keys	fk
INNER JOIN sys.tables	t	ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas	s	ON t.schema_id = s.schema_id
WHERE fk.is_not_trusted = 1