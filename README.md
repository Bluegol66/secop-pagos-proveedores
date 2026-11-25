# Contratación y pagos de entidades públicas en SECOP II

Proyecto de análisis de datos con información abierta de contratación estatal de Colombia (SECOP II). Se centra en las entidades públicas con contratos en el **Valle del Cauca** y en la **oportunidad de pago** de las entidades del país.

> Estado: análisis en SQL Server terminado. El tablero de Power BI está en construcción.

## Preguntas que responde

1. ¿Qué entidades del Valle registran en SECOP II la ejecución de sus contratos (facturas y pagos)?
2. ¿Cuánto se contrató y cuánto aparece como pagado?
3. ¿Los pagos se hacen antes o después de la fecha de vencimiento?

## Herramientas

* SQL Server Express y SQL Server Management Studio: carga, limpieza y análisis.
* Power BI: tablero (en construcción).
* Git y GitHub: control de versiones.

## Datos

|Conjunto|Identificador en datos.gov.co|Filtro|Filas|
|-|-|-|-|
|SECOP II – Contratos Electrónicos|`jbjy-vk9h`|Valle del Cauca, contratos firmados del 01/01/2024 al 01/11/2026|295.783|
|SECOP II – Plan de pagos|`uymx-8p3j`|Facturas emitidas del 01/01/2024 al 01/11/2026, todo el país|102.291|

Fecha de extracción: 12/11/2026.

Los datos originales **no están en este repositorio**. Contienen información de personas (por ejemplo, contratistas que son personas naturales), por eso solo se publican los scripts, la documentación y capturas sin nombres de proveedores. Los CSV se descargan del portal de datos abiertos.

## Estructura del repositorio

```
sql/        scripts numerados, en el orden en que se ejecutan
docs/       diccionario de datos, hallazgos y limitaciones
capturas/   imágenes de los resultados
powerbi/    tablero (en construcción)
```

## Cómo reproducir el análisis

1. Descargar los dos conjuntos desde datos.gov.co con los filtros de la tabla anterior y copiar los CSV a `C:\\datos\_secop` como `contratos\_limpio.csv` (22 columnas útiles) y `pagos.csv` (exportación completa).
2. Ejecutar en SQL Server los scripts de la carpeta `sql`, del `01` al `05`.
3. Ejecutar `06\_verificacion.sql`: todas las filas deben decir **OK**.

|Script|Qué hace|
|-|-|
|`01\_crear\_base\_y\_tablas\_raw.sql`|Crea la base y carga los CSV tal como llegaron|
|`02\_limpiar\_contratos.sql`|Convierte valores, fechas y códigos de los contratos|
|`03\_limpiar\_pagos.sql`|Limpia pagos, elimina duplicados exactos y marca fechas imposibles|
|`04\_calidad\_entidades.sql`|Clasifica a las entidades según cuánto registran|
|`05\_vistas\_powerbi.sql`|Vistas para el tablero, sin nombres de proveedores|
|`06\_verificacion.sql`|Comprueba las cifras del proyecto|

!\[Verificación de los scripts](capturas/01\_verificacion.png)

## Hallazgos

Un billón equivale a un millón de millones de pesos.

**1. Pocas entidades registran la ejecución de sus contratos.** De 332 entidades con contratos analizables, 49 registran facturas o pagos en al menos la mitad de sus contratos. Concentran cerca del 81 % de lo pagado que aparece en SECOP II.

|Grupo|Entidades|Contratos|Valor contratado|Pagado registrado|% pagado|
|-|-|-|-|-|-|
|Registran ejecución|49|59.542|$4,58 billones|$1,20 billones|26,1 %|
|No registran ejecución|283|235.534|$17,68 billones|$0,29 billones|1,6 %|

El 26,1 % no es la tasa de pago del Valle: el grupo se definió justamente por tener registros. Un valor pagado de cero significa que no hay pago registrado en la plataforma, no que no se haya pagado.

!\[Entidades que registran ejecución](capturas/02\_entidades\_que\_registran.png)

**2. Los créditos públicos no son compras.** Hay 18 contratos de "Operaciones de Crédito Público" por unos $2,28 billones, sin pagos registrados. Se excluyen del análisis.

**3. Casi toda la contratación es prestación de servicios.** Son 274.547 de 295.783 contratos (92,8 %).

**4. Casi la mitad de los pagos medibles se hizo después del vencimiento.** De 64.754 pagos medibles en todo el país, el 52,7 % se pagó en la fecha o antes y el 47,3 % después. Cerca del 90 % de los pagos tardíos se hizo con menos de 30 días de retraso.

!\[Pagos según el vencimiento](capturas/03\_oportunidad\_de\_pago.png)

## Limitaciones

* Los valores de facturado y pagado dependen de lo que cada entidad registra en SECOP II.
* Plan de pagos no trae departamento: el análisis de oportunidad de pago es nacional, y solo unos 1.400 pagos son de entidades con contratos en el Valle.
* Al analizar solo a las entidades que registran, los resultados valen para ese grupo y no para todo el Valle.
* "Pago tardío" significa fecha real posterior al vencimiento, sin días de tolerancia.

Detalle completo en [`docs/hallazgos\_y\_limitaciones.md`](docs/hallazgos_y_limitaciones.md) y [`docs/diccionario\_de\_datos.md`](docs/diccionario_de_datos.md).

## Próximos pasos

* Tablero de Power BI con dos páginas: contratación en el Valle y oportunidad de pago.
* Análisis de proveedores con identificadores anonimizados.

## Autora

Ashley Giselle Paredes Palacios · www.linkedin.com/in/ashleyg-ppalacios

