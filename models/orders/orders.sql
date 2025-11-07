{{ config(
    materialized = 'incremental',
    unique_key   = 'order_id'
) }}

with source_orders as (

    select
        order_id,
        customer_id,
        order_date,
        status,
        updated_at,
        total_amount
    from {{ source('dbt_cloud', 'orders') }}

),

filtered as (

    select
        order_id,
        customer_id,
        order_date,
        status,
        updated_at,
        total_amount
    from source_orders
    {% if is_incremental() %}
      -- Only load new/changed records compared to what already exists
      where updated_at > (
        select coalesce(max(updated_at), '1900-01-01') from {{ this }}
      )
    {% endif %}

)

select *
from filtered
