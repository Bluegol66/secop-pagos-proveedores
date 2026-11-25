/* =====================================================================
   04_calidad_entidades.sql
   1) dbo.entidad_calidad: una fila por entidad con cuántos de sus contratos
      tienen valor facturado o pagado registrado en SECOP II.
      registra_ejecucion = 1 si tiene al menos 200 contratos y 50 % o más
      con registro.
   2) dbo.v_contratos_analisis: contratos listos para analizar. Excluye
      las "Operaciones de Crédito Público" (deuda, no compras a proveedores)
      y los contratos de valor cero o negativo.
   ===================================================================== */
USE SECOP_PAGOS;
GO
DROP TABLE IF EXISTS dbo.entidad_calidad;
GO
WITH base AS (
    SELECT codigo_entidad,
           MIN(nombre_entidad) AS nombre_entidad,
           COUNT(*)            AS contratos,
           SUM(CASE WHEN valor_facturado > 0 OR valor_pagado > 0 THEN 1 ELSE 0 END) AS con_registro
    FROM dbo.contratos_limpia
    GROUP BY codigo_entidad
)
SELECT codigo_entidad, nombre_entidad, contratos, con_registro,
       CAST(100.0 * con_registro / contratos AS decimal(5,1)) AS pct_con_registro,
       CASE WHEN contratos >= 200 AND 100.0 * con_registro / contratos >= 50
            THEN 1 ELSE 0 END AS registra_ejecucion
INTO dbo.entidad_calidad
FROM base;
GO
CREATE OR ALTER VIEW dbo.v_contratos_analisis AS
SELECT c.*, e.pct_con_registro, e.registra_ejecucion
FROM dbo.contratos_limpia AS c
JOIN dbo.entidad_calidad AS e
    ON e.codigo_entidad = c.codigo_entidad
WHERE c.tipo_de_contrato <> N'Operaciones de Crédito Público'
  AND c.valor_contrato > 0;
GO
