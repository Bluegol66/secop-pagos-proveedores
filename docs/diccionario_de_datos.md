# Diccionario de datos

Proyecto: análisis de contratación y pagos de entidades públicas (SECOP II).

## Fuentes

| Conjunto | Identificador en datos.gov.co | Filtro aplicado | Filas |
|---|---|---|---|
| SECOP II – Contratos Electrónicos | `jbjy-vk9h` | Departamento = Valle del Cauca; fecha de firma del 01/01/2024 al 01/11/2026 | 295.783 |
| SECOP II – Plan de pagos | `uymx-8p3j` | Fecha de emisión del 01/01/2024 al 01/11/2026; sin filtro de entidad (todo el país) | 102.291 |

Fecha de extracción: 12/11/2026. Los pagos o contratos registrados después de esa fecha no están incluidos.

El conjunto SECOP II – Facturas (`ibyt-yi2f`) no se usa en esta versión.

## Convención de nombres

- `raw_*`: copia fiel de lo descargado, todo como texto. No se modifica y **no se publica** (contiene datos de personas).
- `*_limpia`: tablas con tipos de datos correctos y reglas de calidad aplicadas.
- `v_*`: vistas para análisis y para Power BI.

## Tablas

### `contratos_limpia` (una fila por contrato)

| Columna | Tipo | Descripción |
|---|---|---|
| `id_contrato` | texto | Identificador del contrato (`CO1.PCCNTR.xxxxxxx`). Único. Llave para cruzar con pagos |
| `nombre_entidad` | texto | Entidad contratante |
| `codigo_entidad` | texto | Código de la entidad, sin puntos ni comas |
| `nit_entidad` | texto | NIT de la entidad |
| `departamento`, `ciudad` | texto | Ubicación de la entidad |
| `sector`, `rama` | texto | Clasificación de la entidad |
| `estado_contrato` | texto | Estado del contrato en SECOP II |
| `tipo_de_contrato` | texto | Por ejemplo: Prestación de servicios, Obra, Suministros |
| `modalidad_contratacion` | texto | Modalidad de selección |
| `proveedor_adjudicado` | texto | Contratista. **Puede ser una persona natural; no se publica** |
| `codigo_proveedor` | texto | Código del proveedor |
| `es_pyme` | texto | Si el proveedor es pyme |
| `origen_de_los_recursos` | texto | Fuente de los recursos |
| `fecha_firma` | datetime | Fecha de firma |
| `fecha_inicio` | datetime | Fecha de inicio. Vacía en 3.488 contratos (viene vacía en el origen) |
| `fecha_fin` | datetime | Fecha de fin. Queda vacía si es anterior a 2024 o posterior a 2050 |
| `fecha_fin_invalida` | bit | 1 si la fecha de fin original era imposible (218 contratos) |
| `valor_contrato` | decimal(18,2) | Valor del contrato en pesos |
| `valor_facturado` | decimal(18,2) | Valor facturado registrado por la entidad |
| `valor_pendiente_pago` | decimal(18,2) | Valor pendiente según el origen |
| `valor_pagado` | decimal(18,2) | Valor pagado **registrado en SECOP II** |

### `pagos_limpia` (una fila por pago)

| Columna | Tipo | Descripción |
|---|---|---|
| `id_contrato`, `id_pago` | texto | La pareja no es única: hay 45 parejas repetidas que corresponden a 127 pagos distintos |
| `numero_factura` | texto | Número de factura |
| `codigo_entidad`, `nombre_entidad` | texto | Entidad que registra el pago (todo el país) |
| `estado` | texto | Estado del pago (Pagado, Aprobado, Enviado por proveedor...) |
| `compromiso_presupuestal` | texto | Compromiso presupuestal |
| `fecha_emision`, `fecha_recepcion` | date | Emisión y recepción de la factura |
| `fecha_vencimiento` | date | Vencimiento de la factura |
| `fecha_estimada_pago` | date | Fecha estimada de pago |
| `fecha_real_pago` | date | Fecha real de pago. Vacía si no se registró |
| `valor_neto`, `valor_total`, `valor_a_pagar` | decimal(18,2) | Valores de la factura |
| `dias_vs_vencimiento` | int | Fecha real de pago menos fecha de vencimiento. Positivo = pago tardío; negativo = pago anticipado |
| `dias_vs_estimada` | int | Fecha real de pago menos fecha estimada de pago |
| `fecha_invalida` | bit | 1 si alguna fecha original era imposible (160 pagos) |

### `entidad_calidad` (una fila por entidad)

| Columna | Descripción |
|---|---|
| `codigo_entidad`, `nombre_entidad` | Entidad |
| `contratos` | Contratos de la entidad en `contratos_limpia` |
| `con_registro` | Contratos con valor facturado o pagado mayor que cero |
| `pct_con_registro` | `con_registro` sobre `contratos`, en porcentaje |
| `registra_ejecucion` | 1 si la entidad tiene al menos 200 contratos y 50 % o más con registro; 0 en otro caso |

### `v_contratos_analisis` (vista)

`contratos_limpia` unida con `entidad_calidad`, sin los contratos de tipo "Operaciones de Crédito Público" y sin contratos de valor cero o negativo.

## Reglas de transformación

| Tema | Regla |
|---|---|
| Valores en contratos | Vienen como `$87.872.500` o `$6.004.676,4`. Se quita el `$` y los puntos, y la coma pasa a punto decimal |
| Valores en pagos | Vienen con comas de miles y punto decimal. Se quitan las comas |
| Códigos de entidad | En Contratos usan puntos (`704.246.180`) y en Pagos comas (`704,246,180`). Se quitan ambos |
| Fechas | Formato mes/día/año con AM/PM. Se convierten a fecha y se quita la hora |
| Fechas de pagos imposibles | Vencimiento y fecha estimada fuera de 2024 a 2028, o fecha real fuera de 2024 a 12/11/2026, pasan a vacío y la fila queda marcada con `fecha_invalida = 1` |
| Duplicados en pagos | Se eliminan 92 filas idénticas. Las filas que comparten solo la pareja `id_contrato` + `id_pago` pero difieren en otros campos se conservan |
