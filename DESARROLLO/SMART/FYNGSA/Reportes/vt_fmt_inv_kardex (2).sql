/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  16/08/2017
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vt_fmt_inv_kardex'))
DROP VIEW dbo.vt_fmt_inv_kardex
GO

CREATE VIEW vt_fmt_inv_kardex	
	AS	
SELECT      documento.id_doc, 
			Movimiento = CASE kardex.id_sis_cnl WHEN 0 THEN documento.descripcion ELSE '**CANC**' + documento.descripcion END ,
            Número	 = kardex.num_doc, 
			Fecha = CAST(kardex.fecha AS DATE), 
			Producto = producto.des,
			producto.udm_inv,
			Tipo	 = CASE tipo_mov WHEN 0 THEN 'E' ELSE 'S' END, 
            Entradas = CASE Tipo_mov WHEN 0 THEN kardex.cant ELSE 0 END,
			Salida	 = CASE Tipo_Mov WHEN 1 THEN kardex.cant ELSE 0 END,
			[Cto. Uni.] = kardex.costo, 
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

		   Cliente =cliente.nom1,
		   proveedor.Id_prov,
		   
		   fac.id_fac,
		   Proveedor = proveedor.nom1,			   
		   
		   MedioEnvio.id_med_env,
		   MedioEnvio = MedioEnvio.des,

		   Vendedor = empleado.nom + ' ' + empleado.ap_pat + ' ' + empleado.ap_mat, 

		   operador.Operador,
		   operador.Placas,
		   operador.TarjetaCirculacion,
		   operador.LicenciaOperador
		   	   		   
FROM       dbo.inv_kardex kardex		WITH(NOLOCK)
INNER JOIN dbo.cat_usr	usuario			WITH(NOLOCK) ON kardex.id_usr = usuario.id_usr 
INNER JOIN dbo.cat_almac				WITH(NOLOCK) ON kardex.id_almac = dbo.cat_almac.id_almac 
INNER JOIN dbo.cat_pro producto			WITH(NOLOCK) ON kardex.id_pro = producto.id_pro 
INNER JOIN dbo.cat_doctos documento		WITH(NOLOCK) ON kardex.id_tipo_doc = documento.id_doc

INNER JOIN dbo.vta_fac_enc fac			WITH(NOLOCK) ON fac.id_fac = kardex.id_doc
INNER JOIN dbo.cat_med_env MedioEnvio	WITH(NOLOCK) ON fac.id_med_env1 = MedioEnvio.id_med_env
INNER JOIN dbo.cat_emp empleado			WITH(NOLOCK) ON fac.id_vend = empleado.id_emp

INNER JOIN dbo.sis_mov_ser_lot			WITH(NOLOCK) ON kardex.id_com_ser_lot = dbo.sis_mov_ser_lot.id_com_ser_lot 
INNER JOIN dbo.inv_mov_ser_lot Mov		WITH(NOLOCK) ON dbo.sis_mov_ser_lot.id_mov_ser_lot = Mov.id_mov_ser_lot
INNER JOIN dbo.inv_ser_lot lote			WITH(NOLOCK) ON lote.id_ser_lot = Mov.id_ser_lot

LEFT  JOIN dbo.vta_fac_enc_operador operador WITH(NOLOCK) ON operador.id_fac = fac.id_fac
LEFT  JOIN dbo.cat_barcos	barco		WITH(NOLOCK) ON barco.IdBarco = Mov.IdBarco
LEFT  JOIN dbo.cat_clientes cliente		WITH(NOLOCK) ON cliente.id_cli = Mov.IdCliente
LEFT  JOIN dbo.cat_prov proveedor		WITH(NOLOCK) ON proveedor.Id_prov = Mov.IdProveedor



GO

