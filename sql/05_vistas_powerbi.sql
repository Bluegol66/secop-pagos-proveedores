/* =====================================================================
   05_vistas_powerbi.sql
   Vistas que consume Power BI. La lógica de negocio queda en SQL y no
   en el tablero.

   v_contratos_dashboard: contratos del Valle para analizar. No incluye
     nombre ni código de proveedor ni NIT (datos que pueden identificar
     personas).
   v_pagos_analisis: pagos con banderas listas para contar.
     es_medible = tiene fecha real y de vencimiento, y la diferencia está
                  entre -365 y 365 días (se excluyen 186 extremos).
     es_tardio  = es medible y se pagó después del vencimiento.
   ===================================================================== */
USE SECOP_PAGOS;
GO
CREATE OR ALTER VIEW dbo.v_contratos_dashboard AS
SELECT
    c.id_contrato,
    c.nombre_entidad,
    c.codigo_entidad,
    c.ciudad,
    c.sector,
    c.estado_contrato,
    c.tipo_de_contrato,
    c.modalidad_contratacion,
    c.es_pyme,
    c.origen_de_los_recursos,
    c.fecha_firma,
    YEAR(c.fecha_firma) AS anio_firma,
    c.valor_contrato,
    c.valor_facturado,
    c.valor_pendiente_pago,
    c.valor_pagado,
    CASE WHEN c.valor_facturado > 0 OR c.valor_pagado > 0 THEN 1 ELSE 0 END AS tiene_registro,
    c.pct_con_registro,
    c.registra_ejecucion,
    CASE WHEN c.registra_ejecucion = 1 THEN N'Registra ejecución'
         ELSE N'No registra ejecución' END AS grupo_entidad
FROM dbo.v_contratos_analisis AS c;
GO
CREATE OR ALTER VIEW dbo.v_pagos_analisis AS
SELECT
    p.id_contrato,
    p.id_pago,
    p.codigo_entidad,
    p.nombre_entidad,
    p.estado,
    p.fecha_emision,
    p.fecha_vencimiento,
    p.fecha_real_pago,
    DATEFROMPARTS(YEAR(p.fecha_real_pago), MONTH(p.fecha_real_pago), 1) AS mes_pago,
    p.valor_total,
    p.valor_a_pagar,
    p.dias_vs_vencimiento,
    p.fecha_invalida,
    CASE WHEN p.dias_vs_vencimiento BETWEEN -365 AND 365 THEN 1 ELSE 0 END AS es_medible,
    CASE WHEN p.dias_vs_vencimiento BETWEEN 1 AND 365    THEN 1 ELSE 0 END AS es_tardio,
    CASE
        WHEN p.dias_vs_vencimiento IS NULL THEN N'0. Sin dato'
        WHEN p.dias_vs_vencimiento < -365  THEN N'1. Más de 1 año antes'
        WHEN p.dias_vs_vencimiento < -30   THEN N'2. De 1 a 12 meses antes'
        WHEN p.dias_vs_vencimiento <= 0    THEN N'3. A tiempo (hasta 30 días antes)'
        WHEN p.dias_vs_vencimiento <= 30   THEN N'4. Hasta 30 días tarde'
        WHEN p.dias_vs_vencimiento <= 365  THEN N'5. De 31 a 365 días tarde'
        ELSE                                    N'6. Más de 1 año tarde'
    END AS rango_dias
FROM dbo.pagos_limpia AS p;
GO
