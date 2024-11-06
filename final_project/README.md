# Proyecto Final: Transformación de Datos con dbt

## Introducción

Este proyecto final del curso **"Transformación de Datos con dbt"** te permitirá aplicar los conocimientos adquiridos durante el curso. Trabajarás en la construcción y optimización de un flujo de transformación de datos para la simulación de un sistema de análisis financiero.

El escenario está basado en una compañía ficticia llamada **"FinCorp Analytics"**, que maneja transacciones bancarias y necesita un sistema eficiente para gestionar y analizar estas transacciones, generando reportes detallados de balances, movimientos por cuenta, y cambios en las cuentas a lo largo del tiempo.

## Objetivos del Proyecto

1. **Carga y Gestión de Fuentes de Datos**
   - Definir las fuentes de datos (`sources`) de las tablas crudas en dbt que contienen información de transacciones y cuentas.
   - Estas tablas deben estar correctamente definidas en el archivo `schema.yml` con las descripciones correspondientes para cada columna.

2. **Construcción de Modelos**
   - Crear los modelos que gestionen y transformen los datos crudos en tablas analíticas:
     - `dim_accounts`: Tabla dimensional con información de las cuentas, incluído el tipo de cuenta. Materialización como *tabla*.
     - `fact_transactions`: Fact table con los detalles de las transacciones, incluyendo el balance acumulado por cuenta (de la tabla accounts) y transacción. Materialización como *tabla*.
     - `agg_daily_balances`: Tabla agregada que muestra el balance diario de cada cuenta. Materialización como *incremental*.
     - Puede incluir todos los modelos intermedios que entienda necesarios.

3. **Snapshots**
   - Crear un modelo de snapshot `snapshot_accounts` para rastrear cambios en el estado de las cuentas (cuenta, balance y tipo de cuenta) en el tiempo.
   - Definir y ejecutar el snapshot para almacenar los cambios históricos.

4. **Validación y Pruebas de Datos**
   - Añadir pruebas para asegurar la calidad de los datos:
     - Pruebas de unicidad y no nulos en los campos `account_id` y `transaction_id`.
     - Pruebas personalizadas para asegurar que los balances no sean negativos.
     - Documentar las pruebas en el archivo `schema.yml`.
     - Incluya pruebas de `dbt_expectations` para chequear que la data de los modelos en mart tengan más de una fila.

5. **Uso de Macros y Paquetes**
   - Crear una macro reutilizable para calcular balances acumulados y aplicar esta macro en los modelos.
   - Usar un paquete externo de dbt para generar un hash en las tablas del data mart.

6. **Definición de Data Contracts**
   - Definir las condiciones de un data contract que asegure la calidad y el formato de los datos que se envían desde las fuentes hasta los modelos analíticos.
   - Esto incluye:
    - Los tipos de datos de los modelos del mart
    - Que los números de cuenta sean los mismos en `fact_transactions` que en `dim_accounts`.
    - Que los ids creados para `dim_accounts` y `fact_transactions` sea una clave primaria en sus respectivas tablas.

7. **Perfiles y Targets**
   - Configurar correctamente los archivos `profiles.yml` y `dbt_project.yml` para definir targets y perfiles según el entorno (dev/prod).
   - Ejecutar los modelos en diferentes entornos y verificar los resultados.

8. **Documentación**
   - Modifique este `README.md` dejando en la explicación de por qué tomo cada decisión en cada momento. 
