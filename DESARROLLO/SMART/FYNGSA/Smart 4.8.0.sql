-- Registros:   0 = dejando los registro 0
--             -1 = Borrando toda las tablas    
--





declare @registros as int
set @registros = 0

delete from inv_kardex where id_kardex > 0 

delete from mon_tip_cam where id_tip_cam > 0 

delete from sis_notas where id_nota > 0

delete from inv_mov_tom_tmp where id_pro > 0 
delete from inv_mov_tom_det where id_inv_tom_part > 0
delete from inv_mov_tom where id_inv > 0

delete from cxc_aux where id_cxc_aux > 0
delete from cxp_aux where id_cxp_aux > 0

delete from vta_cobros where id_vta_cob > 0

delete from vta_mov_caj where id_mov > 0
delete from vta_cortes_det where id_caja > 0 and id_corte > 0
delete from vta_cortes where id_corte > 0

delete from inv_mov_part where id_inv_mov_part > 0
delete from inv_mov_doc where id_mov_inv > 0


update inv_pro_almac
set id_alm = 1
where id_pro > 0

update cat_doctos
set num_doc = 1

update sis_doctos_ser
set num_doc = 1


/* Ventas */

delete from vta_mov_part_kit where id_part > 0
delete from vta_mov_part where id_part > 0
delete from vta_mov_doc where id_doc > 0
delete from vta_fac_det_kit where id_fac_det > 0
delete from vta_fac_det where id_fac_det > 0 
update vta_fac_det set id_almac = 0 where id_fac_det = 0
delete from vta_fac_det_tmp where id_fac_det > 0 
delete from vta_fac_enc_clie where id_fact > 0 
delete from tCTLbitacoraCfdi 
delete from vta_fac_enc where id_fac > 0 
delete from vta_fac_enc_tmp where id_fac > 0 
delete from vta_prg_ent where id_prg_ent > 0

delete from pro_rpt_lot_tmp where id_orden > 0
delete from pro_rpt_det_tmp where id_orden > 0
delete from pro_ord where id_ord_pro > 0
delete from pro_rpt_det where id_rpt_pro > 0
delete from pro_rpt_enc where id_pro > 0

delete from inv_mov_ser_lot where id_mov_ser_lot > 0
delete from inv_ser_lot where id_ser_lot > 0

delete from cat_car where id_car > 0
delete from sis_rel_clas where id_rel_clas > 0
delete from cat_clas where id_clas > 0
delete from cat_clas_gral where id_clas_gral > 0
delete from cat_clas_gtos where id_cla_gto > 0
delete from cat_clas_pro where id_clas > 0
delete from cat_pro_lis_pre where id_pro_lis > 0
delete from cat_proins where id_proins > 0


delete from com_mov_part where id_part > 0
delete from com_mov_doc where id_compra > 0

/* CxC */
delete from cxc_cobros_det where id_cobro > 0
delete from cxc_cobros where id_cobro > 0
delete from cxc_nc_det where id_nc > 0
delete from cxc_nc where id_nc > 0
delete from cxc_doc where id_cxc_doc > 0


/* CxP*/
delete from cxp_doc where id_cxp_doc > 0
delete from cxp_doc_det where id_cxp_doc_det > 0
delete from cxp_pagos_det where id_pago > 0
delete from cxp_pagos where id_pago > 0

delete from sis_cam_ext where id_pantalla > 0
delete from sis_cierres where id_cierre > 0

delete from cat_cajas where id_caja > 0
insert into cat_cajas
values (1, 'CAJA PRINCIPAL', 0,'01/01/1900',0,0,0,0,0,0,0	)

delete from inv_pro_almac where id_alm > 1
update inv_pro_almac 
set id_alm = 0

delete from inv_mov_ser_lot_tmp_doc where id_mov_ser_lot > 0
delete from cat_almac where id_almac > 0
insert into cat_almac
values (1, 1, 'GENERAL', 1, 0)
insert into cat_almac
values (2, 1, 'CONSIGNACION', 1, 1)

/* Catálogo de vendedores  */
delete cat_vend where id_vend > 0

/* Catálogo de ubicaciones  */
delete cat_ubicacion where id_ubi > 0

/* Catálogo de productos y datos de producción */
delete from pro_cto_val_agr where id_tip_cto > 0 
delete from pro_est_pro_cto where id_est_pro_cto > 0
delete from pro_lis_mat where id_lis_mat > 0


delete from cat_pro_img where id_pro > 0
delete from cat_kit where id_pro > 0 
delete from inv_pro_almac where id_pro > 0

delete from sis_rel_car where id_pro > 0
delete from cat_pro where id_pro > 0

/* Catálogo de clientes   */
delete from cat_clientes_dir where id_cli > 0
delete from cat_clientes where id_cli > 0 and sistema = 0

