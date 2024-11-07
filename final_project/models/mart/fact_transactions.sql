{{ config(materialized='table') }}

SELECT 
    transaction_id,
    account_id,
    transaction_date,
    transaction_amount,
    transaction_type,
    cumulative_balance
FROM {{ ref('int_transaction_enriched') }}
