# simplicate

Minimal syntax for triggering CouchDB replication from the command line.

At its simplest:

```bash
simplicate -s http://couch.mammal.io:5984/foo_db
```

maps to the following curl command which is displayed for your confirmation.

```
curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicate -d \
  '{"source":"http://couch.mammal.io:5984/foo_db","target":"foo_db","create_target":true}'
```

Supports filters, query-params, doc_ids, continuous replication.

Gets a lot of personal use => stable.

## Install

With [npm](//npmjs.org):

```sh
npm install -g simplicate
```

or manually:

```sh
git clone https://github.com/mammal/simplicate.git
cd simplicate
ln -s `pwd`/simplicate.sh /usr/local/bin/simplicate
```

It's a bash script. Depends on curl.

## Usage

```bash
simplicate -s <src> | -t <tar> [-d <doc_ids> | -f <filter> [-q <query_params>]] [-c] [-v] [<couch_server>]
```

```
OPTIONS

<couch_server>
  The CouchDB Server to which the /_replicate request is posted.
  Defaults to http://127.0.0.1:5984

-s <src>
-t <tar>
  One or both of source and target must be supplied.
  Where only one is specified, it should be the full URL to the database.
  In this case it is inferred that the other database - on <couch_server> - will have
  the same name.

-d <doc_ids>
  Replicate only documents with supplied ids.
  e.g. -d '[ "id1", "id2" ]'

-f <filter>
  Apply a filter function when replicating.
  e.g. -f a_design_doc/some_filter_fn

-q <query_params>
  Query parameters can be supplied to the filter function.
  e.g. -f a_design_doc/some_filter_fn -q '{ "aKey": "aVal" }'

-c
  Continuous replication

-v
  Run `curl` with verbose flag

---

N.B. create_target is always set to true.
```
