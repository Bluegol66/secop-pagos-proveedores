/* =====================================================================
   02_limpiar_contratos.sql
   Crea dbo.contratos_limpia a partir de dbo.raw_contratos.

   Reglas:
   - codigo_entidad: se quitan puntos y comas.
   - Valores en pesos: se quita "$" y los puntos de miles; la coma decimal
     pasa a punto ($1.049.091.114,5 -> 1049091114.5).
   - Fechas: formato mes/día/año con AM/PM.
   - fecha_fin fuera de 2024-01-01 a 2050-12-31 queda vacía y se marca
     con fecha_fin_invalida = 1 (no se pierde la fila).
   ===================================================================== */
USE SECOP_PAGOS;
GO
SET LANGUAGE us_english;
GO
DROP TABLE IF EXISTS dbo.contratos_limpia;
GO
SELECT
    r.id_contrato,
    r.nombre_entidad,
    REPLACE(REPLACE(r.codigo_entidad, '.', ''), ',', '')  AS codigo_entidad,
    r.nit_entidad,
    r.departamento,
    r.ciudad,
    r.sector,
    r.rama,
    r.estado_contrato,
    r.tipo_de_contrato,
    r.modalidad_contratacion,
    r.proveedor_adjudicado,
    r.codigo_proveedor,
    r.es_pyme,
    r.origen_de_los_recursos,
    f.firma                                               AS fecha_firma,
    f.inicio                                              AS fecha_inicio,
    CASE WHEN f.fin >= '2024-01-01' AND f.fin < '2051-01-01'
         THEN f.fin END                                   AS fecha_fin,
    CASE WHEN f.fin IS NOT NULL
          AND NOT (f.fin >= '2024-01-01' AND f.fin < '2051-01-01')
         THEN 1 ELSE 0 END                                AS fecha_fin_invalida,
    TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(REPLACE(r.valor_del_contrato,   '$',''), '.',''), ',', '.')) AS valor_contrato,
    TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(REPLACE(r.valor_facturado,      '$',''), '.',''), ',', '.')) AS valor_facturado,
    TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(REPLACE(r.valor_pendiente_pago, '$',''), '.',''), ',', '.')) AS valor_pendiente_pago,
    TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(REPLACE(r.valor_pagado,         '$',''), '.',''), ',', '.')) AS valor_pagado
INTO dbo.contratos_limpia
FROM dbo.raw_contratos AS r
CROSS APPLY (
    SELECT
        TRY_CONVERT(datetime2(0), r.fecha_de_firma,  101) AS firma,
        TRY_CONVERT(datetime2(0), r.fecha_de_inicio, 101) AS inicio,
        TRY_CONVERT(datetime2(0), r.fecha_de_fin,    101) AS fin
) AS f;
GO
