{{ config(
    materialized='incremental',
    unique_key='account_id, transaction_date'
) }}

WITH transactions_with_balance AS (
    SELECT 
        t.account_id,
        t.transaction_date,
        t.transaction_amount,
        COALESCE(a.initial_balance, 0) AS initial_balance
    FROM {{ ref('fact_transactions') }} AS t
    LEFT JOIN {{ ref('dim_accounts') }} AS a
    ON t.account_id = a.account_id
)

SELECT 
    account_id,
    transaction_date,
    {{ calculate_cumulative_balance('account_id', 'transaction_date', 'transaction_amount', 'initial_balance') }} AS daily_balance
FROM transactions_with_balance
{% if is_incremental() %}
WHERE transaction_date > (
    SELECT COALESCE(MAX(transaction_date), '1970-01-01') 
    FROM {{ this }}
)
{% endif %}

