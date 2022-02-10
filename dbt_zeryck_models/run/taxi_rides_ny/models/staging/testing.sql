

  create or replace view `fresh-shell-338718`.`dbt_szeryck`.`testing`
  OPTIONS()
  as 

select * from `fresh-shell-338718`.`trips_data_all`.`yellow_tripdata_partitioned_clustered`
limit 100;

