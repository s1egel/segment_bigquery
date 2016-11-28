
# Facts about a particular Session. 

- view: session_trk_facts 
  derived_table:
    sql: |
      SELECT s.session_id
        , MAX(map.received_at) AS ended_at
        , count(distinct map.event_id) AS num_pvs
        , count(case when map.event = 'viewed_product' then event_id else null end) as cnt_viewed_product
        , count(case when map.event = 'signup' then event_id else null end) as cnt_signup
      FROM ${sessions_trk.SQL_TABLE_NAME} AS s
      LEFT JOIN ${track_facts.SQL_TABLE_NAME} as map on map.session_id = s.session_id
      GROUP BY 1
                  
                  
                  
  fields:

  - dimension: session_id
    hidden: true
    primary_key: true
    sql: ${TABLE}.session_id

  - dimension_group: ended_at
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.ended_at

  - dimension: number_events
    type: number
    sql: ${TABLE}.num_pvs
  
  - dimension: is_bounced_session
    type: yesno
    sql: ${number_events} = 1
  
  - dimension: viewed_product
    type: yesno
    sql: ${TABLE}.cnt_viewed_product > 0
    
  - dimension: signup
    type: yesno
    sql: ${TABLE}.cnt_signup > 0
      
  - measure: count_viewed_product
    type: count
    filter: 
      viewed_product: yes
  
  - measure: count_signup
    type: count
    filter: 
      signup: yes


  
  sets:
    detail:
      - user_id
      - sessionidx
      - ended_at
      - num_pvs