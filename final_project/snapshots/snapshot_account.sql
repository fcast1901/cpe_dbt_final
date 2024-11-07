{% snapshot snapshot_accounts %}
 
    {{
        config(
            target_schema='snapshots',
            unique_key='account_id',
            strategy='check',
            check_cols=['initial_balance', 'account_name', 'account_type']
        )
    }}
 
    SELECT * FROM {{ ref('int_accounts') }}
 
{% endsnapshot %}

