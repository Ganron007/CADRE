import json, urllib.request, base64

auth = 'Basic ' + base64.b64encode(b'elastic:elastic_CADRE_2026!').decode()
hdr = {'Content-Type': 'application/json', 'Authorization': auth}
es = 'http://127.0.0.1:9200'

# Find Zeek indices
req = urllib.request.Request(f'{es}/_cat/indices?format=json', headers=hdr)
r = json.loads(urllib.request.urlopen(req).read())
zeek_idx = [i['index'] for i in r if 'zeek' in i['index'].lower()]
print('Zeek indices:', zeek_idx)

# Check for Zeek kerberos events in last 10m
for idx in zeek_idx:
    q = json.dumps({'query': {'bool': {'filter': [
        {'range': {'@timestamp': {'gte': 'now-10m'}}},
        {'term': {'event.dataset': 'zeek.kerberos'}}
    ]}}, 'size': 3}).encode()
    req = urllib.request.Request(f'{es}/{idx}/_search', data=q, headers=hdr)
    try:
        r2 = json.loads(urllib.request.urlopen(req).read())
        n = r2['hits']['total']['value']
        if n > 0:
            print(f'\n{idx}: {n} kerberos events in last 10m')
            for h in r2['hits']['hits']:
                s = h['_source']
                # zeek kerberos fields
                zk = s.get('zeek',{}).get('kerberos',{})
                print(f'  {s.get("@timestamp","?")[:19]} error={zk.get("error_msg","")} client={zk.get("client","")} service={zk.get("service","")}')
    except Exception as e:
        print(f'{idx} query error: {e}')
