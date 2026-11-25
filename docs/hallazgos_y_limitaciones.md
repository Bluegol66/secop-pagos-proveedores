# Hallazgos, reglas de calidad y limitaciones

Datos extraídos el 12/11/2026 de datos.gov.co (SECOP II). Cifras calculadas en SQL Server.

## Hallazgos

### 1. Pocas entidades del Valle registran la ejecución de sus contratos

De 332 entidades con contratos firmados desde 2024, solo 49 (15 %) registran facturación o pagos en al menos la mitad de sus contratos (criterio: mínimo 200 contratos y 50 % con registro).

| Grupo | Entidades | Contratos | Valor contratado | Pagado registrado | % pagado |
|---|---|---|---|---|---|
| Registran ejecución | 49 | 59.542 | $4,58 billones | $1,20 billones | 26,1 % |
| No registran ejecución | 283 | 235.534 | $17,68 billones | $0,29 billones | 1,6 % |

El grupo que registra concentra cerca del 81 % de todo el valor pagado que aparece en SECOP II.

**Cómo leerlo:** un valor pagado de cero no significa que no se haya pagado, sino que no hay un pago registrado en la plataforma. El 26,1 % no es la tasa de pago del Valle, porque el grupo se definió justamente por tener registros.

### 2. Los créditos públicos no son pagos a proveedores

Hay 18 contratos de tipo "Operaciones de Crédito Público" por unos $2,28 billones, con $0 pagado. Son operaciones de deuda, no compras, y se excluyen del análisis de proveedores.

### 3. La contratación se concentra en prestación de servicios

Prestación de servicios reúne 274.547 de 295.783 contratos (92,8 %) y $9,47 billones de valor contratado. Muchos de estos contratistas son personas naturales, por lo que los nombres de proveedores no se publican.

### 4. El módulo de pagos casi no lo usan las entidades del Valle

Plan de pagos trae 102.291 pagos de todo el país desde 2024. Solo 1.394 corresponden a entidades que tienen contratos en el Valle. Por eso el análisis de oportunidad de pago es **nacional**, y el análisis de contratación es **del Valle**.

### 5. Oportunidad de pago (nacional)

De 102.199 pagos limpios, 64.940 tienen fecha de vencimiento y fecha real de pago. De ellos, 186 (0,3 %) están a más de un año del vencimiento y se excluyen, así que la medición usa 64.754 pagos.

| Resultado | Pagos | Porcentaje |
|---|---|---|
| Pagados en la fecha o antes | 34.109 | 52,7 % |
| Pagados después del vencimiento | 30.645 | 47,3 % |

- 27.516 de los pagos tardíos (cerca del 90 %) se pagaron hasta 30 días después.
- 186 pagos (0,3 %) están a más de un año del vencimiento. Se excluyen de promedios y porcentajes, pero la fila se conserva.
- Se revisó si la hora de las fechas movía pagos de un día a otro. Hay más pagos en el día 0 (3.979) que en el día 1 (2.799), así que no se encontró evidencia de ese efecto. Hay picos en los días -1 y 2 que no se explican con estos datos.

## Problemas de calidad encontrados

| Problema | Detalle | Tratamiento |
|---|---|---|
| Formato de códigos distinto entre tablas | Puntos en Contratos, comas en Pagos | Se normalizan |
| Valores como texto | `$` y separadores colombianos | Se convierten a decimal |
| Fechas imposibles en contratos | 218 fechas de fin (años como 2006 o 2924) | Quedan vacías y marcadas |
| Fechas imposibles en pagos | 160 pagos con alguna fecha fuera de rango | Quedan vacías y marcadas |
| Filas duplicadas en pagos | 92 filas idénticas | Se elimina una copia |
| Parejas `id_contrato` + `id_pago` repetidas | 45 parejas, 127 pagos distintos | Se conservan |
| Fecha de inicio vacía | 3.488 contratos | Se deja vacía |
| Dos columnas de fecha de emisión | Iguales en 102.290 de 102.291 filas | Se usa una |
| Portal ignora la selección de columnas | El CSV llegó con todas las columnas | Se descartan en SQL |

## Limitaciones

- **Cobertura del registro:** los valores de facturado y pagado dependen de lo que cada entidad registra en SECOP II. No miden pagos reales.
- **Umbral de 200 contratos:** deja fuera entidades pequeñas con buen registro (por ejemplo, la Secretaría de Salud de Tuluá: 172 contratos, 90,7 % con registro).
- **Sesgo de selección:** al analizar el grupo de 49 entidades que registran ejecución, los resultados valen para ese grupo y no para todo el Valle.
- **Alcance geográfico de pagos:** Plan de pagos no tiene departamento. El análisis de oportunidad de pago es nacional.
- **Ventana de tiempo:** solo desde 2024 hasta el 01/11/2026. Los pagos de contratos firmados antes de 2024 no cruzan con la tabla de contratos.
- **Definición de "tarde":** pago con fecha real posterior al vencimiento, sin días de tolerancia.
- **Valor pendiente de pago:** por lo observado, parece el valor del contrato menos lo facturado, es decir, lo que falta por ejecutar. No debe leerse como deuda vencida. Esto es una deducción de los datos, no una definición oficial.

## Pendiente

- Anonimizar proveedores (código en lugar de nombre) antes de publicar datos.
- Decidir si se incorpora la tabla de Facturas.
