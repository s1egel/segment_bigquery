view: aliases_mapping {
  derived_table: {
    sql_trigger_value: select count(*) from app_production.tracks_view ;;
    sql: with
      all_mappings as (
        select anonymous_id
        , user_id
        , received_at as received_at
        from app_production.tracks_view

        union distinct

        select user_id
          , null
          , received_at
        from app_production.tracks_view
      )

      select
         distinct anonymous_id as alias
        ,coalesce(first_value(user_id)
            over(
              partition by anonymous_id
              order by received_at desc
              rows between unbounded preceding and unbounded following), user_id, anonymous_id) as looker_visitor_id
      from all_mappings
       ;;
  }

  # Anonymous ID
  dimension: alias {
    type: string
    primary_key: yes
    sql: ${TABLE}.alias ;;
  }

  # User ID
  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }
}