/* Catálogo de proveedores   */
delete from cat_prov where id_prov > 0

/* Catálogo de gastos  */
delete from cat_gastos where id_gto > 0

/* Puestos  */
delete from cat_puestos where id_puesto > 0

/* Departamentos  */
delete from cat_depto where id_depto > 0

/* Areas  */
delete from cat_areas where id_area > 0

/* Empleado  */
delete from cat_emp where id_emp > 0

/* Clasificaciones*/
delete from cat_clasificaciones where id_clas > 0

/* Lista de Precio*/
delete from cat_lis_pre where id_lis_pre > 0

/* Medios de Envio */
delete from cat_med_env where id_med_env > 0

/* Almacenes */
delete from cat_almac where id_almac > 0



/* Bancos */
delete from bco_aux where id_bco_aux > 0
delete from bco_transferencias where id_bco_trn > 0
delete from bco_conc where id_conc > 0
delete from bco_doc_det where id_bco_doc_det > 0
delete from bco_doc where id_bco_doc > 0
delete from bco_cuentas where id_cta > 0
delete sis_conceptos where id_cpt > 0 and sistema = 0
delete bco_tip_trn where (not id_tip_trn between 98 and 128) and (not id_tip_trn between 0 and 8)
delete from bco_bancos where id_bco > 0
insert into bco_bancos Values(1,'BANCOMER','','','','','','',1)
insert into bco_bancos Values(2,'BANAMEX','','','','','','',1)
insert into bco_bancos Values(3,'SCOTIABANK INVERLAT','','','','','','',1)
insert into bco_bancos Values(4,'HSBC','','','','','','',1)
insert into bco_bancos Values(5,'BANORTE','','','','','','',1)
insert into bco_bancos Values(6,'SANTANDER SERFIN','','','','','','',1)
insert into bco_bancos Values(7,'BANCRECER','','','','','','',1)
insert into bco_bancos Values(8,'BANCO AZTECA','','','','','','',1)
insert into bco_bancos Values(9,'PARA CUENTAS DE CAJA','','','','','','',1)




/* Monedas */
delete from mon_tip_cam where id_tip_cam > 0
delete from mon_monedas where id_moneda > 1

/* Requisiciones */
delete from req_req_mat_det where id_req_mat_det > 0
delete from req_req_mat where id_req_mat > 0


/* Accesos al sistema solo deja el grupo 1 que es del supervisor */
delete from sis_accesos where id_grp > 1
update sis_accesos set permiso = 1 where id_acceso > 0
delete from cat_usr where id_usr > 1
delete from sis_grp where id_grp > 1

/* Otas tablas de sistema */
delete from sis_lab where id_lab > 0
delete from sis_mov_ser_lot where id_com_ser_lot > 0


/* Certificados de calidad */
delete from cca_cert  where id_cert > 0
delete from cca_cert_det  where id_cert_det > 0
delete from cca_esp_pro where id_esp_pro > 0
delete from cca_esp_pro2 where id_esp_pro2 > 0
delete from cca_esp where id_esp > 0
delete from cca_fesp where id_fesp > 0
delete from cca_ident where id_ident > 0
delete from cca_plan where id_plan > 0
delete from cca_plan_des where id_plan_des > 0
delete from cca_ref where id_ref > 0

/* Sistema */
delete from sis_cnl where id_sis_cnl > 0

/* DATOS DE LA EMPRESA */
--DELETE FROM CFG_EMPRESA
--INSERT INTO CFG_EMPRESA VALUES(1,'EMPRESA DEMOSTRATIVA','EMPRESA DEMOSTRATIVA','','','','',0,'','','','','')


/* Codigos de Servicio */
delete from sis_cod_svr where id_cod_svr > 0


/*Facturacion*/
DELETE FROM tCTLbitacoraCfdi WHERE Id > 0
DELETE FROM tCTLcertificadoCFDi WHERE Id > 0

DELETE FROM tCTLhistoricoCancelacionesCFDi WHERE IdHistoricoTimbradoCDFi > 0
DELETE FROM tCTLhistoricoTimbresCFDi WHERE IdHistoricoTimbradoCDFi > 0


DELETE FROM dbo.cfd_sat_arch WHERE id_fac > 0
DELETE FROM dbo.sis_arch WHERE id_arch > 0
DELETE FROM dbo.inv_mto_ser_lot WHERE id_mto_ser_lot > 0

DELETE FROM dbo.cat_cli_fa_cta WHERE id_cli_fa_cta > 0
DELETE FROM inv_mov_ser_lot_tmp WHERE id_tip_doc > 0
DELETE FROM pro_aju_mat_tmp WHERE id_lis_mat > 0
DELETE FROM sis_rel_obj_arch WHERE id_rel_obj_arch > 0
DELETE FROM cat_cli_fa_da WHERE id_cli_fa_da > 0



