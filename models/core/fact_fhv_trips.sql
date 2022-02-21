{{ config(materialized='table') }}

-- Mostly copied over from fact_trips
-- Changed datetime conditional

with fhv_data as (
    select *, 
        'FHV' as service_type 
    from {{ ref('stg_fhv_tripdata') }}
    where (date(pickup_datetime) between '2019-01-01' and '2019-12-31')
), 

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

-- Copied zone stuff from fact_trips

select
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    fhv_data.dispatching_base_num,
    fhv_data.pickup_locationid,
    fhv_data.dropoff_locationid,
    fhv_data.pickup_datetime,
    fhv_data.dropoff_datetime,
    fhv_data.sr_flag
from fhv_data
inner join dim_zones as pickup_zone
on fhv_data.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_data.dropoff_locationid = dropoff_zone.locationid
