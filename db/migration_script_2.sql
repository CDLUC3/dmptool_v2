# add columns to track DMP1 keys
ALTER TABLE `dmp2`.`users`                  ADD `old_user_id`             INT(11);

#migrate new dmp1 users
INSERT INTO `dmp2`.`users` (
       `institution_id`, `email`,                  `first_name`, `last_name`,
       `token`,          `token_expiration`,       `prefs`,      `created_at`,
       `updated_at`,     `login_id`,               `active`,  
       `old_user_id`)
SELECT `institution_id`, `email`,            `first_name`,     `last_name`,  
				`token`,          `token_expiration`, 			`prefs`,    `created_at`, 
				`updated_at`,      `login_id`,               1, 
				`id`
FROM `dmp`.`users` AS `users_1`
WHERE `users_1`.`created_at` >= '2014-05-16 10:00:00'; #new dmp1 users


#update the login_id for the new users: from uid in
# the DMP1 authentications table, where provider is ldap; then update the login_id
# where provider is shibboleth and login_id is null, 
#if a user modifies his record in both dmp1 and dmp2, dmp2 will be overwritten
UPDATE `dmp2`.`users` AS `users_2`
JOIN   `dmp`.`authentications` AS `auth_1` ON `auth_1`.`user_id` = `users_2`.`id`
SET `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`provider` = 'ldap' AND `users_2`.`created_at` >= '2014-05-16 10:00:00';

UPDATE `dmp2`.`users` AS `users_2`
JOIN   `dmp`.`authentications` AS `auth_1` ON `auth_1`.`user_id` = `users_2`.`id`
SET `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`provider` = 'shibboleth'
AND   `users_2`.`login_id` IS NULL  AND `users_2`.`created_at` >= '2014-05-16 10:00:00';


#update dmp2 users  with old dmp1 users modifications, if a user modifies his record in both dmp1 and dmp2, dmp2 will be overwritten
UPDATE `dmp2`.`users` AS `users_2`
JOIN 	 `dmp`.`users` AS `users_1` ON `users_1`.`id` = `users_2`.`old_user_id`
SET 	 `users_2`.`institution_id` = `users_1`.`institution_id`,
			 `users_2`.`email` 					= `users_1`.`email`,
			 `users_2`.`first_name` 		= `users_1`.`first_name`,
			 `users_2`.`last_name` 			= `users_1`.`last_name`,
			 `users_2`.`prefs` 					= `users_1`.`prefs`,
			 `users_2`.`updated_at` 		= `users_1`.`updated_at`,
WHERE `users_1`.`created_at` < '2014-05-16 10:00:00'; #old dmp1 users


#migrate all the plans
INSERT INTO `dmp2`.`plans` AS `plans_2` (
       `id`,                      `name`,                `requirements_template_id`,
       `solicitation_identifier`, `submission_deadline`, `visibility`,
       `created_at`,              `updated_at`,          `current_plan_state_id`)
SELECT `id`,                      `name`,                `funder_template_id`,
       `solicitation_no`,          NULL,                 'private',
       `created_at`,              `updated_at`,           NULL
FROM `dmp`.`plans` AS `plans_1`;


#migrate all the comments, all changes made in dmp2  will be overwritten by changes made in dmp1






