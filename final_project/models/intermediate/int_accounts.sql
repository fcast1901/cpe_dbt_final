SELECT 
    account_id,
    account_name,
    cast(to_char(opening_date, 'YYYYMMDD') as integer) as opening_date,
    account_type,
    balance as initial_balance
FROM {{ ref('stg_accounts') }}