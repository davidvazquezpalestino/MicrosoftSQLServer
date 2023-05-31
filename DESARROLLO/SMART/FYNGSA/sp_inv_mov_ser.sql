SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
GO

--    ============================================
--                    MELISSA v1.1
--    ============================================
--      Por:  Ing. Jorge Ivan Hernandez Rivera
--    Fecha:  04 de Diciembre del 2004
--    --------------------------------------------
--    Se crean los movimientos por numero de 
--    serie
--    --------------------------------------------

ALTER  PROCEDURE [dbo].[sp_inv_mov_ser]
@id_pro      as int,
@num_lot     as varchar(64),
@num_ser     as varchar(64),
@id_almac    as int,
@id_usr      as int,
@id_tip_doc  as int,
@id_doc      as int,
@num_doc     as int,
@fecha       as datetime,
@cant        as float,
@tipo        as tinyint,
@IO          as tinyint , /* 1=Entrada  2=Salida*/
@fec_elab    as datetime,
@fec_cad     as datetime,
@c_ped       as tinyint,
@num_ped     as varchar(30),
@aduana      as varchar(50),
@fecha_ped   as datetime,
@id_mov_ser  as int output,
@id_sis_cnl  as int,
-- Versión 1.1.54  03/sep/2006 JIHR
@id_ord_prd  as int,
@num_ord_prd as int,
@costo       as float,
@tip_ord     as tinyint,  -- 1 = Orden de Prod. 2 = Orden de Comp

-- Versión 2.1.0
@preview    as tinyint = 0, -- 1 = Preview se guarda en el temporal 0 = Lo guarda en las tablas normales
-- Versión 4.4.0  27/10/2015
@brix_corregido as float = 0,
@cantidad_brix  as float = 0,

--version x
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

  declare @dec_cant   as int
  set @dec_cant = dbo.dve_dec_cant_vta()
  set @cant = round(@cant , @dec_cant)

  declare @id_ser     as int 
  declare @cant_real  as float
  declare @id_cert    as int

  declare @cantidad_brix_real as float --27/10/2015

  set @id_cert = 0 

  if @IO = 2  
	BEGIN
		set @cant_real = round(@cant * -1 , @dec_cant)
		set @cantidad_brix_real = round(@cantidad_brix * -1 , @dec_cant)  --27/10/2015
	END
  else
	BEGIN
		set @cant_real = round(@cant , @dec_cant)
		set @cantidad_brix_real = round(@cantidad_brix, @dec_cant)  --27/10/2015
	END
 
  if @preview =  0
    execute sp_inv_ser @id_ser output,@id_pro,@num_lot,@id_almac,@num_ser,@tipo,@cant_real,@fec_elab,@fec_cad,@id_cert,@c_ped,@num_ped,@aduana,@fecha_ped,@id_ord_prd,
                     @num_ord_prd,@costo,@tip_ord,@fecha,@cantidad_brix_real,
					 @IdBarco, @IdCliente, @IdProveedor, @Ticket1OrigenFolio, @Ticket1OrigenPeso, @Ticket2OrigenFolio, @Ticket2OrigenPeso, @Ticket1RecepcionFolio, @Ticket1RecepcionPeso, @Ticket1RecepcionPesoReal, @Ticket2RecepcionFolio, @Ticket2RecepcionPeso, @Ticket2RecepcionPesoReal

  if @preview = 0 
    begin
      set @id_mov_ser = dbo.dve_id_inv_mov_ser()
      insert into inv_mov_ser_lot Values(@id_mov_ser,@id_ser,@id_almac,@id_usr,@id_tip_doc,@id_doc,@num_doc,@fecha,@cant_real,@tipo,@fec_elab,@fec_cad,@id_sis_cnl,@brix_corregido,@cantidad_brix_real, @IdBarco,@IdCliente,@IdProveedor,@Ticket1OrigenFolio,@Ticket1OrigenPeso,@Ticket2OrigenFolio,@Ticket2OrigenPeso,@Ticket1RecepcionFolio,@Ticket1RecepcionPeso,@Ticket1RecepcionPesoReal,@Ticket2RecepcionFolio,@Ticket2RecepcionPeso,@Ticket2RecepcionPesoReal)
    end
  else
    begin
      set @id_mov_ser = dbo.Dve_ID_Inv_mov_ser_lot_tmp_doc()
      set @id_ser = 0
      insert into inv_mov_ser_lot_tmp_doc
      Values(@id_mov_ser,@id_ser,@id_almac,@id_usr,@id_tip_doc,@id_doc,@num_doc,@fecha,@cant_real,@tipo,@fec_elab,@fec_cad,@id_sis_cnl,@num_lot,@num_ser,@c_ped,@num_ped,@aduana,@fecha_ped)
    end






GO

