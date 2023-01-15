set -e
psql -U postgres postgres << EOSQL

--
-- function
--
create or replace function increment_version()
  returns trigger
as
\$body\$
begin
  new.version := new.version + 1;
  return new;
end;
\$body\$
language plpgsql;

create or replace function update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
   NEW.updated_at = now(); 
   RETURN NEW;
END;
\$\$ language 'plpgsql';

--
-- account
--
CREATE TABLE account (
  id          SERIAL,
  user_name   text PRIMARY KEY,
  user_pass   text not null,
  user_host   text, /* host:port/path or 111.222.333.444:post/path */
  email       text,
  active      boolean default false,
  created_at  timestamp not null default current_timestamp,
  updated_at  timestamp not null default current_timestamp,
  version integer not null default 0
);

create trigger version_trigger_account
  before update on account
  for each row execute procedure increment_version();

create trigger update_updated_at_account
  before update on account
  for each row execute procedure update_updated_at_column();

--
-- session
--
CREATE TABLE session (
  id          SERIAL,
  token       text PRIMARY KEY,
  user_name   text not null,
  created_at  timestamp not null default current_timestamp,
  updated_at  timestamp not null default current_timestamp,
  version     integer not null default 0
);

create trigger version_trigger_session
  before update on account
  for each row execute procedure increment_version();

create trigger update_updated_at_session
  before update on account
  for each row execute procedure update_updated_at_column();

--
-- command
--
CREATE TABLE command (
  id          SERIAL,
  user_name   text PRIMARY KEY,
  type        text not null,
  command     text not null,
  memo        text,
  created_at  timestamp not null default current_timestamp,
  updated_at  timestamp not null default current_timestamp,
  version     integer not null default 0
);

create trigger version_trigger_command
  before update on command
  for each row execute procedure increment_version();

create trigger update_updated_at_command
  before update on command
  for each row execute procedure update_updated_at_column();

--
-- sample
--
CREATE TABLE Users(
  account_id    SERIAL PRIMARY KEY,
  account_name  VARCHAR(20),
  email         VARCHAR(100),
  password      CHAR(64)
);

CREATE TABLE UserStatus(
  status        VARCHAR(20) PRIMARY KEY
);

EOSQL