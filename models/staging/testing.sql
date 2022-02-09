{{ config(materialized='view') }}

select * from {{ source('staging','yellow_tripdata_partitioned_clustered') }}
limit 100