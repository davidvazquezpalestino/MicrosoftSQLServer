SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
GO


/*
    ============================================
                    MELISSA v1.1
    ============================================
      Por:  Ing. Jorge Ivan Hernandez Rivera
    Fecha:  04 de Diciembre del 2004

      Act:  06 / Feberero / 2005
    --------------------------------------------
    Se dan de alta los nuevos números de serie
    --------------------------------------------
*/

ALTER Procedure [dbo].[sp_inv_ser]
@id_ser    as int output,
@id_pro    as int,
@num_lot   as varchar(64),
@id_alm    as int,
@num_ser   as varchar(64),
@tipo      as tinyint,
@cant      as float,
@fec_elab  as datetime,
@fec_cad   as datetime,
@id_cert   as float,
@c_ped     as tinyint,
@num_ped   as varchar(30),
@aduana    as varchar(50),
@fecha_ped as datetime,
-- Versión 1.1.54  03/Sep/2006 JIHR
@id_ord_prd  as int,
@num_ord_prd as int,
@costo       as float,
@tip_ord     as tinyint,
-- Versión 3.5 17/Feb/2014
@Fecha		as datetime,
-- Versión 4.4 27/10/2015
@cant_brix  as float,

@IdBarco as  int = 0, 
@IdCliente as  int = 0, 
@IdProveedor as  int = 0, 
@Ticket1OrigenFolio as  int = 0, 
@Ticket1OrigenPeso as  NUMERIC (18,2) = 0, 
@Ticket2OrigenFolio as  int = 0, 
@Ticket2OrigenPeso as  numeric (18,2)= 0, 
@Ticket1RecepcionFolio as  int = 0, 
@Ticket1RecepcionPeso as  numeric (18,2)= 0, 
@Ticket1RecepcionPesoReal as  numeric (18,2)= 0, 
@Ticket2RecepcionFolio as  int = 0, 
@Ticket2RecepcionPeso as  numeric (18,2)= 0, 
@Ticket2RecepcionPesoReal as  numeric (18,2)= 0

AS
  
  declare @dec_cant       as int
  declare @dec_existencia as int
  declare @id_mto_ser_lot as int
  set @dec_cant       = dbo.dve_dec_cant_vta()
  set @dec_existencia = dbo.dve_dec_existencia()

  set @cant = round(@cant,@dec_cant)
  
  -- Se ejecuta el SP que crea el Maestro de Serie/Lote
  Execute sp_inv_mto_ser_lot @id_mto_ser_lot output,@id_pro,@num_lot,@num_ser,@tipo,@cant,@fec_elab,@fec_cad,@id_cert,@c_ped,@num_ped,
                             @aduana,@fecha_ped,@id_ord_prd,@num_ord_prd,@costo, @tip_ord, @cant_brix,
							 @IdBarco, @IdCliente, @IdProveedor, @Ticket1OrigenFolio, @Ticket1OrigenPeso, @Ticket2OrigenFolio, @Ticket2OrigenPeso, @Ticket1RecepcionFolio, @Ticket1RecepcionPeso, @Ticket1RecepcionPesoReal, @Ticket2RecepcionFolio, @Ticket2RecepcionPeso, @Ticket2RecepcionPesoReal

  Select @id_ser = id_ser_lot from inv_ser_lot WITH (NOLOCK) where id_pro= @id_pro and num_ser = @num_ser and num_lot = @num_lot and tipo=@tipo and id_almac = @id_alm

  If @id_ser Is NULL 
    Begin
      set @id_ser = dbo.Dve_id_inv_ser()
      Insert Into Inv_ser_lot  Values(@id_ser,@id_pro,@id_alm,@num_lot,@num_ser,@cant,@tipo,@fec_elab,@fec_cad,@id_cert,@c_ped,@num_ped,@aduana,
                                      @fecha_ped,1,0,0,@id_mto_ser_lot,@Fecha, @costo,@cant_brix )
    End
  Else
    Begin
      UPDATE inv_ser_lot set existencia = round(existencia + @cant,@dec_existencia),
							 disponible = round(disponible + @cant,@dec_existencia),
							 existencia_brix = round(existencia_brix + @cant_brix,@dec_existencia) 
	 WHERE id_ser_lot = @id_ser
    End


GO

