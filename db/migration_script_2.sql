INSERT INTO `dmp2`.`users` (
       `institution_id`, `email`,                  `first_name`, `last_name`,
       `token`,          `token_expiration`,       `prefs`,      `created_at`,
       `updated_at`,     `login_id`,               `active`,     `deleted_at`,
       `old_user_id`)
SELECT `institution_id`, `email`,            `first_name`,     `last_name`,  
				`token`,          `token_expiration`, 			`prefs`,    `created_at`, 
				`updated_at`,      `login_id`,               1
FROM `dmp`.`users`;