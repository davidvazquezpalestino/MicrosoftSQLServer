
IF NOT EXISTS (SELECT 1 FROM dbo.cfg_version WHERE Versión = '4.9.0')
INSERT INTO dbo.cfg_version(Versión, Fecha) VALUES ('4.9.0', CURRENT_TIMESTAMP)
GO	

IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE t.object_id = OBJECT_ID('cat_barcos'))
CREATE TABLE dbo.cat_barcos 
(
IdBarco INT IDENTITY (1, 1) PRIMARY KEY (IdBarco),
Codigo VARCHAR(16),
Descripcion VARCHAR(256),
IdEstatus INT NOT NULL DEFAULT 0
)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE object_id = OBJECT_ID('vta_fac_enc_operador'))
BEGIN
CREATE TABLE dbo.vta_fac_enc_operador
(
    id INT IDENTITY(0, 1) PRIMARY KEY (id),
	id_fac INT DEFAULT 0 CONSTRAINT FK_vta_fac_enc_vta_fac_enc_operador_id_fac FOREIGN KEY (id_fac) REFERENCES dbo.vta_fac_enc (id_fac),
    Operador VARCHAR(256),
    Placas VARCHAR(256),
    TarjetaCirculacion VARCHAR(256),
    LicenciaOperador VARCHAR(256),
	IdCompra INT,
	NumeroTalon varchar (32)
);
END;
GO

SET IDENTITY_INSERT dbo.cat_barcos ON
IF NOT EXISTS (SELECT 1 FROM dbo.cat_barcos WHERE cat_barcos.IdBarco = 0)
	INSERT INTO dbo.cat_barcos (IdBarco) VALUES (0);
SET IDENTITY_INSERT dbo.cat_barcos OFF

GO
IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdBarco' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdBarco INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdCliente INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdProveedor INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = OBJECT_ID('inv_mov_ser_lot') and fk.name = 'FK_inv_mov_ser_lot_cat_barcos_IdBarco')
ALTER TABLE dbo.inv_mov_ser_lot ADD CONSTRAINT FK_inv_mov_ser_lot_cat_barcos_IdBarco FOREIGN KEY (IdBarco) REFERENCES dbo.cat_barcos(IdBarco)

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = OBJECT_ID('inv_mov_ser_lot') and fk.name = 'FK_inv_mov_ser_lot_cat_prov_IdProveedor')
ALTER TABLE dbo.inv_mov_ser_lot ADD CONSTRAINT FK_inv_mov_ser_lot_cat_prov_IdProveedor FOREIGN KEY (IdProveedor) REFERENCES dbo.cat_prov(Id_prov)

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = OBJECT_ID('inv_mov_ser_lot') and fk.name = 'FK_inv_mov_ser_lot_cat_clientes_IdCliente')
ALTER TABLE dbo.inv_mov_ser_lot ADD CONSTRAINT FK_inv_mov_ser_lot_cat_clientes_IdCliente FOREIGN KEY (IdCliente) REFERENCES dbo.cat_clientes(id_cli)

/*tabla temporal*/


GO
IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdBarco' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdBarco INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdCliente INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdProveedor INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionPesoReal NUMERIC(18, 2) NULL END 


/*inv_mto_ser_lot*/

GO
IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdBarco' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdBarco INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdCliente INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdProveedor INT NOT NULL DEFAULT 0 END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2OrigenFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionFolio VARCHAR(64) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPesoReal' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS (SELECT 1 FROM cfg_global WHERE id_cfg_glb = 52)
BEGIN
	INSERT INTO cfg_global(id_cfg_glb, campo, descripcion, Valor, fecha, id_mod)
	SELECT 52, 'MostrarFrameTicket','Mostrar Frame Ticket', '0', GETDATE(),0	
END

IF NOT EXISTS(SELECT id_rec FROM sis_recursos WHERE id_rec =  716)
BEGIN	    
	INSERT INTO sis_recursos(id_rec, des, mod, status, id_mod, tipo, frm, id_img, id_rec_pad, orden, modo, Nivel, descripcion)    
	VALUES (716, 'Origenes', 'CT', 1, 15, 1, 'cat_barcos', 2, 1, '19-13-00-00-00-00', 1, 1, '') 
