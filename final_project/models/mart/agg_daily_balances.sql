{{ config(
    materialized='incremental',
    unique_key='account_id'
) }}

WITH transactions_with_balance AS (
    SELECT 
        t.transaction_hash,
        t.account_id,
        a.account_hash as account_sk,
        transaction_date,
        COALESCE(a.initial_balance, 0) as initial_balance,
        LAG(COALESCE(a.initial_balance, 0) + t.cumulative_balance) OVER (
            PARTITION BY t.account_id 
            ORDER BY t.transaction_date
        ) AS previous_balance,
        COALESCE(a.initial_balance, 0) + cumulative_balance AS daily_balance
    FROM {{ ref('fact_transactions') }} AS t
    LEFT JOIN {{ ref('dim_accounts') }} AS a
    ON t.account_id = a.account_id
)
        

SELECT 
    account_id,
    transaction_hash as transaction_sk,
    transaction_date,
    initial_balance,
    COALESCE(previous_balance, initial_balance) as previous_balance,
    daily_balance
FROM transactions_with_balance
{% if is_incremental() %}
WHERE transaction_date > (
    SELECT COALESCE(MAX(transaction_date), '1970-01-01') 
    FROM {{ this }}
)
{% endif %}
