{{ config(
    materialized = 'incremental',
    unique_key   = 'ORDER_ID'
) }}

with source_orders as (

    select
        ORDER_ID,
        CUSTOMER_ID,
        ORDER_DATE,
        UPDATED_AT,
        TOTAL_AMOUNT
    from {{ source('snowflake_raw', 'ORDERS') }}

),

filtered as (

    select
        ORDER_ID,
        CUSTOMER_ID,
        ORDER_DATE,
        UPDATED_AT,
        TOTAL_AMOUNT
    from source_orders
    {% if is_incremental() %}
      where UPDATED_AT > (
        select coalesce(max(UPDATED_AT), '1900-01-01') from {{ this }}
      )
    {% endif %}

)

select *
from filtered
