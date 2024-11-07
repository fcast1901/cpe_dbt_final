with date_dim as (
    {{ dbt_date.get_date_dimension("2019-01-01", "2030-12-31") }}
)

select
    *,
    cast(to_char(date_day, 'YYYYMMDD') as integer) as sk_date,
    cast(to_char(date_day, 'FMMM') || '_' || to_char(date_day, 'FMDD') || '_' || to_char(date_day, 'YY') as text) as date_string
from date_dim