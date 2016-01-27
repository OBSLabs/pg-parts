### Applying partitionining to existing table
Let's assume that table already exist and there is some data. This script create a such example.
```sql
-- create new table.
create table impressions(campaign_id integer, site_id integer);
-- create some data.
create table insert into impressions values (1,2), (2,3);
```
Next step is to add table to the config.yml

and then run `bundle exec bin/partition -c config.yml`

That will produce output similar to:
```sql
CREATE TABLE IF NOT EXISTS impressions_20160127 () INHERITS (impressions);

        CREATE OR REPLACE RULE impressions_insert AS
        ON INSERT TO impressions
        DO INSTEAD
          INSERT INTO impressions_20160127 VALUES (new.*)  RETURNING *;
```

To transfer data from master partition to the current partition:
```sql
-- insert automatically detects current partition based on insert rule defined above.
insert into impressions select * from only impressions;
-- delete records just from master partition.
delete from only impressions;
```
