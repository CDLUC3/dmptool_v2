# add columns to track DMP1 keys
ALTER TABLE `dmp2`.`institutions`           ADD `old_funder_id`           INT(11);
ALTER TABLE `dmp2`.`requirements_templates` ADD `old_funder_id`           INT(11);
ALTER TABLE `dmp2`.`resources`              ADD `old_funder_id`           INT(11);
ALTER TABLE `dmp2`.`resources`              ADD `old_help_text_id`        INT(11);
ALTER TABLE `dmp2`.`resources`              ADD `old_institution_id`      INT(11);
ALTER TABLE `dmp2`.`resources`              ADD `old_suggested_answer_id` INT(11);
ALTER TABLE `dmp2`.`resource_contexts`      ADD `old_funder_id`           INT(11);
ALTER TABLE `dmp2`.`users`                  ADD `old_user_id`             INT(11);


# set SQL properties to resolve problems with institution.id = 0
SET SQL_MODE         = NO_AUTO_VALUE_ON_ZERO;
SET SQL_SAFE_UPDATES = 0;


# institutions: first copy the institutions;
# then copy DMP1 funders, which DMP2 considers to be institutions as well
TRUNCATE TABLE `dmp2`.`institutions`;
INSERT INTO `dmp2`.`institutions` (
       `id`,            `full_name`,  `nickname`, `desc`,           `contact_info`,
       `contact_email`, `url`,        `url_text`, `shib_entity_id`, `shib_domain`,
       `created_at`,    `updated_at`, `logo`,     `ancestry`,       `deleted_at`)
SELECT `id`,            `name`,       `nickname`,  NULL,            `contact_info`,
       `contact_email`, `url`,        `url_text`, `shib_entity_id`, `shib_domain`,
       `created_at`,    `updated_at`,  NULL,       NULL,             NULL
FROM `dmp`.`institutions`;

INSERT INTO `dmp2`.`institutions` (
       `full_name`,     `nickname`,   `desc`,          `contact_info`,
       `contact_email`, `url`,        `url_text`,      `shib_entity_id`,
       `shib_domain`,   `created_at`, `updated_at`,    `logo`,
       `ancestry`,      `deleted_at`, `old_funder_id`)
SELECT `desc`,          `name`,        NULL,            NULL,
        NULL,            NULL,         NULL,            NULL,
        NULL,           `created_at`, `updated_at`,     NULL,
        NULL,            NULL,        `f`.`id`
FROM `dmp`.`funders` AS `f`;


# users: first copy all of the DMP1 users; then update the login_id from uid in
# the DMP1 authentications table, where provider is ldap; then update the login_id
# where provider is shibboleth and login_id is null
TRUNCATE TABLE `dmp2`.`users`;
INSERT INTO `dmp2`.`users` (
       `id`,         `institution_id`, `email`,            `first_name`,
       `last_name`,  `token`,          `token_expiration`, `prefs`,
       `created_at`, `updated_at`,     `login_id`,         `active`)
SELECT `id`,         `institution_id`, `email`,            `first_name`,
       `last_name`,  `token`,          `token_expiration`, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
     `created_at`, `updated_at`,      NULL,               1
FROM `dmp`.`users`;

UPDATE `dmp2`.`users` AS `u`
JOIN   `dmp`.`authentications` AS `a` ON `a`.`user_id` = `u`.`id`
SET `u`.`login_id` = `a`.`uid`
WHERE `a`.`provider` = 'ldap';

UPDATE `dmp2`.`users` AS `u`
JOIN   `dmp`.`authentications` AS `a` ON `a`.`user_id` = `u`.`id`
SET `u`.`login_id` = `a`.`uid`
WHERE `a`.`provider` = 'shibboleth'
AND   `u`.`login_id` IS NULL;


# insert users who are not present in the old tool
INSERT INTO `dmp2`.`users` (
       `institution_id`, `email`,                  `first_name`, `last_name`,
       `token`,          `token_expiration`,       `prefs`,      `created_at`,
       `updated_at`,     `login_id`,               `active`,     `deleted_at`,
       `old_user_id`)
