{% macro calculate_cumulative_balance(account_id, transaction_date, transaction_amount, initial_balance=0) %}
    (
        {{ initial_balance }} 
        + SUM({{ transaction_amount }}) OVER (
            PARTITION BY {{ account_id }} 
            ORDER BY {{ transaction_date }} 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    )
{% endmacro %}