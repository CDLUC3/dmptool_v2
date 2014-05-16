SET @cutoff = '2014-05-15 17:05:00'; #UTC format, corresponds to timestamp of first migration

SELECT * 
FROM `dmp2`.`users` AS `users_2`
JOIN  `dmp`.`authentications` AS `auth_1` ON `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`created_at` >= @cutoff;