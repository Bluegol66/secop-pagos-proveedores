/* =====================================================================
   06_verificacion.sql
   Compara lo que hay en la base con las cifras verificadas del proyecto.
   Si todas las filas dicen OK, los scripts 01 a 05 reproducen el análisis.
   Una captura de este resultado sirve de evidencia en el README.

   Cifras esperadas (datos extraídos el 12/11/2026):
   - 295.783 contratos del Valle y 102.291 pagos en bruto
   - 102.199 pagos limpios (se eliminan 92 duplicados exactos)
   - 218 fechas de fin de contrato imposibles y 160 pagos con fecha imposible
   - 64.754 pagos medibles, de los cuales 30.645 tardíos
   - 333 entidades, 49 de ellas con registro de ejecución
   ===================================================================== */
USE SECOP_PAGOS;
GO
SELECT prueba, obtenido, esperado,
       CASE WHEN obtenido = esperado THEN 'OK' ELSE 'REVISAR' END AS resultado
FROM (
    SELECT 'filas raw_contratos'            AS prueba, (SELECT COUNT(*) FROM dbo.raw_contratos)  AS obtenido, 295783 AS esperado
    UNION ALL SELECT 'filas raw_pagos',               (SELECT COUNT(*) FROM dbo.raw_pagos),                    102291
    UNION ALL SELECT 'filas contratos_limpia',        (SELECT COUNT(*) FROM dbo.contratos_limpia),             295783
    UNION ALL SELECT 'filas pagos_limpia',            (SELECT COUNT(*) FROM dbo.pagos_limpia),                 102199
    UNION ALL SELECT 'fechas de fin invalidas',       (SELECT SUM(fecha_fin_invalida) FROM dbo.contratos_limpia), 218
    UNION ALL SELECT 'pagos con fecha invalida',      (SELECT SUM(CAST(fecha_invalida AS int)) FROM dbo.pagos_limpia), 160
    UNION ALL SELECT 'entidades en entidad_calidad',  (SELECT COUNT(*) FROM dbo.entidad_calidad),              333
    UNION ALL SELECT 'entidades que registran ejecucion', (SELECT COUNT(*) FROM dbo.entidad_calidad WHERE registra_ejecucion = 1), 49
    UNION ALL SELECT 'pagos medibles',                (SELECT SUM(es_medible) FROM dbo.v_pagos_analisis),      64754
    UNION ALL SELECT 'pagos tardios',                 (SELECT SUM(es_tardio)  FROM dbo.v_pagos_analisis),      30645
) AS t;
GO
