drop table if exists test_table;
create table test_table(
    user_id varchar(20) not null
    , user_name varchar(30)
	, created_timestamp timestamp
    , primary key (user_id)
);