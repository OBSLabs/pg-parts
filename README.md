pg-parts is a partition manager for postgres. It's designed specially to handle fast growing tables (1M records/day) which retain data for a certain period of time (e.g. last 14 days).

### Basic idea
Break a large table into smaller partition. Remove data via detach partition vs delete recods with DELETE statement.

### Why bother about partitioning when `delete from X where created_at` does a job?
1. Index bloat https://wiki.postgresql.org/wiki/Index_Maintenance#Index_Bloat
2. Load spikes during the maintenance. Attach partition has no overhead.

### Applying partitionining to existing table
Let's assume that table already exist and there is some data. This script create a such example.
```sql
-- create new table.
create table impressions(campaign_id integer, site_id integer);
-- create some data.
insert into impressions values (1,2), (2,3);
```
Next step is to add table to the config.yml

and then run `bundle exec bin/partition -c config.yml` which produces output similar to:
```sql
CREATE TABLE IF NOT EXISTS impressions_20160127 () INHERITS (impressions);
CREATE OR REPLACE RULE impressions_insert AS
  ON INSERT TO impressions
  DO INSTEAD
  INSERT INTO impressions_20160127 VALUES (new.*)  RETURNING *;
```

To transfer data from master table to the current partition:
```sql
-- insert automatically detects current partition based on insert rule defined above.
insert into impressions select * from only impressions;
-- delete records just from master table.
delete from only impressions;
```
### Execution
pg-parts is idempotent. It creates partion when missing and does nothing otherwise, thereby it's safe to run it multiple times.

### Index partition
pg-parts automatically creates indicies on newly created partition based on master table and name them accordingly.

### Detachment
pg-parts automatically detach partitions older then threhold defined in config.yml

### Remove detached partitions
pg-parts doesn't do it implicitly and it's necessary to run `bundle exec ruby bin/truncate -c config.yml`explicitly to removes all detached partitions.

### Deployment
* `git clone git@github.com:OBSLabs/pg-parts.git` to home directory is a suitable way to install it.
* /etc/ as a home for pg-parts config file. i.e. `/etc/pg_parts.yml`
* cron is a reliable way to run bin/partition & bin/truncate

