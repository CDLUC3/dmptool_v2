SET @cutoff = '2014-05-15 17:05:00'; #UTC format, corresponds to timestamp of first migration


#removes any users on dmp2 that has been added to both dmp1 and dmp2 after migration1 and before migration2 
DELETE `users_2`
FROM `dmp2`.`users` AS `users_2`
INNER JOIN  `dmp`.`authentications` AS `auth_1` 
	ON `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`created_at` > @cutoff;



#Output any roles that a duplicate user might have been granted on dmp2
SELECT `users_2`.`id` as `user_id`, `users_2`.`first_name`,`users_2`.`last_name`,`users_2`.`created_at`, `users_2`.`updated_at`, `users_2`.`institution_id`, 
	`authorizations_2`.`role_id`, `roles_2`.`name` as `role_name`
FROM `dmp2`.`users` AS `users_2`
INNER JOIN  `dmp`.`authentications` AS `auth_1` 
	ON `users_2`.`login_id` = `auth_1`.`uid`
LEFT OUTER JOIN `dmp2`.`authorizations` AS `authorizations_2`
	ON `users_2`.`id` = `authorizations_2`.`user_id`
LEFT OUTER JOIN `dmp2`.`roles` AS `roles_2`
	ON `authorizations_2`.`role_id` = `roles_2`.`id`
WHERE `auth_1`.`created_at` > @cutoff;
