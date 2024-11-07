{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['account_id']) }} AS account_hash,
    account_id,
    account_name,
    opening_date,
    initial_balance,
    account_type
FROM {{ ref('int_accounts') }}