END 

DECLARE @id_acceso AS INT;
SELECT @id_acceso = MAX(id_acceso) + 1
FROM dbo.sis_accesos

IF NOT EXISTS (SELECT 1 FROM sis_accesos WHERE id_rec = 716 AND id_grp = 1)
INSERT INTO dbo.sis_accesos(id_acceso, id_grp, id_rec, permiso) VALUES (@id_acceso, 1, 716, 1 )

GO
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
			ProductoCodigo = producto.codigo,
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
/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  13/09/2017
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vt_fmt_inv_kardex'))
	DROP VIEW dbo.vt_fmt_inv_kardex
GO

CREATE VIEW dbo.vt_fmt_inv_kardex	
	AS	
SELECT      documento.id_doc, 
			Movimiento = CASE kardex.id_sis_cnl WHEN 0 THEN documento.descripcion ELSE '**CANC**' + documento.descripcion END ,
            Folio	   = kardex.num_doc, 
			Fecha = CAST(kardex.fecha AS DATE), 
			Producto = producto.des,
			producto.udm_inv,

			producto.presentacion,
			ProductoMarca = producto.marca,

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
		   operador.LicenciaOperador,	
		   operador.NumeroTalon,	   	 
			nota.nota 	
					   
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

LEFT  JOIN dbo.sis_notas nota			WITH(NOLOCK) ON nota.id_nota = fac.id_nota
LEFT  JOIN dbo.vta_fac_enc_operador operador WITH(NOLOCK) ON operador.id_fac = fac.id_fac
LEFT  JOIN dbo.cat_barcos	barco		WITH(NOLOCK) ON barco.IdBarco = Mov.IdBarco
LEFT  JOIN dbo.cat_clientes cliente		WITH(NOLOCK) ON cliente.id_cli = Mov.IdCliente
LEFT  JOIN dbo.cat_prov proveedor		WITH(NOLOCK) ON proveedor.Id_prov = Mov.IdProveedor

GO


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


/*Procedimientos Modificados*/


IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('sp_inv_mov_ser'))
DROP PROCEDURE sp_inv_mov_ser
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

CREATE  PROCEDURE [dbo].[sp_inv_mov_ser]
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
@Ticket1OrigenFolio as  VARCHAR(64) = '', 
@Ticket1OrigenPeso as  NUMERIC (18,2) = 0, 
@Ticket2OrigenFolio as  VARCHAR(64) = '', 
@Ticket2OrigenPeso as  NUMERIC (18,2)= 0, 
@Ticket1RecepcionFolio as  VARCHAR(64) = '', 
@Ticket1RecepcionPeso as  numeric (18,2)= 0, 
@Ticket1RecepcionPesoReal as  numeric (18,2)= 0, 
@Ticket2RecepcionFolio as  VARCHAR(64) = '', 
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


IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('sp_inv_mto_ser_lot'))
DROP PROCEDURE sp_inv_mto_ser_lot
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

CREATE PROCEDURE [dbo].[sp_inv_mto_ser_lot]
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


@IdBarco AS  int = 0, 
@IdCliente AS  int = 0, 
@IdProveedor AS  int = 0, 
@Ticket1OrigenFolio AS  VARCHAR(64) = '', 
@Ticket1OrigenPeso AS  NUMERIC (18,2) = 0, 
@Ticket2OrigenFolio AS  VARCHAR(64) = '', 
@Ticket2OrigenPeso AS  NUMERIC (18,2)= 0, 
@Ticket1RecepcionFolio AS  VARCHAR(64) = '', 
@Ticket1RecepcionPeso AS  NUMERIC (18,2)= 0, 
@Ticket1RecepcionPesoReal AS  NUMERIC (18,2)= 0, 
@Ticket2RecepcionFolio AS  VARCHAR(64) = '', 
@Ticket2RecepcionPeso AS  NUMERIC (18,2)= 0, 
@Ticket2RecepcionPesoReal AS  NUMERIC (18,2)= 0

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


IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('sp_inv_ser'))
	DROP PROCEDURE sp_inv_ser
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

