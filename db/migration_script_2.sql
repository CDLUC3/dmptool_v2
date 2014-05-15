# SET VARIABLES 

# set SQL properties to resolve problems with institution.id = 0
SET SQL_MODE         = NO_AUTO_VALUE_ON_ZERO;
SET SQL_SAFE_UPDATES = 0;

#set cutoff date and time for migration
SET @cutoff = '2014-05-14 22:59:00'; #UTC format


# ALTER TABLES

# add user column to keep track of the relationship between user and plan in user_plans table
ALTER TABLE `dmp2`.`users`                  ADD `old_user_id`             INT(11);


#DATA MIGRATION

#migrate new dmp1 users
INSERT INTO `dmp2`.`users` (
       `institution_id`, `email`,                  `first_name`, `last_name`,
       `token`,          `token_expiration`,       `prefs`,      `created_at`,
       `updated_at`,                   `active`,  
       `old_user_id`)
SELECT `institution_id`, `email`,            `first_name`,     `last_name`,  
	`token`,          `token_expiration`, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',    
	`created_at`, `updated_at`, 1, `id`
FROM `dmp`.`users` AS `users_1`
WHERE `users_1`.`created_at` >= @cutoff; #new dmp1 users

#update the login_id for the new users: from uid in
# the DMP1 authentications table, where provider is ldap; then update the login_id
# where provider is shibboleth and login_id is null, 
#if a user modifies his record in both dmp1 and dmp2, dmp2 will be overwritten
UPDATE `dmp2`.`users` AS `users_2`
JOIN   `dmp`.`authentications` AS `auth_1` ON `auth_1`.`user_id` = `users_2`.`old_user_id`
SET `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`provider` = 'ldap' AND `users_2`.`created_at` >= @cutoff;

UPDATE `dmp2`.`users` AS `users_2`
JOIN   `dmp`.`authentications` AS `auth_1` ON `auth_1`.`user_id` = `users_2`.`id`
SET `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`provider` = 'shibboleth'
AND   `users_2`.`login_id` IS NULL  AND `users_2`.`created_at` >= @cutoff;

#update dmp2 users  with old dmp1 users modifications, 
#if a user modifies his record in both dmp1 and dmp2, dmp2 will be overwritten
UPDATE `dmp2`.`users` AS `users_2`
JOIN 	 `dmp`.`users` AS `users_1` ON `users_1`.`id` = `users_2`.`old_user_id`
SET 	 `users_2`.`institution_id` = `users_1`.`institution_id`,
			 `users_2`.`email` 					= `users_1`.`email`,
			 `users_2`.`first_name` 		= `users_1`.`first_name`,
			 `users_2`.`last_name` 			= `users_1`.`last_name`,
			 `users_2`.`prefs` 					=  X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
			 `users_2`.`updated_at` 		= `users_1`.`updated_at`
WHERE `users_1`.`created_at` < @cutoff; #old dmp1 users

#migrate all the plans (any dmp2 plan will be overwritten)
TRUNCATE TABLE `dmp2`.`plans`;
INSERT INTO `dmp2`.`plans` (
       `id`,                      `name`,                `requirements_template_id`,
       `solicitation_identifier`, `submission_deadline`, `visibility`,
       `created_at`,              `updated_at`,          `current_plan_state_id`)
SELECT `id`,                      `name`,                `funder_template_id`,
       `solicitation_no`,          NULL,                 'private',
       `created_at`,              `updated_at`,           NULL
FROM `dmp`.`plans`;

#migrate all user_plans from dmp1 to dmp2 
TRUNCATE TABLE `dmp2`.`user_plans`;
INSERT INTO `dmp2`.`user_plans` (
       `id`, `user_id`, `plan_id`, `owner`, `created_at`, `updated_at`)
SELECT `id`, `user_id`, `plan_id`,  1,      `created_at`, `updated_at`
FROM `dmp`.`user_plans` ;

#update dmp2 user_plans with the correct user_id set after the migration (the id of the user is changed after the migration), 
#only if the user is not a new dmp2 user (new dmp2 users will not have any plans since their plans are being overwritten)
UPDATE `dmp2`.`user_plans` AS `user_plans_2`
JOIN 	 `dmp2`.`users` AS `users_2` ON `user_plans_2`.`user_id` = `users_2`.`old_user_id`
SET 	 `user_plans_2`.`user_id` 	= `users_2`.`id`
WHERE  `users_2`.`old_user_id` IS NOT NULL; #only dmp1 users

#plan_states is new in dmp2, we need to add a row for every plan and set its state to 'new'
# First, create a plan state record for every user plan,
# then update plans.current_plan_state_id to the state
# set to "new"
TRUNCATE TABLE `dmp2`.`plan_states`;
INSERT INTO `dmp2`.`plan_states` (
       `plan_id`, `state`, `user_id`, `created_at`, `updated_at`)
SELECT `plan_id`, 'new',   `user_id`, `created_at`, `updated_at`
FROM `dmp2`.`user_plans` ;

UPDATE `dmp2`.`plans` AS `plans_2`
JOIN   `dmp2`.`plan_states` AS `plan_states_2` ON `plan_states_2`.`plan_id` = `plans_2`.`id`
SET `plans_2`.`current_plan_state_id` = `plan_states_2`.`id`;


#migrate answers to responses and overwrite all the previous responses
TRUNCATE TABLE `dmp2`.`responses`;
INSERT INTO `dmp2`.`responses` (
       `id`, `plan_id`, `requirement_id`, `text_value`,`created_at`, `updated_at`, `lock_version`)
SELECT `id`, `plan_id`, `question_id`   ,  `text`     , `created_at`, `updated_at`, 0
FROM `dmp`.`answers`; 



ALTER TABLE `dmp2`.`users`                  DROP COLUMN `old_user_id`;










