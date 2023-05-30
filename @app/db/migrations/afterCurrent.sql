
-- organization id: 629684b4-fd40-11ed-93d6-677b9143f9b6


insert into app_public.organizations (id, name, slug)
values
  ('629684b4-fd40-11ed-93d6-677b9143f9b6', 'Fun with Ballz', 'fun_with_ballz')
on conflict do nothing;

insert into app_public.users (id, username, name, is_verified)
values
  ('8f1918de-fd41-11ed-9ff7-2fcba8915da5', 'fred', 'Fred Flintstones', true),
  ('990d29de-fd41-11ed-8f9f-3fa561d2843f', 'wilma', 'Wilma Flintstones', true)
on conflict do nothing;

update app_private.user_secrets set password_hash = crypt('fred', gen_salt('bf')) where user_id = '8f1918de-fd41-11ed-9ff7-2fcba8915da5';
update app_private.user_secrets set password_hash = crypt('wilma', gen_salt('bf')) where user_id = '990d29de-fd41-11ed-8f9f-3fa561d2843f';

insert into app_public.organization_memberships (id, organization_id, user_id, is_owner)
values
  ('f6870bde-fd41-11ed-b53b-df5ad25f9ef4', '629684b4-fd40-11ed-93d6-677b9143f9b6', '990d29de-fd41-11ed-8f9f-3fa561d2843f', true),
  ('fbe5df88-fd41-11ed-849a-0712d2e978f4', '629684b4-fd40-11ed-93d6-677b9143f9b6', '8f1918de-fd41-11ed-9ff7-2fcba8915da5', false)
on conflict do nothing;

insert into app_public.bowling_alleys (id, organization_id, name, maximum_number_of_players)
values
  ('3a803f9a-fd42-11ed-b238-4ff6087e1eaa', '629684b4-fd40-11ed-93d6-677b9143f9b6', 'Bahn 1', 6),
  ('5b7d5a7a-b033-4435-9968-a57c30dc2342', '629684b4-fd40-11ed-93d6-677b9143f9b6', 'Bahn 2', 6),
  ('9fcfaf1c-bbc3-479e-b9a1-36eb88505047', '629684b4-fd40-11ed-93d6-677b9143f9b6', 'Bahn 3', 6),
  ('6e79b591-6166-4e75-ae35-95faf4852cb6', '629684b4-fd40-11ed-93d6-677b9143f9b6', 'Bahn 4', 6);

insert into app_public.bookings (id) values ('b1f7c20d-343f-4dda-9e4f-6233170c65bf');

insert into app_public.alley_bookings (booking_id, alley_id, timeslot)
values
  ('b1f7c20d-343f-4dda-9e4f-6233170c65bf', '3a803f9a-fd42-11ed-b238-4ff6087e1eaa', '[2023-05-28 13:00:00, 2023-05-28 14:30:00)');