CREATE PROCEDURE [dbo].[sp_inv_ser]
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
@Ticket1OrigenFolio as  VARCHAR(64) = '', 
@Ticket1OrigenPeso as  NUMERIC (18,2) = 0, 
@Ticket2OrigenFolio as  VARCHAR(64) = '', 
@Ticket2OrigenPeso as  NUMERIC (18,2)= 0, 
@Ticket1RecepcionFolio as  VARCHAR(64) = '', 
@Ticket1RecepcionPeso as  NUMERIC (18,2)= 0, 
@Ticket1RecepcionPesoReal as  NUMERIC (18,2)= 0, 
@Ticket2RecepcionFolio as  VARCHAR(64) = '', 
@Ticket2RecepcionPeso as  NUMERIC (18,2)= 0, 
@Ticket2RecepcionPesoReal as  NUMERIC (18,2)= 0

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
      Update inv_ser_lot set existencia = round(existencia + @cant,@dec_existencia),disponible = round(disponible + @cant,@dec_existencia),existencia_brix = round(existencia_brix + @cant_brix,@dec_existencia) where id_ser_lot = @id_ser
    End



GO


IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFMTremision'))
	DROP VIEW dbo.vFMTremision
GO

CREATE VIEW dbo.vFMTremision
	AS 
SELECT IdComprobante = Comprobante.id_fac,
       Folio = Comprobante.numero,
       IdTipoDocumento = Comprobante.id_tipo_doc,
       Sucursal = Comprobante.ref,
       Documento = Documento.descripcion,
       Fecha = CAST(Comprobante.fecha AS DATE),
       Comprobante.no_ped_cli,
       Comprobante.no_req_cli,

       Cliente = CONCAT(Cliente.rfc, IIF(Cliente.rfc = '', '', ' - '), Cliente.nom1),
       
	   MedioEnvio = MedioEnvio.des,
	   Vendedor = IIF(Vendedor.id_vend = 0, ' ', Vendedor.nombre),
	   Operador = Operador.Operador,
       Placas = Operador.Placas,
       TarjetaCirculacion = Operador.TarjetaCirculacion,
       LicenciaOperador = Operador.LicenciaOperador,
       NumeroTalon = Operador.NumeroTalon,
       Nota = CASE WHEN Nota.id_nota = 0 THEN '' ELSE Nota.nota END

FROM dbo.vta_fac_enc			 Comprobante
INNER JOIN dbo.cat_clientes			 Cliente ON Cliente.id_cli = Comprobante.id_cli
INNER JOIN dbo.cat_doctos		   Documento ON Documento.id_doc = Comprobante.id_tipo_doc
INNER JOIN dbo.sis_notas				Nota ON Nota.id_nota = Comprobante.id_nota
INNER JOIN dbo.vta_fac_enc_operador Operador ON Operador.id_fac = Comprobante.id_fac 
INNER JOIN dbo.cat_vend				Vendedor ON Vendedor.id_vend = Cliente.id_vend
INNER JOIN dbo.cat_med_env        MedioEnvio ON Comprobante.id_med_env1 = MedioEnvio.id_med_env

GO

IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFMTdetalleRemision'))
	DROP VIEW dbo.vFMTdetalleRemision
GO

CREATE VIEW dbo.vFMTdetalleRemision
	AS
SELECT IdComprobante = id_fac,
       
	   Partida = DetalleComprobante.no_part,

	   IdProducto = Producto.id_pro,
       ProductoCodigo = Producto.codigo,
       Producto = Producto.des,
       Presentacion = Producto.presentacion,
	   Cantidad = DetalleComprobante.cant,
       
	   IdAlmacen = Almacen.id_almac,
       Almacen   = Almacen.descripcion,
	   
	   UnidadMedida = DetalleComprobante.udm
   	   
FROM dbo.vta_fac_det  DetalleComprobante WITH(NOLOCK)
INNER JOIN dbo.cat_pro			Producto WITH(NOLOCK) ON Producto.id_pro = DetalleComprobante.id_pro
INNER JOIN dbo.cat_almac		 Almacen WITH(NOLOCK) ON Almacen.id_almac = DetalleComprobante.id_almac
GO


IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vt_inv_kardex'))
DROP VIEW dbo.vt_inv_kardex
GO

GO
CREATE VIEW [dbo].[vt_inv_kardex]
	AS
