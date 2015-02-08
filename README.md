# simplicate

As well as triggering replication from the command line, also useful for generating
curl commands that you can share with others.

At its simplest:

```bash
simplicate -s http://couch.mammal.io:5984/foo_db
```

maps to the following curl command which is displayed for your confirmation.

```
curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicate \
  -d '{"source":"http://couch.mammal.io:5984/foo_db","target":"foo_db","create_target":true}'
```

Supports filters, query-params, doc_ids, continuous replication.

## Install

With [npm](//npmjs.org):

```sh
npm install -g simplicate
```

or manually:

```sh
git clone https://github.com/aslant/simplicate.git
ln -s `pwd`/simplicate/simplicate.sh /usr/local/bin/simplicate
```

It's a bash script. Depends on curl.

## Usage

```bash
simplicate -s <src> | -t <tar>  [-d <doc_ids>] [-f <filter> [-q <query_params>]] [-c] [-v] [<couch_server>]
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
  In this case it is inferred that the other database - on <couch_server> - 
  will have the same name.

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

## Abbreviated URLs

If a port is supplied but the protocol and hostname are both omitted, then the protocol and hostname are inferred as `http://127.0.0.1`.

For example `:9999/foo_db` is mapped to `http://127.0.0.1:9999/foo_db`, `:8888` is mapped to `http://127.0.0.1:8888`.
