WITH source AS (
    SELECT *
    FROM {{ source('raw', 'account_types') }}
)

SELECT 
    account_type_id,
    account_type_name
FROM source