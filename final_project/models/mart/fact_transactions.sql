{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['transaction_id', 'account_id', 'transaction_date']) }} AS transaction_hash,
    transaction_id,
    account_id,
    transaction_date,
    transaction_amount,
    transaction_type,
    cumulative_balance
FROM {{ ref('int_transaction_enriched') }}
