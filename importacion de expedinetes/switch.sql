


SELECT '
// ' + Documento + '
case "' + Codigo + '":
    file.IdRequisito = ' + ISNULL(CAST(IdRequisito AS VARCHAR), 0) + ';
    file.IdRequisitoD = ' + ISNULL(CAST(IdRequisitoD AS VARCHAR), 0) + ';
    file.idListaDdocumento = ' + ISNULL(CAST(IdListaDdocumento AS VARCHAR),0) + ';
	file.IdTipoDdominio = '+IIF(TipoDdominioDescripcion is not NULL,'(int) EnTipoDdominio.'+TipoDdominioDescripcion+' ','0')+';
    break;'
FROM documentos.dbo.tblDocumentos



