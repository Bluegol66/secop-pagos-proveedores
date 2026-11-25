/* =====================================================================
   01_crear_base_y_tablas_raw.sql
   Crea la base de datos y carga los CSV tal como salieron del portal
   (todo como texto). No limpia nada: eso se hace en los scripts 02 y 03.

   ANTES DE EJECUTAR, copiar los CSV a C:\datos_secop con estos nombres:
     contratos_limpio.csv -> contratos del Valle, 22 columnas
     pagos.csv            -> Plan de pagos, 34 columnas (exportación completa)

   Los CSV y las tablas raw_* tienen datos de personas: NO se publican.

   El script se puede repetir sin riesgo: solo carga una tabla si está vacía.
   ===================================================================== */
IF DB_ID('SECOP_PAGOS') IS NULL CREATE DATABASE SECOP_PAGOS;
GO
USE SECOP_PAGOS;
GO

/* ---------- raw_contratos (22 columnas) ---------- */
IF OBJECT_ID('dbo.raw_contratos') IS NULL
CREATE TABLE dbo.raw_contratos (
    nombre_entidad         nvarchar(300) NULL,
    nit_entidad            nvarchar(50)  NULL,
    departamento           nvarchar(100) NULL,
    ciudad                 nvarchar(100) NULL,
    sector                 nvarchar(200) NULL,
    rama                   nvarchar(100) NULL,
    id_contrato            nvarchar(50)  NULL,
    estado_contrato        nvarchar(100) NULL,
    tipo_de_contrato       nvarchar(200) NULL,
    modalidad_contratacion nvarchar(300) NULL,
    fecha_de_firma         nvarchar(50)  NULL,
    fecha_de_inicio        nvarchar(50)  NULL,
    fecha_de_fin           nvarchar(50)  NULL,
    proveedor_adjudicado   nvarchar(500) NULL,
    es_pyme                nvarchar(20)  NULL,
    origen_de_los_recursos nvarchar(300) NULL,
    valor_del_contrato     nvarchar(50)  NULL,
    valor_facturado        nvarchar(50)  NULL,
    valor_pendiente_pago   nvarchar(50)  NULL,
    valor_pagado           nvarchar(50)  NULL,
    codigo_entidad         nvarchar(50)  NULL,
    codigo_proveedor       nvarchar(50)  NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM dbo.raw_contratos)
    BULK INSERT dbo.raw_contratos
    FROM 'C:\datos_secop\contratos_limpio.csv'
    WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001', TABLOCK);
GO

/* ---------- raw_pagos (34 columnas, mismo orden que el portal) ---------- */
IF OBJECT_ID('dbo.raw_pagos') IS NULL
CREATE TABLE dbo.raw_pagos (
    Id_del_Contrato                      nvarchar(max) NULL,
    ID_de_pago                           nvarchar(max) NULL,
    Numero_de_factura                    nvarchar(max) NULL,
    Fecha_de_emision                     nvarchar(max) NULL,
    Fecha_de_recepcion                   nvarchar(max) NULL,
    Valor_neto_de_la_factura             nvarchar(max) NULL,
    Valor_total_de_la_factura            nvarchar(max) NULL,
    Valor_a_pagar                        nvarchar(max) NULL,
    Estado                               nvarchar(max) NULL,
    Obligado_a_facturar_electrónicamente nvarchar(max) NULL,
    CUFE                                 nvarchar(max) NULL,
    Fecha_de_emisión                     nvarchar(max) NULL,
    Fecha_de_vencimiento                 nvarchar(max) NULL,
    Valor_neto                           nvarchar(max) NULL,
    Valor_total                          nvarchar(max) NULL,
    Notas                                nvarchar(max) NULL,
    Fecha_de_Entrega_original            nvarchar(max) NULL,
    Número_de_radicación                 nvarchar(max) NULL,
    Fecha_de_recepción_original          nvarchar(max) NULL,
    Fecha_estimada_de_pago               nvarchar(max) NULL,
    Compromiso_presupuestal              nvarchar(max) NULL,
    Plan_de_recepción                    nvarchar(max) NULL,
    Fecha_real_de_pago                   nvarchar(max) NULL,
    Aprobado_por                         nvarchar(max) NULL,
    Codigo_Entidad                       nvarchar(max) NULL,
    NIT_Entidad                          nvarchar(max) NULL,
    Nombre_Entidad                       nvarchar(max) NULL,
    Referencia_Contrato                  nvarchar(max) NULL,
    Nombre_supervisor                    nvarchar(max) NULL,
    Tipo_documento_supervisor            nvarchar(max) NULL,
    Documento_supervisor                 nvarchar(max) NULL,
    Fecha_inicio_contrato                nvarchar(max) NULL,
    Nombre_proveedor                     nvarchar(max) NULL,
    Documento_proveedor                  nvarchar(max) NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM dbo.raw_pagos)
    BULK INSERT dbo.raw_pagos
    FROM 'C:\datos_secop\pagos.csv'
    WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001', TABLOCK);
GO
