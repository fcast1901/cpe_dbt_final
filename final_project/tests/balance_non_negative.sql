SELECT *
FROM {{ ref('stg_accounts') }}
WHERE balance < 0
 