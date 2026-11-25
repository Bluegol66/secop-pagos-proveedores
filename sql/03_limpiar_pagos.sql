/* =====================================================================
   03_limpiar_pagos.sql
   Crea dbo.pagos_limpia a partir de dbo.raw_pagos, en una sola pasada.

   Reglas:
   - Se conservan solo las 16 columnas útiles (sin CUFE, notas, supervisor
     ni documentos de personas).
   - codigo_entidad: se quitan puntos y comas.
   - Valores: se quitan las comas de miles (el decimal ya viene con punto).
   - Fechas: mes/día/año con AM/PM, o formato "2026 Feb 09". Se quita la hora.
   - Duplicados: se elimina una copia de las filas totalmente idénticas.
     Las filas que solo comparten id_contrato + id_pago pero difieren en otros
     campos son pagos distintos y se conservan.
   - Fechas imposibles: vencimiento y fecha estimada fuera de 2024-01-01 a
     2028-12-31, o fecha real fuera de 2024-01-01 a 2026-11-12, quedan vacías
     y la fila se marca con fecha_invalida = 1.
   - dias_vs_vencimiento = fecha real de pago - fecha de vencimiento
     (positivo = pago tardío, negativo = pago anticipado).

   NO EJECUTAR si dbo.raw_pagos está vacía: esta tabla se borra y se recrea.
   ===================================================================== */
USE SECOP_PAGOS;
GO
SET LANGUAGE us_english;
GO
DROP TABLE IF EXISTS dbo.pagos_limpia;
GO
WITH conv AS (
    SELECT
        p.Id_del_Contrato                                       AS id_contrato,
        p.ID_de_pago                                            AS id_pago,
        p.Numero_de_factura                                     AS numero_factura,
        REPLACE(REPLACE(p.Codigo_Entidad, '.', ''), ',', '')    AS codigo_entidad,
        p.Nombre_Entidad                                        AS nombre_entidad,
        p.Estado                                                AS estado,
        p.Compromiso_presupuestal                               AS compromiso_presupuestal,
        CAST(f.emision     AS date)                             AS fecha_emision,
        CAST(f.recepcion   AS date)                             AS fecha_recepcion,
        CAST(f.vencimiento AS date)                             AS venc_orig,
        CAST(f.estimada    AS date)                             AS est_orig,
        CAST(f.real_pago   AS date)                             AS real_orig,
        TRY_CONVERT(decimal(18,2), REPLACE(p.Valor_neto_de_la_factura,  ',', '')) AS valor_neto,
        TRY_CONVERT(decimal(18,2), REPLACE(p.Valor_total_de_la_factura, ',', '')) AS valor_total,
        TRY_CONVERT(decimal(18,2), REPLACE(p.Valor_a_pagar,             ',', '')) AS valor_a_pagar
    FROM dbo.raw_pagos AS p
    CROSS APPLY (
        SELECT
            COALESCE(TRY_CONVERT(datetime2(0), p.Fecha_de_emision,       101), TRY_CONVERT(datetime2(0), p.Fecha_de_emision))       AS emision,
            COALESCE(TRY_CONVERT(datetime2(0), p.Fecha_de_recepcion,     101), TRY_CONVERT(datetime2(0), p.Fecha_de_recepcion))     AS recepcion,
            COALESCE(TRY_CONVERT(datetime2(0), p.Fecha_de_vencimiento,   101), TRY_CONVERT(datetime2(0), p.Fecha_de_vencimiento))   AS vencimiento,
            COALESCE(TRY_CONVERT(datetime2(0), p.Fecha_estimada_de_pago, 101), TRY_CONVERT(datetime2(0), p.Fecha_estimada_de_pago)) AS estimada,
            COALESCE(TRY_CONVERT(datetime2(0), p.Fecha_real_de_pago,     101), TRY_CONVERT(datetime2(0), p.Fecha_real_de_pago))     AS real_pago
    ) AS f
),
dedup AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY id_contrato, id_pago, numero_factura, codigo_entidad, nombre_entidad,
                            estado, compromiso_presupuestal, fecha_emision, fecha_recepcion,
                            venc_orig, est_orig, real_orig, valor_neto, valor_total, valor_a_pagar
               ORDER BY (SELECT NULL)) AS rn
    FROM conv
),
rango AS (
    SELECT d.*,
        CASE WHEN d.venc_orig BETWEEN '2024-01-01' AND '2028-12-31' THEN d.venc_orig END AS fecha_vencimiento,
        CASE WHEN d.est_orig  BETWEEN '2024-01-01' AND '2028-12-31' THEN d.est_orig  END AS fecha_estimada_pago,
        CASE WHEN d.real_orig BETWEEN '2024-01-01' AND '2026-11-12' THEN d.real_orig END AS fecha_real_pago
    FROM dedup AS d
    WHERE d.rn = 1
)
SELECT
    id_contrato, id_pago, numero_factura, codigo_entidad, nombre_entidad,
    estado, compromiso_presupuestal,
    fecha_emision, fecha_recepcion, fecha_vencimiento, fecha_estimada_pago, fecha_real_pago,
    valor_neto, valor_total, valor_a_pagar,
    CASE WHEN fecha_real_pago IS NOT NULL AND fecha_vencimiento IS NOT NULL
         THEN DATEDIFF(day, fecha_vencimiento, fecha_real_pago) END    AS dias_vs_vencimiento,
    CASE WHEN fecha_real_pago IS NOT NULL AND fecha_estimada_pago IS NOT NULL
         THEN DATEDIFF(day, fecha_estimada_pago, fecha_real_pago) END  AS dias_vs_estimada,
    CAST(CASE WHEN (venc_orig IS NOT NULL AND fecha_vencimiento   IS NULL)
                OR (est_orig  IS NOT NULL AND fecha_estimada_pago IS NULL)
                OR (real_orig IS NOT NULL AND fecha_real_pago     IS NULL)
              THEN 1 ELSE 0 END AS bit)                                AS fecha_invalida
INTO dbo.pagos_limpia
FROM rango;
GO
