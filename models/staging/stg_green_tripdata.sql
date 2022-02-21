{{ config(materialized='view') }}
 
-- Mostly copied over from stg_yellow_tripdata.sql
-- Changed source line, trip_type line, tpep to lpep, added ehail fee

with tripdata as 
(
  -- select *,
  --   row_number() over(partition by lpep_pickup_datetime, pulocationid) as rn
  select *
  from {{ source('staging','green_tripdata_partitioned_clustered') }}
  where vendorid is not null 
)
select
   -- identifiers
   -- First one uses macro surrogate_key from dbt_utls package to create unique ID for each trip
    {{ dbt_utils.surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,
    
    -- timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    -- yellow cabs are always street-hail
    cast(trip_type as integer) as trip_type,
    
    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    {{ get_payment_type_description('payment_type') }} as payment_type_description, 
    cast(congestion_surcharge as numeric) as congestion_surcharge
from tripdata
-- where rn = 1
-- Given how rn was defined above, this removes duplicates

-- Run CLI command below to build with all data, instead of test build with only 100 rows
-- dbt build --m stg_green_tripdata.sql --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}