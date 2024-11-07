
# FinCorpAnalytics Project

## CREACION Y CONFIGURACION DEL ENTORNO Y BASE DE DATOS

1. Cree la carpeta: `FinCorpAnalytics`
2. Cree el entorno virtual dentro de la carpeta: `entorno_virtual_FinCorpAnalytics` (python -m venv entorno_virtual_FinCorpAnalytics)
3. Active el entorno virtual: fui a `\entorno_virtual_FinCorpAnalytics\Scripts` y ejecuté `activate`
4. Instale dbt-core y dbt-postgres: `pip install dbt-core dbt-postgres`
5. Cree una instancia de PostgreSQL con Docker:
   ```
   docker run -it --name FinCorpAnalytics-postgres -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres
   ```
6. Inicie el proyecto con `dbt init` y complete la configuración:
   - Which database would you like to use: 1
   - host: localhost
   - port: 5432
   - user: postgres
   - password: mysecretpassword
   - dbname: postgres
   - schema: public
   - threads: 1
7. Ejecute para corroborar que quedó bien instalado dentro de `FinCorpAnalytics\entorno_virtual_FinCorpAnalytics\Scripts\DbtProject_FinCorpAnalytics`:
   ```
   dbt build
   ```

## CARGA DE DATOS CSV A BASE POSTGRES

8. Se depositaron los archivos en la carpeta deseada.
9. Se ejecuta el siguiente script de Python (`import_data.py`), que toma los datos de los CSV y los inserta en la base de datos creada anteriormente.

## CARGA Y GESTION DE FUENTES DE DATOS

10. Se crea el archivo `sources.yml` y se cargan los sources. También se definen las tablas en el archivo `schema.yml`.

11. Cargar fuentes en tablas temporales y mapear columnas para tolerar cambios en la fuente de datos en el futuro sin afectar los modelos.

## Procesamiento en intermediate.

13. Como hay 2 tipos de cuenta (corriente, ahorro) y el tipo de cuenta ya está cargado en la tabla, se opta por no utilizar la tabla account_types.

14. Creamos el macro reutilizable `calculate_cumulative_balance.sql` para calcular balances acumulados y aplicarlo en la etapa intermediate. El macro utiliza la función SUM con una ventana (window function) para calcular el saldo acumulado (cumulative balance) en cada fila de transacción. Esto se logra ordenando las transacciones por fecha (transaction_date) para cada cuenta (account_id) y acumulando el transaction_amount desde la primera transacción hasta la transacción actual.
Ademas creamos el macro 'calculate_daily_balance.sql' para poder saber el balance diario de cada cuenta.

15. En este caso (a diferencia del ejercicio de repaso), no había una razón tan clara para utilizar la etapa de intermediate. Como buena práctica decidimos utilizarla, generando 2 modelos:
   - `int_accounts`: 
     - Convertimos a int las fechas (generando la `sk_date` para la etapa posterior)
   - `int_transactions_enriched`:
     - Convertimos a int las fechas (generando la `sk_date` para la etapa posterior)
     - Con la ayuda del macro `calculate_cumulative_balance.sql` generamos la columna `cumulative_balance`.
     - Arreglamos inconsistencias del tipo de transaction (utilizando transaction_amount).

## Capa Mart y Modelos Finales

   Generamos los 3 modelos deseados:
   - `dim_accounts`: 
         Este modelo crea una tabla con información esencial de cuentas, incluyendo una clave única (`account_hash`), generada a partir de `account_id` usando `dbt_utils.generate_surrogate_key`. Los campos seleccionados incluyen `account_id`, `account_name`, `opening_date`, `initial_balance`, y `account_type`, que provienen de la tabla `int_accounts`. La materialización como `table` garantiza que los datos se almacenen físicamente, optimizando el rendimiento en consultas futuras.
   - `fact_transactions`: 
         Este modelo crea una tabla con detalles de transacciones, generando una clave única (`transaction_hash`) a partir de `transaction_id`, `account_id` y `transaction_date` mediante `dbt_utils.generate_surrogate_key`. Los campos seleccionados incluyen `transaction_id`, `account_id`, `transaction_date`, `transaction_amount`, `transaction_type` y `cumulative_balance`, provenientes de `int_transaction_enriched`. La materialización como `table` guarda los datos físicamente para mejorar el rendimiento en futuras consultas.
   - `agg_daily_balances`:
         Este modelo incremental calcula el balance diario por cuenta. Combina datos de transacciones y cuentas para obtener el balance, y solo agrega registros nuevos o actualizados, optimizando la carga. Los campos seleccionados incluyen `account_id`, `transaction_sk`, `transaction_date`, `initial_balance`, y `daily_balance`. La condición incremental asegura que solo se procesen transacciones recientes, mejorando el rendimiento.

   Además, se tomó la decisión de crear una dimensión de fecha, sumando una buena práctica y agregando más campos de fecha posibles para el análisis posterior. Esto se realizó mediante el paquete: `calogica/dbt_date`.

## SNAPSHOTS Y PRUEBAS

17. Creamos el snapshot llamado `snapshot_accounts.sql` dentro de la carpeta snapshots, para guardar todos los cambios de las cuentas (cuenta, tipo de cuenta y balance).
 
18. Agregamos en el `schema.yml` las pruebas automáticas:
   - Pruebas de unicidad y no nulos para account_id y transaction_id.
   - Crear prueba personalizada generica balance_more_than_zero.sql para verificar que los balances sean mayores que cero.
   - Agregar prueba de existencia de filas usando calogica/dbt_expectations.
    
## CONTRATOS DE DATOS

19. Agregamos contratos en el esquema para asegurar la calidad y el formato de datos:
   - Especificar tipos de datos en columnas de dim_accounts y fact_transactions.
   - Usar foreign_key en account_id de fact_transactions para referenciar dim_accounts, asegurando consistencia entre las tablas.
   - Definir unique en account_id y transaction_id para garantizar unicidad y no nulos, generando un control para las claves primarias de las tablas.
   
## PERFILES Y TARGETS

20. El archivo profiles.yml define dos perfiles de configuración de entorno, lo que permite una separación clara entre el entorno de producción y el de desarrollo. Esta estructura asegura que los datos y transformaciones se gestionen de manera segura y organizada.

Perfiles Configurados:
   -final_project (PRD)
   -dev_felipe (Desarrollo)