SELECT        dbo.cat_doctos.id_doc AS [Tipo Doc.], CASE id_sis_cnl WHEN 0 THEN dbo.cat_doctos.descripcion ELSE '**CANC**' + dbo.cat_doctos.descripcion END AS Movimiento,
                          dbo.inv_kardex.num_doc AS Número, dbo.inv_kardex.fecha, dbo.cat_pro.codigo AS ProductoCodigo, dbo.cat_pro.des AS Producto, CASE tipo_mov WHEN 0 THEN 'E' ELSE 'S' END AS Tipo, 
                         CASE Tipo_mov WHEN 0 THEN cant ELSE 0 END AS Cargo, CASE Tipo_Mov WHEN 1 THEN cant ELSE 0 END AS Abono, dbo.inv_kardex.costo AS [Cto. Uni.], 
                         dbo.inv_kardex.costo_prom AS [Cto. Prom.], dbo.inv_kardex.costo_total AS [Cto. Total], dbo.inv_kardex.existencia, dbo.cat_almac.descripcion AS Almacén, 
                         dbo.inv_kardex.id_pro, dbo.inv_kardex.id_kardex, dbo.cat_almac.id_almac, dbo.inv_kardex.serie, dbo.cat_doctos.prd_rcst, dbo.inv_kardex.id_sis_cnl, 
                         dbo.inv_kardex.tipo_mov, dbo.inv_kardex.existencia_alm
FROM            dbo.inv_kardex INNER JOIN
                         dbo.cat_usr ON dbo.inv_kardex.id_usr = dbo.cat_usr.id_usr INNER JOIN
                         dbo.cat_almac ON dbo.inv_kardex.id_almac = dbo.cat_almac.id_almac INNER JOIN
                         dbo.cat_pro ON dbo.inv_kardex.id_pro = dbo.cat_pro.id_pro INNER JOIN
                         dbo.cat_doctos ON dbo.inv_kardex.id_tipo_doc = dbo.cat_doctos.id_doc
GO

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
			ProductoCodigo = producto.codigo,
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

IF NOT EXISTS(SELECT id_cfg_glb FROM cfg_global WHERE id_cfg_glb =  53)     
INSERT INTO cfg_global(id_cfg_glb, campo, descripcion, Valor, fecha, id_mod)    
VALUES (53, 'ValidarExistCliente', 'Información Aduanera Será Obligatoria al Guardar', '1', '20171010', 0) 

GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  26/10/2017
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFMTInventarioCliente'))
	DROP VIEW dbo.vFMTInventarioCliente
GO

CREATE VIEW dbo.vFMTInventarioCliente
	AS
SELECT Inventario.num_lot,
	   IdCliente,
       Cliente = IIF(Cliente.id_cli = 0,' - ', Cliente.nom2),
       Producto.id_pro,
	   Producto.clave,
	   Producto = Producto.des,
	   Presentacion = Producto.presentacion,
	   Producto.udm_inv,
	   Inventario.existencia
FROM dbo.inv_mto_ser_lot Inventario

INNER JOIN dbo.cat_pro Producto ON Producto.id_pro = Inventario.id_pro
INNER JOIN dbo.cat_clientes Cliente ON Cliente.id_cli = Inventario.IdCliente

WHERE Inventario.id_mto_ser_lot > 0
GO

IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFMTinventarios'))
DROP VIEW dbo.vFMTinventarios
GO

CREATE VIEW [dbo].[vFMTinventarios]
	AS
SELECT Producto.id_pro,
       Producto = Producto.des,
	   Producto.codigo,
	   Producto.presentacion,
       Producto.udm_inv,

       Almacen.id_almac,
       Almacen = Almacen.descripcion,      	   
       Existencia = SUM(Inventario.existencia)

FROM dbo.inv_ser_lot Inventario
INNER JOIN dbo.cat_almac Almacen ON Almacen.id_almac = Inventario.id_almac
INNER JOIN dbo.cat_pro Producto ON Producto.id_pro = Inventario.id_pro
WHERE Inventario.id_ser_lot > 0
GROUP BY Producto.id_pro,
         Producto.des,
         Producto.codigo,
         Producto.presentacion,
         Producto.udm_inv,
         Almacen.id_almac,
         Almacen.descripcion        
HAVING SUM(Inventario.existencia) > 0

GO







