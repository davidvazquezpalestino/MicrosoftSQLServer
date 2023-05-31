/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  13/09/2017
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pvta_fac_enc_operador'))
DROP PROCEDURE pvta_fac_enc_operador
GO

CREATE PROCEDURE dbo.pvta_fac_enc_operador
    @IdCompra INT = NULL,
    @id_fac INT = NULL,
    @Operador VARCHAR(256) = NULL,
    @Placas VARCHAR(256) = NULL,
    @TarjetaCirculacion VARCHAR(256) = NULL,
    @LicenciaOperador VARCHAR(256) = NULL,
    @NumeroTalon VARCHAR(32) = NULL
AS
BEGIN
    IF @Operador IS NOT NULL  AND @Operador !=''     
        INSERT INTO vta_fac_enc_operador(IdCompra, id_fac, Operador, Placas, TarjetaCirculacion, LicenciaOperador, NumeroTalon)
		VALUES(@IdCompra, @id_fac, @Operador, @Placas, @TarjetaCirculacion, @LicenciaOperador, @NumeroTalon)
END;


GO

