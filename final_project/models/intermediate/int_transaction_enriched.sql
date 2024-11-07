WITH transaction_details AS (
    SELECT 
        t.transaction_id,
        t.account_id,
        t.transaction_date,
        t.transaction_amount,
        CASE 
            WHEN t.transaction_amount < 0 THEN 'retiro' 
            ELSE 'deposito'  
        END AS transaction_type,
        COALESCE(a.initial_balance, 0) AS initial_balance,
        {{ calculate_cumulative_balance('t.account_id', 't.transaction_date', 't.transaction_amount') }} AS cumulative_balance
    FROM {{ ref('stg_transactions') }} AS t
    LEFT JOIN {{ ref('int_accounts') }} AS a
    ON t.account_id = a.account_id
)

SELECT 
    transaction_id,
    account_id,
    transaction_date,
    transaction_amount,
    transaction_type,
    initial_balance,
    cumulative_balance
FROM transaction_details
