{{ config(materialized='view') }}

-- Copied from stg_yellow_tripdata
-- Updated source line, columns to select
-- Used dispatching_base_num instead of vendorid. The bit with rn should still ensure uniqueness
 
with tripdata as 
(
  select *,
    row_number() over(partition by dispatching_base_num, pickup_datetime) as rn
  from {{ source('staging','fhv_tripdata_non_partitioned') }}
  where dispatching_base_num is not null 
)
-- Note: source macro above gets correct schema and all dependencies. 'staging' is name from schema.yml

select
   -- identifiers
    {{ dbt_utils.surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    cast(dispatching_base_num as string) as dispatching_base_num,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    sr_flag,
    -- fhv's are always pre-arranged service
    2 as trip_type,
from tripdata
where rn = 1

-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}