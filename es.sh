curl -XGET 'http://localhost:9200/test_reservations/_search?pretty' -d '
{
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "must": [
            { "term": { "deleted": false } },
            { "term": { "is_block": false } },
            { "term": { "user_id": 482 } },
            { "term": { "start_day": "2016-12-22" }}
          ]
        }
      }
    }
  }
}
'
