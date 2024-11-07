WITH source AS (
    SELECT *
    FROM {{ source('raw', 'accounts') }}
)

SELECT 
    account_id,
    account_name,
    account_type,
    CAST(opening_date AS DATE) AS opening_date,  -- Ensure opening_date is in date format
    balance
FROM source