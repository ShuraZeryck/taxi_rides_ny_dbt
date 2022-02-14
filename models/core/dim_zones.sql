{{ config(materialized='table') }}


select 
    locationid, 
    borough, 
    zone, 
    replace(service_zone,'Boro','Green') as service_zone
from {{ ref('taxi_zone_lookup') }}
-- In taxi_zone_lookup, green zones are called boro zones, but we change that here