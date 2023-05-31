/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  13/09/2017
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vt_inventario_kardex'))
	DROP VIEW dbo.vt_inventario_kardex
GO

CREATE VIEW [dbo].[vt_inventario_kardex]
	AS
SELECT      documento.id_doc, 
			Movimiento = CASE kardex.id_sis_cnl WHEN 0 THEN documento.descripcion ELSE '**CANC**' + documento.descripcion END ,
            Folio	 = kardex.num_doc, 
			Fecha = CAST(kardex.fecha AS DATE), 
			Producto = producto.des,
			producto.udm_inv,
			producto.presentacion,
			MarcaProducto = producto.marca,
			Tipo	 = CASE tipo_mov WHEN 0 THEN 'E' ELSE 'S' END, 
            Entradas = CASE Tipo_mov WHEN 0 THEN kardex.cant ELSE 0 END,
			Salida	 = CASE Tipo_Mov WHEN 1 THEN kardex.cant ELSE 0 END,
			
			[Cto. Uni.]  = kardex.costo, 
            [Cto. Prom.] = kardex.costo_prom, 
			[Cto. Total] = kardex.costo_total, 
			
			kardex.existencia, 
			Almacen = dbo.cat_almac.descripcion, 
            kardex.id_pro, kardex.id_kardex, dbo.cat_almac.id_almac, kardex.serie, documento.prd_rcst, kardex.id_sis_cnl, 
            kardex.tipo_mov, 
		    kardex.existencia_alm,
		    TipoCambio = kardex.tc,
		    NoLote = lote.num_lot,
		    Pedimento = lote.num_ped,
		    FechaPedimento = CAST(lote.fecha_ped AS DATE),
		    Aduana = lote.aduana,

		    MedioEnvio.id_med_env,
		    MedioEnvio = MedioEnvio.des,
		  
		    compra.id_compra,
		    id_emp_comp,
		    Recibio = empleado.nom +' '+ empleado.ap_pat + ' ' + empleado.ap_mat,

			nota.nota,

			Ticket1OrigenFolio,	
			Ticket1OrigenPeso,	
			Ticket2OrigenFolio,	
			Ticket2OrigenPeso,	
			Ticket1RecepcionFolio,
			Ticket1RecepcionPeso,	
			Ticket1RecepcionPesoReal,
			Ticket2RecepcionFolio,	
			Ticket2RecepcionPeso,	
			Ticket2RecepcionPesoReal,

		   barco.IdBarco,
		   Barco = barco.Descripcion,
		   
		   cliente.id_cli,

		   Cliente = cliente.nom1,
		   proveedor.Id_prov,
		   
		   Proveedor = proveedor.nom1,	
		   
		   Operador.Operador,
		   Operador.Placas,
		   Operador.TarjetaCirculacion,
		   Operador.LicenciaOperador,
		   Operador.NumeroTalon
		      		   
FROM       dbo.inv_kardex kardex
INNER JOIN dbo.cat_usr	usuario ON kardex.id_usr = usuario.id_usr 
INNER JOIN dbo.cat_almac ON kardex.id_almac = dbo.cat_almac.id_almac 
INNER JOIN dbo.cat_pro producto ON kardex.id_pro = producto.id_pro 
INNER JOIN dbo.cat_doctos documento ON kardex.id_tipo_doc = documento.id_doc
INNER JOIN dbo.sis_mov_ser_lot ON kardex.id_com_ser_lot = dbo.sis_mov_ser_lot.id_com_ser_lot 
INNER JOIN dbo.inv_mov_ser_lot Mov ON dbo.sis_mov_ser_lot.id_mov_ser_lot = Mov.id_mov_ser_lot
INNER JOIN dbo.inv_ser_lot lote ON lote.id_ser_lot = Mov.id_ser_lot
INNER JOIN dbo.com_mov_doc compra ON compra.id_compra = kardex.id_doc
LEFT  JOIN dbo.sis_notas nota ON nota.id_nota = compra.id_nota
INNER JOIN dbo.cat_emp     empleado ON empleado.id_emp =  compra.id_emp_comp
INNER JOIN dbo.cat_med_env MedioEnvio ON MedioEnvio.id_med_env = compra.id_med_env
LEFT JOIN dbo.vta_fac_enc_operador Operador ON Operador.IdCompra = compra.id_compra
LEFT  JOIN dbo.cat_barcos barco ON barco.IdBarco = Mov.IdBarco
LEFT  JOIN dbo.cat_clientes cliente ON cliente.id_cli = Mov.IdCliente
LEFT  JOIN dbo.cat_prov proveedor ON proveedor.Id_prov = Mov.IdProveedor






GO


