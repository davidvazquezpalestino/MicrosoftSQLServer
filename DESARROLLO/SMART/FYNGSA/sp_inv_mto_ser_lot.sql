SET QUOTED_IDENTIFIER ON
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

ALTER Procedure [dbo].[sp_inv_mto_ser_lot]
@id_mto_ser_lot as int output,
@id_pro         as int,
@num_lot        as varchar(64),
@num_ser        as varchar(64),
@tipo           as tinyint,
@cant           as real,
@fec_elab       as datetime,
@fec_cad        as datetime,
@id_cert        as int,
@c_ped          as tinyint,
@num_ped        as varchar(30),
@aduana         as varchar(50),
@fecha_ped      as datetime,
@id_ord_prd     as int,
@num_ord_prd    as int,
@costo          as float ,
@tip_ord        as tinyint,
@cant_brix		as float,  -- Versión 4.4.0  27/10/2015


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
  set @dec_cant       = dbo.dve_dec_cant_vta()
  set @dec_existencia = dbo.dve_dec_existencia()

  set @cant = round(@cant,@dec_cant)
  set @cant_brix = round(@cant_brix,@dec_cant)

  Select @id_mto_ser_lot = id_mto_ser_lot from inv_mto_ser_lot
  where id_pro= @id_pro and num_ser = @num_ser and num_lot = @num_lot and tipo=@tipo

  If @id_mto_ser_lot Is NULL 
    Begin
      set @id_mto_ser_lot = dbo.Dve_ID_Mto_ser_lot()
      Insert Into Inv_mto_ser_lot  
	  VALUES(@id_mto_ser_lot,@id_pro,@num_lot,@num_ser,@cant,@tipo,@fec_elab,@fec_cad,@id_cert,@c_ped,@num_ped,@aduana,@fecha_ped,1,0,@cant,@id_ord_prd,@num_ord_prd,@costo,@tip_ord,@cant_brix,
	  @IdBarco, @IdCliente, @IdProveedor, @Ticket1OrigenFolio, @Ticket1OrigenPeso, @Ticket2OrigenFolio, @Ticket2OrigenPeso, @Ticket1RecepcionFolio, @Ticket1RecepcionPeso, @Ticket1RecepcionPesoReal, @Ticket2RecepcionFolio, @Ticket2RecepcionPeso, @Ticket2RecepcionPesoReal)
    End
  Else
    Begin
      Update inv_mto_ser_lot set existencia = round(existencia + @cant,@dec_existencia),disponible = round(disponible + @cant,@dec_existencia),existencia_brix = round(existencia_brix + @cant_brix,@dec_existencia) where id_mto_ser_lot = @id_mto_ser_lot
    End


GO

