IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE t.object_id = OBJECT_ID('cat_barcos'))
CREATE TABLE dbo.cat_barcos 
(
IdBarco INT IDENTITY (1, 1) PRIMARY KEY (IdBarco),
Codigo VARCHAR(16),
Descripcion VARCHAR(256),
IdEstatus INT
)
GO

IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE object_id = OBJECT_ID('vta_fac_enc_operador'))
BEGIN
CREATE TABLE dbo.vta_fac_enc_operador
(
    id INT IDENTITY(0, 1) PRIMARY KEY (id),
	id_fac INT  CONSTRAINT FK_vta_fac_enc_vta_fac_enc_operador_id_fac FOREIGN KEY (id_fac) REFERENCES dbo.vta_fac_enc (id_fac),
    Operador VARCHAR(256),
    Placas VARCHAR(256),
    TarjetaCirculacion VARCHAR(256),
    LicenciaOperador VARCHAR(256)
);
END;
GO

SET IDENTITY_INSERT dbo.cat_barcos ON
IF NOT EXISTS (SELECT 1 FROM dbo.cat_barcos WHERE cat_barcos.IdBarco = 0)
	INSERT INTO dbo.cat_barcos (IdBarco) VALUES (0);
SET IDENTITY_INSERT dbo.cat_barcos OFF

GO
IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdBarco' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdBarco INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdCliente INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD IdProveedor INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot ADD Ticket2RecepcionFolio INT NULL END 

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
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdBarco INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdCliente INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD IdProveedor INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPeso' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPesoReal' AND columna.object_id = object_id ('inv_mov_ser_lot_tmp')) 
BEGIN ALTER TABLE dbo.inv_mov_ser_lot_tmp ADD Ticket2RecepcionPesoReal NUMERIC(18, 2) NULL END 


/*inv_mto_ser_lot*/

GO
IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdBarco' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdBarco INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdCliente' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdCliente INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='IdProveedor' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD IdProveedor INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1OrigenPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2OrigenFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2OrigenPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2OrigenPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket1RecepcionPesoReal' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket1RecepcionPesoReal NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionFolio' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionFolio INT NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPeso' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionPeso NUMERIC(18, 2) NULL END 

IF NOT EXISTS(SELECT 1 FROM sys.columns columna WHERE columna.name ='Ticket2RecepcionPesoReal' AND columna.object_id = object_id ('inv_mto_ser_lot')) 
BEGIN ALTER TABLE dbo.inv_mto_ser_lot ADD Ticket2RecepcionPesoReal NUMERIC(18, 2) NULL END 

INSERT INTO cfg_global(id_cfg_glb, campo, descripcion, Valor, fecha, id_mod)
SELECT 52, 'MostrarFrameTicket','Mostrar Frame Ticket', '0', GETDATE(),0