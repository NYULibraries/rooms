curl -XGET 'http://localhost:9200/staging_reservations/_search?pretty' -d '
{
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "must": [
            { "terms": { "room_id": [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20] } },
            { "term": { "deleted": false } },
            { "bool": {
              "should": [
                {
                  "bool": {
                    "must": [
                      { "range": { "start_dt": { "gte": "2017-01-05T13:30:00+00:00" } } },
                      { "range": { "start_dt": { "lt": "2017-01-05T16:00:00+00:00" } } }
                    ]
                  }
                },
                {
                  "bool": {
                    "must": [
                      { "range": { "end_dt": { "gt": "2017-01-05T13:30:00+00:00" } } },
                      { "range": { "end_dt": { "lte": "2017-01-05T16:00:00+00:00" } } }
                    ]
                  }
                },
                {
                  "bool": {
                    "must": [
                      { "range": { "start_dt": { "lte": "2017-01-05T13:30:00+00:00" } } },
                      { "range": { "end_dt": { "gte": "2017-01-05T16:00:00+00:00" } } }
                    ]
                  }
                }
              ]
            }
            }
          ]
        }
      }
    }
  },
  "size": 200
}
'
