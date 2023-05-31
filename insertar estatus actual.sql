
DECLARE @Tabla VARCHAR(1024) = 'tCTLusuariosPerfiles';
DECLARE @Id VARCHAR(100) = 'Id';
DECLARE @IdTipoDdominio VARCHAR(12) = '0'

SELECT	'
DISABLE TRIGGER trEstatusActualBitacoraEstatus ON tCTLestatusActual; '+CHAR(9)+'
BEGIN			
	INSERT INTO tCTLestatusActual(IdEstatus, Alta, IdTipoDDominio, IdControl)

	SELECT 1 As IdEstatus, CURRENT_TIMESTAMP Alta, ' + @IdTipoDdominio + ' AS IdTipoDDominio, ' + @Id + ' AS IdControl
	FROM ' + @Tabla + ' 
	WHERE  IdEstatusActual = 0 AND ' + @Id + ' NOT IN (SELECT IdControl FROM tCTLestatusActual WHERE IdTipoDDominio = ' + @IdTipoDdominio + ');

	UPDATE dom SET IdEstatusActual = ea.IdEstatusActual	FROM ' + @Tabla + ' dom 
	INNER JOIN tCTLestatusActual ea ON dom.' + @Id + ' = ea.IdControl  AND ea.IdTipoDDominio = ' + @IdTipoDdominio + '
	WHERE dom.IdEstatusActual = 0 AND ea.IdControl <> 0;
END;
ENABLE TRIGGER trEstatusActualBitacoraEstatus ON tCTLestatusActual;'

  