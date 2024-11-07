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


# Paso a paso realizado:
CREACION Y CONFIGURACION DEL ENTORNO Y BASE DE DATOS
 
1- Cree la carpeta: FinCorpAnalytics
2- Cree el entorno virtual dentro de la carpeta: entorno_virtual_FinCorpAnalytics (python -m venv entorno_virtual_FinCorpAnalytics)
3- Active el entorno virual: fui a \entorno_virtual_FinCorpAnalytics\Scripts y ejecute actuvate
4- Instale dbt-core y dbt-postrgres: pip install dbt-core dbt-postgr
5- Cree una instancia de postgres con docker: docker run -it --name FinCorpAnalytics-postgres -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres
6- Inicie el proyecyto: dbt init
	Which database would you like to use: 1
	host: localhost
	port: 5432
	user: postgres
	password: mysecretpassword
	dbname: postgres
	schema: public
	threads: 1
7- Ejecute para corroborar que quedo bien instalado, dentro de FinCorpAnalytics\entorno_virtual_FinCorpAnalytics\Scripts\DbtProject_FinCorpAnalytics: dbt build
 
CARGA DE DATOS CSV A BASE POSTGRES
 
8- Descargue los arhivos csv en computadora local
9- Ejecute el siguiente script de python (import_data.py), que toma los datos de los csv y los inserta en la base de datos creada anteriormente.

 
CARGA Y GESTION DE FUENTES DE DATOS
 
10- Cree el archivo sources.yml y cargue los sources. Defini tambien las tablas en el archivo schema.yml
11- Cargamos a staging la informacion de source, identificando cada columna para tolerar en un futuro un cambio de nombre de la source y no hacer que todo nuestros modelos se vean afectados.

12- Pasamos a la etapa de procesamiento en intermediate.

13- Al ser 2 tipos de cuenta (corriente, ahorro) y el tipo de cuenta ya esta cargado en la tabla.

14- Creamos el macro reutilizable 'calculate_cumulative_balance.sql' para calcular balances acumulados y aplicar esta macro en la etapa intermediate.

15- En este caso (a diferencia del ejercicio de repaso), no había una razón tan clara para utilizar la etapa de intermediate. Como buena practica decidimos utilizarla, generando 2 modelos :
   int_accounts: 
                  - Convertimos a int las fechas (generando la sk_date para la etapa posterior)

   int_transactions_enriched:
                  - Convertimos a int las fechas (generando la sk_date para la etapa posterior)
                  - Con la ayuda del macro 'calculate_cumulative_balance.sql' generamos la columna 'cumulative_balance'.

16- Luego pasamos a la capa Mart.
Generamos los 3 modelos deseados:
   - dim_accounts
   - fact_transactions
   - agg_daily_balances
Además, se tomó la decisión de crear una dimensión de fecha, sumando una buena practica y agregando mas campos fecha posibles para el analisis posterior. Esto se realizó mediante el paquete: 'calogica/dbt_date' (https://github.com/calogica/dbt-date?tab=readme-ov-file#get_date_dimensionstart_date-end_date).

Creamos el snapshots llamado snapshot_accounts.sql dentro de la carpeta snapshots, para guardar todos los cambios de las cuentas (cuenta, tipo de cuenta y balance).
 
Agregamos en el schema.yml las pruebas automaticas de unicidad y no nulos para los campos account_id yt transaction_id
Creamos una prueba personalizada llamada balance_more_than_zero.sql que dado un modelo y una columna generica testea si el balance es mayor que cero. Y a este test lo llamamos en el schema.yml.
Agregamos en packages.yml el paquete calogica/dbt_expectations, luego corrimos dbt deps para instalarlo y agregamos en el schema de mart la prueba de que tengan al menos 1 fila.
 
Agregamos contracts en el schema para asegurar la calidad y el formato de datos:
 
Especificamos los tipos de datos en cada columna dentro de dim_accounts y fact_transactions. Esto asegura que los datos en las tablas cumplan con los formatos definidos en el data contract.
Usamos foreign_key para que account_id en fact_transactions refiera a account_id en dim_accounts. Esto garantiza que todos los account_id en fact_transactions existan también en dim_accounts, asegurando consistencia entre las tablas.
Definimos unique en account_id de dim_accounts y en transaction_id de fact_transactions, estableciendo que estas columnas sean claves primarias, asegurando unicidad y no nulos.

Perfil y target.