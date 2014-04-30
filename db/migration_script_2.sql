# add columns to track DMP1 keys
ALTER TABLE `dmp2`.`users`                  ADD `old_user_id`             INT(11);



#update dmp2 users with dmp1 modifications





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
WHERE `users_1`.`created_at` >= '2014-05-16 10:00:00';



#dmp1 user_plans

#migrate new dmp1 plans
INSERT INTO `dmp2`.`plans` (
       `id`,                      `name`,                `requirements_template_id`,
       `solicitation_identifier`, `submission_deadline`, `visibility`,
       `created_at`,              `updated_at`,          `current_plan_state_id`)
SELECT `id`,                      `name`,                `funder_template_id`,
       `solicitation_no`,          NULL,                 'private',
       `created_at`,              `updated_at`,           NULL
FROM `dmp`.`plans`;