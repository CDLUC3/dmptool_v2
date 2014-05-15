SELECT * 
FROM `dmp2`.`users` AS `users_2`
JOIN  `dmp`.`authentications` AS `auth_1` ON `users_2`.`login_id` = `auth_1`.`uid`
WHERE `auth_1`.`created_at` >= '2014-05-15 17:05:00';