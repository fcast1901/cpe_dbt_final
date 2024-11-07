{{ config(materialized='table') }}

SELECT 
    account_id,
    account_name,
    opening_date,
    initial_balance,
    account_type
FROM {{ ref('int_accounts') }}
