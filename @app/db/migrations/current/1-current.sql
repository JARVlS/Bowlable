
create extension if not exists "uuid-ossp";

drop table if exists app_public.feed_posts;
drop policy if exists show_subscribed on app_public.feeds;
drop policy if exists manage_maintained on app_public.feeds;
drop policy if exists manage_maintained on app_public.feed_subscriptions;
drop policy if exists select_peers on app_public.feed_subscriptions;
drop function if exists app_public.my_feed_subscriptions();
drop function if exists app_public.my_subscribed_feed_ids();
drop table if exists app_public.feed_subscriptions;
drop table if exists app_public.feeds;

-- TABLE feeds
create table app_public.feeds (
  id uuid primary key default uuid_generate_v1mc(),
  name text,
  abstract text,
  is_private boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table app_public.feeds is
  E'A feed is a (chronologically sorted) container for messages and handed-out materials.';
comment on column app_public.feeds.name is
  E'Each feed has an optional name.';
comment on column app_public.feeds.is_private is
  E'Private feeds are only visible to their subscribers.';

grant select on app_public.feeds to :DATABASE_VISITOR;
grant insert (name, is_private) on app_public.feeds to :DATABASE_VISITOR;
grant update (name, is_private) on app_public.feeds to :DATABASE_VISITOR;
grant delete on app_public.feeds to :DATABASE_VISITOR;

alter table app_public.feeds enable row level security;
create policy select_public on app_public.feeds for select using (not is_private);

create trigger _100_timestamps
  before insert or update on app_public.feeds
  for each row
  execute procedure app_private.tg__timestamps();

-- TABLE feed_subscriptions
create table app_public.feed_subscriptions (
  feed_id uuid not null
    constraint feed
      references app_public.feeds (id)
      on update cascade on delete cascade,
  subscriber_id uuid not null
    default app_public.current_user_id()
    constraint sender
      references app_public.users (id)
      on update cascade on delete cascade,
  is_maintainer boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint feed_subscriptions_pk primary key (subscriber_id, feed_id)
);

comment on table app_public.feed_subscriptions is
  E'Users can be subscribed to feeds.';
comment on column app_public.feed_subscriptions.subscriber_id is
  E'The subscribing user.';
comment on column app_public.feed_subscriptions.is_maintainer is
  E'Maintainers can manage subscriptions and delete the feed.';

grant select on app_public.feed_subscriptions to :DATABASE_VISITOR;
grant insert (feed_id, subscriber_id) on app_public.feed_subscriptions to :DATABASE_VISITOR;
grant update (is_maintainer) on app_public.feed_subscriptions to :DATABASE_VISITOR;
grant delete on app_public.feed_subscriptions to :DATABASE_VISITOR;

create or replace function app_public.my_subscribed_feed_ids() returns setof uuid as $$
  select feed_id from app_public.feed_subscriptions where subscriber_id = app_public.current_user_id();
$$ language sql stable parallel safe security definer set search_path to pg_catalog, public, pg_temp;

create or replace function app_public.my_feed_subscriptions() returns setof app_public.feed_subscriptions as $$
  select * from app_public.feed_subscriptions where subscriber_id = app_public.current_user_id() and feed_id in (select app_public.my_subscribed_feed_ids());
$$ language sql stable parallel safe;

-- Every subscriber should be able to see her or his feeds, even if private.
create policy show_subscribed on app_public.feeds for select using (id in (select app_public.my_subscribed_feed_ids()));
-- Maintainers should be able to update their feeds.
create policy manage_maintained on app_public.feeds for all using (id in (select feed_id from app_public.my_feed_subscriptions() where is_maintainer));

alter table app_public.feed_subscriptions enable row level security;
-- You should see your own feed_subscriptions.
create policy select_own on app_public.feed_subscriptions for select using (subscriber_id = app_public.current_user_id());
-- You should see others in your feeds.
create policy select_peers on app_public.feed_subscriptions for select using (feed_id in (select app_public.my_subscribed_feed_ids()));
-- You should be able to unsubscribe from your feeds.
create policy delete_own on app_public.feed_subscriptions for delete using (subscriber_id = app_public.current_user_id());
-- Maintainers can unsubscribe others from their feeds.
create policy manage_maintained on app_public.feed_subscriptions for all using (feed_id in (select feed_id from app_public.my_feed_subscriptions() where is_maintainer));
-- You should be able to subscribe public feeds
create policy subscribe_public_feeds on app_public.feed_subscriptions for insert with check (
  subscriber_id = app_public.current_user_id()
  and feed_id in (select id from app_public.feeds where not is_private)
);



create trigger _100_timestamps
  before insert or update on app_public.feed_subscriptions
  for each row
  execute procedure app_private.tg__timestamps();


-- TABLE feed_posts
create table app_public.feed_posts (
  id uuid primary key default uuid_generate_v1mc(),
  feed_id uuid not null
    constraint feed
      references app_public.feeds (id)
      on update cascade on delete cascade,
  sender_id uuid
    default app_public.current_user_id()
    constraint sender
      references app_public.users (id)
      on update cascade on delete set null,
  body text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  constraint empty_body_if_and_only_if_deleted check (is_deleted = (body is null))
);

grant select on app_public.feed_posts to :DATABASE_VISITOR;
grant insert (feed_id, body) on app_public.feed_posts to :DATABASE_VISITOR;
grant update (body, is_deleted) on app_public.feed_posts to :DATABASE_VISITOR;

alter table app_public.feed_posts enable row level security;


create trigger _100_timestamps
  before insert or update on app_public.feed_posts
  for each row
  execute procedure app_private.tg__timestamps();









/*

This project is using Graphile Migrate to manage migrations; please be aware
the Graphile Migrate works in a different way to most other migration
frameworks:

- it's "up-only" (there are no down migrations)
- the current migration (this file) is executed every time it is saved
- it requires *significant discipline* as changes made in this file will
  persist locally even after they are deleted from the file

Because during development the current migration is expected to run multiple
times, the migration has to deal with both the situation where it _has_ been
executed before, and where it _hasn't_ been executed before.

You can (and should) read more on Graphile Migrate in its repository:

  https://github.com/graphile/migrate

You can absolutely switch out Graphile Migrate for a more traditional
migration framework if you prefer.

*/

--------------------------------------------------------------------------------

/*

What follows is an example of a table that could be created after setup is
complete. To use it uncomment the statements below and save the file -
graphile-migrate will update the schema into database automagically and
PostGraphile should automatically detect these changes and reflect them
through GraphQL which you should see immediately in GraphiQL.

Note any "DROP" statements should be at the top in reverse order of creation.
The reason for reverse order is because we could have references from the
second created resource to the first created resource. So your migration
might look something like this pseudo-example:

    DROP C;
    DROP B;
    DROP A;
    CREATE A;
    CREATE B REFERENCING A;
    CREATE C REFERENCING A;

We have to DROP B before DROP A because we have references that point to A
from B.

You can uncomment the following lines one block a time and safe the file to view
the changes.

**IMPORTANT**: when you uncomment the `CREATE TABLE` statements this will not
result in the table being added to the GraphQL API, this is because we are
using `ignoreRBAC: false` so we do not expose tables until you `GRANT` the
relevant operations on them. The tables will appear when you uncomment the
`GRANT` lines.

*/

-- drop table if exists app_public.user_feed_posts;
-- drop table if exists app_public.posts;
-- drop table if exists app_public.topics;

-- create table app_public.topics (
--   title            text not null primary key
-- );
-- alter table app_public.topics enable row level security;

-- create table app_public.posts (
--   id               serial primary key,
--   author_id        uuid default app_public.current_user_id() references app_public.users(id) on delete set null,
--   headline         text not null check (char_length(headline) < 280),
--   body             text,
--   topic            text not null references app_public.topics on delete restrict,
--   created_at       timestamptz not null default now(),
--   updated_at       timestamptz not null default now()
-- );
-- alter table app_public.posts enable row level security;
-- create index on app_public.posts (author_id);

-- create trigger _100_timestamps before insert or update on app_public.posts for each row execute procedure app_private.tg__timestamps();

-- grant
--   select,
--   insert (headline, body, topic),
--   update (headline, body, topic),
--   delete
-- on app_public.posts to :DATABASE_VISITOR;

-- create policy select_all on app_public.posts for select using (true);
-- create policy manage_own on app_public.posts for all using (author_id = app_public.current_user_id());
-- create policy manage_as_admin on app_public.posts for all using (exists (select 1 from app_public.users where is_admin is true and id = app_public.current_user_id()));

-- comment on table app_public.posts is 'A forum post written by a `User`.';
-- comment on column app_public.posts.id is 'The primary key for the `Post`.';
-- comment on column app_public.posts.headline is 'The title written by the `User`.';
-- comment on column app_public.posts.author_id is 'The id of the author `User`.';
-- comment on column app_public.posts.topic is 'The `Topic` this has been posted in.';
-- comment on column app_public.posts.body is 'The main body text of our `Post`.';
-- comment on column app_public.posts.created_at is 'The time this `Post` was created.';
-- comment on column app_public.posts.updated_at is 'The time this `Post` was last modified (or created).';

-- create table app_public.user_feed_posts (
--   id               serial primary key,
--   user_id          uuid not null references app_public.users on delete cascade,
--   post_id          int not null references app_public.posts on delete cascade,
--   created_at       timestamptz not null default now()
-- );
-- alter table app_public.user_feed_posts enable row level security;
-- create index on app_public.user_feed_posts (user_id);
-- create index on app_public.user_feed_posts (post_id);

-- grant select on app_public.user_feed_posts to :DATABASE_VISITOR;

-- create policy select_own on app_public.user_feed_posts for select using (user_id = app_public.current_user_id());

-- comment on table app_public.user_feed_posts is 'A feed of `Post`s relevant to a particular `User`.';
-- comment on column app_public.user_feed_posts.id is 'An identifier for this entry in the feed.';
-- comment on column app_public.user_feed_posts.created_at is 'The time this feed item was added.';
