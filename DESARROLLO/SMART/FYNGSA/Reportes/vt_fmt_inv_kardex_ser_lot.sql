/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  13/09/2017
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vt_fmt_inv_kardex_ser_lot'))
	DROP VIEW dbo.vt_fmt_inv_kardex_ser_lot
GO

CREATE VIEW dbo.vt_fmt_inv_kardex_ser_lot
	AS
SELECT     dbo.inv_kardex.id_tipo_doc, dbo.cat_doctos.descripcion AS Documento, 
					  Fecha = CAST(dbo.inv_kardex.fecha AS DATE), 
					  dbo.inv_kardex.num_doc, 
					  dbo.inv_kardex.id_pro, 
                      dbo.cat_pro.clave, 
					  dbo.cat_pro.codigo, 
					  Producto = dbo.cat_pro.des, 
					  Presentacion = dbo.cat_pro.presentacion, 					  
					  dbo.inv_kardex.cant AS cant_mov, 
                      costoUnitario = dbo.inv_kardex.costo, 
					  CostoTotal = dbo.inv_kardex.costo_total, 
					  dbo.cat_almac.descripcion AS Almacen, 

                      dbo.inv_kardex.id_almac, 
					  dbo.inv_mov_ser_lot.id_mov_ser_lot, 
					  dbo.inv_mov_ser_lot.id_ser_lot, 
					  dbo.inv_mov_ser_lot.id_usr, 
                      dbo.inv_mov_ser_lot.cant, 
					  dbo.inv_mov_ser_lot.tipo, 
					  dbo.inv_ser_lot.num_lot, 
					  dbo.inv_ser_lot.num_ser, 
					  dbo.inv_ser_lot.fec_elab, 
                      dbo.inv_ser_lot.fec_cad, 
					  dbo.inv_ser_lot.num_ped, 
					  dbo.inv_ser_lot.aduana, 
					  dbo.inv_ser_lot.fecha_ped, 
					  dbo.sis_mov_ser_lot.id_com_ser_lot, 
                      dbo.inv_kardex.id_usr AS Expr1, dbo.cat_usr.usr, 					 
					  
					  TipoMovimiento = CASE tipo_mov WHEN 0 THEN 'Entrada' ELSE 'Salida' END,
					  Salidas =  CASE Tipo_mov WHEN 0 THEN inv_kardex.cant ELSE 0 END, 
					  Entradas = CASE Tipo_Mov WHEN 1 THEN inv_kardex.cant ELSE 0 END,

					  existencia = inv_kardex.existencia_alm,
					  dbo.inv_kardex.udm,
					  cat_barcos.IdBarco,
					  Barco = dbo.cat_barcos.Descripcion,
					  dbo.cat_prov.Id_prov

FROM         dbo.cat_almac 
                    INNER JOIN  dbo.inv_kardex ON dbo.cat_almac.id_almac = dbo.inv_kardex.id_almac 
                    INNER JOIN  dbo.cat_doctos ON dbo.inv_kardex.id_tipo_doc = dbo.cat_doctos.id_doc 
                    INNER JOIN  dbo.cat_pro ON dbo.inv_kardex.id_pro = dbo.cat_pro.id_pro 
                    INNER JOIN  dbo.sis_mov_ser_lot ON dbo.inv_kardex.id_com_ser_lot = dbo.sis_mov_ser_lot.id_com_ser_lot 
                    INNER JOIN  dbo.inv_mov_ser_lot ON dbo.sis_mov_ser_lot.id_mov_ser_lot = dbo.inv_mov_ser_lot.id_mov_ser_lot 
                    INNER JOIN  dbo.inv_ser_lot ON dbo.inv_mov_ser_lot.id_ser_lot = dbo.inv_ser_lot.id_ser_lot 
					INNER JOIN  dbo.cat_usr ON dbo.inv_kardex.id_usr = dbo.cat_usr.id_usr
					INNER JOIN	dbo.cat_barcos ON cat_barcos.IdBarco = inv_mov_ser_lot.IdBarco
					INNER JOIN	dbo.cat_prov ON	dbo.cat_prov.Id_prov = dbo.inv_mov_ser_lot.IdProveedor
					INNER JOIN	dbo.cat_clientes ON dbo.cat_clientes.id_cli = dbo.inv_mov_ser_lot.IdCliente

WHERE     (dbo.inv_kardex.id_com_ser_lot > 0)





GO


