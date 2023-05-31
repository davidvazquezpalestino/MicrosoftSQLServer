SELECT a.bd,a.OBJECT, COUNT(a.bd), b.BD,b.OBJECT, COUNT(b.bd)
FROM 
(
	SELECT 'intelixDEV' AS BD, o.name [OBJECT], c.NAME, c.column_id
	FROM [intelixDEV].sys.objects o INNER JOIN 
		 [intelixDEV].sys.[columns] c ON o.[object_id] = c.[object_id]
	WHERE NOT o.NAME IN ('')
) AS a 

--LEFT JOIN 
RIGHT JOIN

(
	SELECT 'TEST' AS BD, o.name [OBJECT], c.NAME, c.column_id
	FROM [TEST].sys.objects o INNER JOIN 
		 [TEST].sys.[columns] c ON o.[object_id] = c.[object_id]
	WHERE NOT o.NAME IN ('')
) AS b ON b.OBJECT = a.OBJECT AND b.NAME = a.NAME
--	WHERE b.NAME IS NULL 
	WHERE a.NAME IS NULL 
GROUP BY a.BD, b.BD, a.OBJECT, b.OBJECT