VALUES (1,               'shirin.faenza@ucop.edu', 'Shirin',     'Faenza',
NULL,             NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-10-22 20:55:35', '2013-11-05 17:50:25', 'sfaenza', 1, NULL, 5),
       (1, 'bhavi.vedula04@gmail.com', 'Bhavi', 'Vedula', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-10-28 22:12:01', '2013-11-04 08:47:36', 'bhavi.vedula04', 1, NULL, 11),
       (1, 'admin123@gmail.com', 'Admin123', 'Admin', '123', NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-01 23:46:01', '2013-12-11 20:40:29', 'admin123', 1, NULL, 13),
       (1, 'resource123@gmail.com', 'Resource123',  '123', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-01 23:46:51', '2013-12-20 21:32:03', 'resource123', 1, NULL, 14),
       (1, 'require123@gmail.com', 'Require123',  '123', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-01 23:47:12', '2013-11-05 17:33:48', 'require123', 1, NULL, 15),
       (1, 'instrev123@gmail.com', 'Instrev123',  '123', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-01 23:47:37', '2013-11-05 15:20:10', 'instrev123', 1, NULL, 16),
       (1, 'instadmin123@gmail.com', 'Instadmin123',  '123', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-01 23:48:06', '2014-01-07 22:21:56', 'instadmin123', 1, NULL, 17),
       (1, 'esatzman@ucop.edu', 'Eric', 'Satzman', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-04 21:58:34', '2013-11-04 21:58:34', 'esatzman', 1, NULL, 18),
       (1, 'carly.strasser@ucop.edu', 'Carly', 'Strasser', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-05 22:37:14', '2014-01-14 01:14:41', 'cstrasser', 1, NULL, 23),
       (1, 'test_user2@gmail.com', 'Test', 'User2', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-11-12 22:22:19', '2014-01-07 22:20:29', 'test_user2', 1, NULL, 27),
       (1, 'Carly.Strasser@ucop.edu', NULL, NULL, NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2013-12-17 17:52:39', '2013-12-17 17:52:39',
       'Carly.Strasser-ucop.edu@ucop.edu', 1, NULL, 89),
       (1, 'Rosalie.Lack@ucop.edu', 'Rosalie', 'Lack', NULL, NULL, X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A',
       '2014-01-08 19:31:16', '2014-01-08 19:31:43',
       'Rosalie.Lack-ucop.edu@ucop.edu', 1, NULL, 91);


# authentications: no migration necessary
TRUNCATE TABLE `dmp2`.`authentications`;


# authorizations: copy the admin user authorization
TRUNCATE TABLE `dmp2`.`authorizations`;
INSERT INTO `dmp2`.`authorizations` (
       `role_id`, `user_id`, `created_at`, `updated_at`)
SELECT  1,        `id`,      `created_at`, `updated_at`
FROM  `dmp2`.`users`
WHERE `dmp2`.`users`.`email` = 'admin123@gmail.com';

INSERT INTO `dmp2`.`authorizations` (
       `role_id`, `user_id`, `created_at`, `updated_at`)
SELECT  5,        `id`,      `created_at`, `updated_at`
FROM  `dmp2`.`users`
WHERE `dmp2`.`users`.`email` = 'instadmin123@gmail.com';

INSERT INTO `dmp2`.`authorizations` (
       `role_id`, `user_id`, `created_at`, `updated_at`)
SELECT  3,        `id`,      `created_at`, `updated_at`
FROM  `dmp2`.`users`
WHERE `dmp2`.`users`.`email` = 'require123@gmail.com';

INSERT INTO `dmp2`.`authorizations` (
       `role_id`, `user_id`, `created_at`, `updated_at`)
SELECT  2,        `id`,      `created_at`, `updated_at`
FROM  `dmp2`.`users`
WHERE `dmp2`.`users`.`email` = 'resource123@gmail.com';

INSERT INTO `dmp2`.`authorizations` (
       `role_id`, `user_id`, `created_at`, `updated_at`)
SELECT  4,        `id`,      `created_at`, `updated_at`
FROM  `dmp2`.`users`
WHERE `dmp2`.`users`.`email` = 'instrev123@gmail.com';



# requirements_templates: first copy the DMP1 funder_templates data into DMP2
# requirements_templates
# institution PKs
TRUNCATE TABLE `dmp2`.`requirements_templates`;
INSERT INTO `dmp2`.`requirements_templates` (
       `id`,         `institution_id`, `name`,        `active`,     `start_date`,
       `end_date`,   `visibility`,     `review_type`, `created_at`, `updated_at`,
       `old_funder_id`)
SELECT `id`,          NULL,            `name`,        `active`,     `start_date`,
       `end_date`,   'public',         'no_review',   `created_at`, `updated_at`,
       `t`.`funder_id`
FROM `dmp`.`funder_templates` AS `t`;

# now map old funder IDs to new institution IDs
UPDATE `dmp2`.`requirements_templates` AS `t`
JOIN `dmp2`.`institutions` AS `i` ON `i`.`old_funder_id` = `t`.`old_funder_id`
SET `t`.`institution_id` = `i`.`id`;


# requirements: copy DMP1 questions, with some information from question_templates
TRUNCATE TABLE `dmp2`.`requirements`;
INSERT INTO `dmp2`.`requirements` (
       `id`,            `position`,                 `text_brief`,
       `text_full`,     `requirement_type`,         `obligation`,
       `default`,       `requirements_template_id`, `created_at`,
       `updated_at`,    `ancestry`,                 `group`)
SELECT `q`.`id`,        `t`.`question_order`,       `q`.`text_brief`,
       `q`.`text_full`, 'text',                     'optional',
        NULL,           `t`.`funder_template_id`,   `q`.`created_at`,
       `q`.`updated_at`, NULL,                       0
FROM `dmp`.`questions`          AS `q`
JOIN `dmp`.`question_templates` AS `t` ON `t`.`question_id` = `q`.`id`;


# responses: copy the DMP1 answers
TRUNCATE TABLE `dmp2`.`responses`;
INSERT INTO `dmp2`.`responses` (
       `id`,         `plan_id`, `requirement_id`, `label_id`, `text_value`,
             `created_at`, `updated_at`)
SELECT `id`,         `plan_id`, `question_id`,     NULL,      `text`,
       `created_at`, `updated_at`
FROM `dmp`.`answers`;


# user_plans: copy the DMP1 user plans into DMP2
TRUNCATE TABLE `dmp2`.`user_plans`;
INSERT INTO `dmp2`.`user_plans` (
       `id`, `user_id`, `plan_id`, `owner`, `created_at`, `updated_at`)
SELECT `id`, `user_id`, `plan_id`,  1,      `created_at`, `updated_at`
FROM `dmp`.`user_plans`;


# plans: copy DMP1 plans into DMP2
TRUNCATE TABLE `dmp2`.`plans`;
INSERT INTO `dmp2`.`plans` (
       `id`,                      `name`,                `requirements_template_id`,
       `solicitation_identifier`, `submission_deadline`, `visibility`,
       `created_at`,              `updated_at`,          `current_plan_state_id`)
SELECT `id`,                      `name`,                `funder_template_id`,
       `solicitation_no`,          NULL,                 'private',
       `created_at`,              `updated_at`,           NULL
FROM `dmp`.`plans`;


# plan_states: first, create a plan state record for every user plan,
# with the status; then update plans.current_plan_state_id to the state
# set to "new"
TRUNCATE TABLE `dmp2`.`plan_states`;
INSERT INTO `dmp2`.`plan_states` (
       `plan_id`, `state`, `user_id`, `created_at`, `updated_at`)
SELECT `plan_id`, 'new',   `user_id`, `created_at`, `updated_at`
FROM `dmp2`.`user_plans` ;

UPDATE `dmp2`.plans AS `p`
JOIN   `dmp2`.`plan_states` AS `s` ON `s`.`plan_id` = `p`.`id`
SET `p`.`current_plan_state_id` = `s`.`id`;


# resources: first copy DMP1 resources into DMP2 URL resources;
# then insert DMP1 help and suggested answers,
# using their first 50 characters as labels (the actionable URLs labels will not be truncated)
# help and suggested answers are de-duplicated within institutions
TRUNCATE TABLE `dmp2`.`resources`;
INSERT INTO `dmp2`.`resources` (
       `id`,         `resource_type`,  `value`, `label`, `created_at`,
       `updated_at`, `text`)
SELECT `id`,         'actionable_url', `url`,   `desc`,  `created_at`,
       `updated_at`,  NULL
FROM `dmp`.`resources`;

# then copy DMP1 help texts into DMP2 resources where institution ID is NULL
# but only for unique combinations of funder ID and help text; 
INSERT INTO `dmp2`.`resources` (
       `resource_type`,    `value`,                   `label`,
       `created_at`,       `updated_at`,              `text`,
       `old_help_text_id`, `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'help_text',         NULL, CONCAT(LEFT(dmp2.fnStripTags(`h`.`help_text`), 50), '...'),
       `h`.`created_at`,   `h`.`updated_at`,          `help_text`,
       `h`.`id`,            NULL,                      NULL,
       `f`.`funder_id`
FROM `dmp`.`help_texts`         AS `h`
JOIN `dmp`.`question_templates` AS `t` ON `t`.`question_id` = `h`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON `f`.`id`          = `t`.`funder_template_id`
WHERE `h`.`institution_id` IS NULL
AND LENGTH(dmp2.fnStripTags(`h`.`help_text`)) > 50
GROUP BY `f`.`funder_id` ASC, `h`.`help_text` ASC;

INSERT INTO `dmp2`.`resources` (
       `resource_type`,    `value`,                   `label`,
       `created_at`,       `updated_at`,              `text`,
       `old_help_text_id`, `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'help_text',         NULL,        LEFT(dmp2.fnStripTags(`help_text`), 50),
       `h`.`created_at`,   `h`.`updated_at`,          `help_text`,
       `h`.`id`,            NULL,                      NULL,
       `f`.`funder_id`
FROM `dmp`.`help_texts`         AS `h`
JOIN `dmp`.`question_templates` AS `t` ON `t`.`question_id` = `h`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON `f`.`id`          = `t`.`funder_template_id`
WHERE `h`.`institution_id` IS NULL
AND LENGTH(dmp2.fnStripTags(`h`.`help_text`)) <= 50
GROUP BY `f`.`funder_id` ASC, `h`.`help_text` ASC;

# finally copy DMP1 help texts into DMP2 resources where institution ID is not NULL,
# but only for unique combinations of institution ID and help text
INSERT INTO `dmp2`.`resources` (
       `resource_type`,    `value`,                   `label`,
       `created_at`,       `updated_at`,              `text`,
       `old_help_text_id`, `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'help_text',         NULL, CONCAT(LEFT(dmp2.fnStripTags(`help_text`) ,50), '...'),
       `created_at`,       `updated_at`,              `help_text`,
       `id`,                NULL,                     `institution_id`,
        NULL
FROM `dmp`.`help_texts` AS `h`
WHERE `institution_id` IS NOT NULL
AND LENGTH(dmp2.fnStripTags(`h`.`help_text`)) > 50
GROUP BY `institution_id` ASC, `help_text` ASC;

INSERT INTO `dmp2`.`resources` (
       `resource_type`,      `value`,                   `label`,
       `created_at`,         `updated_at`,              `text`,
       `old_help_text_id`,   `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'help_text',           NULL,      LEFT(dmp2.fnStripTags(`help_text`), 50),
       `created_at`,         `updated_at`,              `help_text`,
       `id`,                  NULL,                     `institution_id`,
        NULL
FROM `dmp`.`help_texts` AS `h`
WHERE `institution_id` IS NOT NULL
AND LENGTH(dmp2.fnStripTags(`h`.`help_text`)) <= 50
GROUP BY `institution_id` ASC, `help_text` ASC;

# now do the same thing for suggested answers 
INSERT INTO `dmp2`.`resources` (
       `resource_type`,     `value`,                   `label`,
       `created_at`,        `updated_at`,              `text`,
       `old_help_text_id`,  `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'suggested_response', NULL, CONCAT(LEFT(dmp2.fnStripTags(`suggested_answer_text`), 50), '...'),
       `a`.`created_at`,    `a`.`updated_at`,          `suggested_answer_text`,
        NULL,               `a`.`id`,                   NULL,
       `funder_id`
FROM `dmp`.`suggested_answers`  AS `a`
JOIN `dmp`.`question_templates` AS `t` ON `t`.`question_id` = `a`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON `f`.`id`          = `t`.`funder_template_id`
WHERE `a`.`institution_id` IS NULL
AND LENGTH(dmp2.fnStripTags(`a`.`suggested_answer_text`)) > 50
GROUP BY `f`.`funder_id` ASC, `a`.`suggested_answer_text` ASC;

INSERT INTO `dmp2`.`resources` (
       `resource_type`,     `value`,                   `label`,
       `created_at`,        `updated_at`,              `text`,
       `old_help_text_id`,  `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'suggested_response', NULL,        LEFT(dmp2.fnStripTags(`suggested_answer_text`), 50),
       `a`.`created_at`,    `a`.`updated_at`,          `suggested_answer_text`,
        NULL,               `a`.`id`,                   NULL,
       `funder_id`
FROM `dmp`.`suggested_answers`  AS `a`
JOIN `dmp`.`question_templates` AS `t` ON `t`.`question_id` = `a`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON `f`.`id`          = `t`.`funder_template_id`
WHERE `a`.`institution_id` IS NULL
AND LENGTH(dmp2.fnStripTags(`a`.`suggested_answer_text`)) <= 50
GROUP BY `f`.`funder_id` ASC, `a`.`suggested_answer_text` ASC;

INSERT INTO `dmp2`.`resources` (
       `resource_type`,      `value`,                   `label`,
       `created_at`,         `updated_at`,              `text`,
       `old_help_text_id`,   `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'suggested_response',  NULL, CONCAT(LEFT(dmp2.fnStripTags(`suggested_answer_text`), 50), '...'),
       `created_at`,         `updated_at`,              `suggested_answer_text`,
        NULL,                `id`,                      `institution_id`,
        NULL
FROM `dmp`.`suggested_answers` AS `a`
WHERE `institution_id` IS NOT NULL
AND LENGTH(dmp2.fnStripTags(`a`.`suggested_answer_text`)) > 50
GROUP BY `institution_id` ASC, `suggested_answer_text` ASC;

INSERT INTO `dmp2`.`resources` (
       `resource_type`,      `value`,                   `label`,
       `created_at`,         `updated_at`,              `text`,
       `old_help_text_id`,   `old_suggested_answer_id`, `old_institution_id`,
       `old_funder_id`)
SELECT 'suggested_response',  NULL,        LEFT(dmp2.fnStripTags(`suggested_answer_text`), 50),
       `created_at`,         `updated_at`,              `suggested_answer_text`,
        NULL,                `id`,                      `institution_id`,
        NULL
FROM `dmp`.`suggested_answers` AS `a`
WHERE `institution_id` IS NOT NULL
AND LENGTH(dmp2.fnStripTags(`a`.`suggested_answer_text`)) <= 50
GROUP BY `institution_id` ASC, `suggested_answer_text` ASC;


TRUNCATE TABLE `dmp2`.`resource_contexts`;
INSERT INTO `dmp2`.`resource_contexts` (
       `id`,         `institution_id`, `requirements_template_id`, `requirement_id`,
       `created_at`, `updated_at`,     `resource_id`,              `old_funder_id`)
SELECT `id`,         `institution_id`, `funder_template_id`,       `question_id`,
       `created_at`, `updated_at` ,    `resource_id`,               NULL
FROM `dmp`.`resource_contexts`
WHERE `question_id` >  0
OR    `question_id` IS NULL;

# then add help texts; since each help text is now only defined once per
# institution, so we must match on DMP2 resources by text and institution
# (or, if institution is NULL, by funder) and not just copy DMP1 help_texts
INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`, `requirements_template_id`, `requirement_id`,
       `created_at`,     `updated_at`,               `resource_id`,
       `old_funder_id`)
SELECT  NULL,            `t`.`funder_template_id`,   `h`.`question_id`,
       `h`.`created_at`, `h`.`updated_at`,           `r`.`id`,
       `f`.`funder_id`
FROM `dmp`.`help_texts`         AS `h`
JOIN `dmp`.`question_templates` AS `t` ON  `t`.`question_id`   = `h`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON  `f`.`id`            =
                                           `t`.`funder_template_id`
JOIN `dmp2`.`resources`         AS `r` ON (`r`.`text`          = `h`.`help_text`
                                       AND `r`.`old_funder_id` = `f`.`funder_id`)
WHERE `r`.`resource_type`  = 'help_text'
AND   `h`.`institution_id` IS NULL;

INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`,         `requirements_template_id`, `requirement_id`,
       `created_at`,             `updated_at`,               `resource_id`,
       `old_funder_id`)
SELECT `h`.`institution_id`,     `t`.`funder_template_id`,   `h`.`question_id`,
       `h`.`created_at`,         `h`.`updated_at`,           `r`.`id`,
        NULL
FROM `dmp`.`help_texts`         AS `h`
JOIN `dmp`.`question_templates` AS `t` ON  `t`.`question_id`        =
                                           `h`.`question_id`
JOIN `dmp2`.`resources`         AS `r` ON (`r`.`text`               = `h`.`help_text`
                                       AND `r`.`old_institution_id` =
                                           `h`.`institution_id`)
WHERE `r`.`resource_type`      = 'help_text'
AND   `r`.`old_institution_id` IS NOT NULL;

# now do the same thing for suggested answers
INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`,         `requirements_template_id`, `requirement_id`,
       `created_at`,             `updated_at`,               `resource_id`,
       `old_funder_id`)
SELECT  NULL,                    `t`.`funder_template_id`,   `a`.`question_id`,
       `a`.`created_at`,         `a`.`updated_at`,           `r`.`id`,
       `f`.`funder_id`
FROM `dmp`.`suggested_answers`  AS `a`
JOIN `dmp`.`question_templates` AS `t` ON  `t`.`question_id`   = `a`.`question_id`
JOIN `dmp`.`funder_templates`   AS `f` ON  `f`.`id`            =
                                           `t`.`funder_template_id`
JOIN `dmp2`.`resources`         AS `r` ON (`r`.`text`          =
                                           `a`.`suggested_answer_text`
                                       AND `r`.`old_funder_id` = `f`.`funder_id`)
WHERE `r`.`resource_type`      = 'suggested_response'
AND   `r`.`old_institution_id` IS NULL;

INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`,         `requirements_template_id`, `requirement_id`,
       `created_at`,             `updated_at`,               `resource_id`,
       `old_funder_id`)
SELECT `a`.`institution_id`,     `t`.`funder_template_id`,   `a`.`question_id`,
       `a`.`created_at`,         `a`.`updated_at`,           `r`.`id`,
        NULL
FROM `dmp`.`suggested_answers`  AS `a`
JOIN `dmp`.`question_templates` AS `t` ON  `t`.`question_id`        =
                                           `a`.`question_id`
JOIN `dmp2`.`resources`         AS `r` ON (`r`.`text`               =
                                           `a`.`suggested_answer_text`
                                       AND `r`.`old_institution_id` =
                                           `a`.`institution_id`)
WHERE `r`.`resource_type`      = 'suggested_response'
AND   `r`.`old_institution_id` IS NOT NULL;


# customization level 6: container for levels 5 and 7
INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`,     `requirements_template_id`,    `requirement_id`,
       `created_at`,         `updated_at`,                  `resource_id`,
       `name`,               `contact_info`,                `contact_email`,
       `review_type`)
SELECT `c`.`institution_id`, `c`.`requirements_template_id`, NULL,
       `c`.`created_at`,     `c`.`updated_at`,               NULL,
CONCAT(`t`.`name`, ' – ',
       `i`.`nickname`),      `i`.`contact_info`,            `i`.`contact_email`,
       'no_review'
FROM `dmp2`.`resource_contexts`      AS `c`
JOIN `dmp2`.`requirements_templates` AS `t` ON `t`.`id` =
                                               `c`.`requirements_template_id`
JOIN `dmp2`.`institutions`           AS `i` ON `i`.`id` = `c`.`institution_id`
WHERE `c`.`institution_id`           IS NOT NULL
AND   `c`.`requirements_template_id` IS NOT NULL
AND  (`c`.`requirement_id`           IS NOT NULL
OR    `c`.`resource_id`              IS NOT NULL)
GROUP BY `c`.`institution_id`, `c`.`requirements_template_id`;


# customization level 8: container for levels 2 and 3
INSERT INTO `dmp2`.`resource_contexts` (
       `institution_id`,     `requirements_template_id`,    `requirement_id`,
       `created_at`,         `updated_at`,                  `resource_id`,
       `name`,               `contact_info`,                `contact_email`,
       `review_type`)
SELECT  NULL,                `c`.`requirements_template_id`, NULL,
       `c`.`created_at`,     `c`.`updated_at`,               NULL,
       `t`.`name`,           `i`.`contact_info`,            `i`.`contact_email`,
       'no_review'
FROM `dmp2`.`resource_contexts`      AS `c`
JOIN `dmp2`.`requirements_templates` AS `t` ON `t`.`id` =
                                               `c`.`requirements_template_id`
JOIN `dmp2`.`institutions`           AS `i` ON `i`.`id` = `t`.`institution_id`
WHERE `c`.`institution_id`           IS     NULL
AND   `c`.`requirements_template_id` IS NOT NULL
AND  (`c`.`requirement_id`           IS NOT NULL
OR    `c`.`resource_id`              IS NOT NULL)
GROUP BY `c`.`institution_id`, `c`.`requirements_template_id`;


# additional_informations: copy DMP1 resources for question_id = -1
TRUNCATE TABLE `dmp2`.`additional_informations`;
INSERT INTO `dmp2`.`additional_informations` (
       `url`,           `label`,    `requirements_template_id`, `created_at`,
       `updated_at`)
SELECT `r`.`url`,       `r`.`desc`, `c`.`funder_template_id`,   `r`.`created_at`,
       `r`.`updated_at`
FROM `dmp`.`resource_contexts` AS `c`
JOIN `dmp`.`resources` AS `r` ON `r`.`id` = `c`.`resource_id`
WHERE `c`.`question_id` = -1;


# sample_plans: copy DMP1 resources for question_id = -2
TRUNCATE TABLE `dmp2`.`sample_plans`;
INSERT INTO `dmp2`.`sample_plans` (
       `url`,           `label`,    `requirements_template_id`, `created_at`,
       `updated_at`)
SELECT `r`.`url`,       `r`.`desc`, `c`.`funder_template_id`,   `r`.`created_at`,
       `r`.`updated_at`
FROM `dmp`.`resource_contexts` AS `c`
JOIN `dmp`.`resources` AS `r` ON `r`.`id` = `c`.`resource_id`
WHERE `c`.`question_id` = -2;



# remove the old DMP1 keys needed only during the migration
ALTER TABLE `dmp2`.`institutions`           DROP COLUMN `old_funder_id`;
ALTER TABLE `dmp2`.`requirements_templates` DROP COLUMN `old_funder_id`;
ALTER TABLE `dmp2`.`resources`              DROP COLUMN `old_funder_id`;
ALTER TABLE `dmp2`.`resources`              DROP COLUMN `old_help_text_id`;
ALTER TABLE `dmp2`.`resources`              DROP COLUMN `old_institution_id`;
ALTER TABLE `dmp2`.`resources`              DROP COLUMN `old_suggested_answer_id`;
ALTER TABLE `dmp2`.`resource_contexts`      DROP COLUMN `old_funder_id`;
ALTER TABLE `dmp2`.`users`                  DROP COLUMN `old_user_id`;

