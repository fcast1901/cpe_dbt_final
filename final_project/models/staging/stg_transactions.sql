
WITH source AS (
    SELECT *
    FROM {{ source('raw', 'transactions') }}
)

SELECT 
    transaction_id,
    account_id,
    CAST(transaction_date AS DATE) AS transaction_date,  -- Ensure transaction_date is in date format
    transaction_amount,
    transaction_type
FROM source