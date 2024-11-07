WITH transaction_details AS (
    SELECT 
        t.transaction_id,
        t.account_id,
        t.transaction_date,
        t.transaction_amount,
        t.transaction_type,
        COALESCE(a.initial_balance, 0) AS initial_balance,
        COALESCE(SUM(t.transaction_amount) 
            OVER (PARTITION BY t.account_id ORDER BY t.transaction_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) AS cumulative_balance
    FROM {{ ref('stg_transactions') }} AS t
    LEFT JOIN {{ ref('int_accounts') }} AS a
    ON t.account_id = a.account_id
)

SELECT * 
FROM transaction_details
