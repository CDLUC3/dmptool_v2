INSERT INTO `institutions` (`id`, `full_name`, `nickname`, `ancestry`)

VALUES ('1', 'Test Institution', 'Testy', NULL),     
       ('2', 'Non Partner Institution', 'Non partner', NULL), #set manually
       ('3', 'sub test institution 1', 'sub test institution 1', 1),
       ('4', 'sub test institution 2', 'sub test institution 2', 1),
       ('5', 'UCOP', 'UCOP', NULL),
       ('6', 'CDL', 'CDL', 5),
       ('7', 'NRS', 'NRS', 5);



INSERT INTO `users` (`id`, `institution_id`, `email`, `first_name`, `last_name`, `token`, `token_expiration`, `prefs`, `created_at`, `updated_at`, `login_id`, `active`, `deleted_at`, `orcid_id`, `auth_token`)
VALUES
      (1,0,'admin123@gmail.com','Admin','123',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D69747465643A20747275650A20203A7669735F6368616E67653A20747275650A20203A7375626D69747465643A20747275650A20203A757365725F61646465643A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D69747465643A20747275650A20203A6465616374697665643A20747275650A3A7265736F757263655F656469746F72733A0A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D69747465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2015-03-09 19:03:04','2015-03-09 19:03:28','admin123',1,NULL,NULL,'9401c20f3d7fb9b6b8a3e84b7513b362'),
      (2,5,'resource123@gmail.com','Resource','123',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:46:51','2013-12-20 21:32:03','resource123',1,NULL,NULL,NULL),
      (3,5,'require123@gmail.com','Require123','123',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:47:12','2013-11-05 17:33:48','require123',1,NULL,NULL,NULL),
      (4,5,'instrev123@gmail.com','Instrev123','123',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A20747275650A20203A64656163746976617465643A20747275650A20203A64656C657465643A20747275650A20203A6E65775F636F5F6F776E65723A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:47:37','2013-11-05 15:20:10','instrev123',1,NULL,NULL,NULL),
      (5,5,'instadmin123@gmail.com','Instadmin123','123',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:48:06','2014-01-07 22:21:56','instadmin123',1,NULL,NULL,NULL),
      (6,4,'testsub_02@gmail.com','testsub','02',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:48:06','2014-01-07 22:21:56','testsub_02',1,NULL,NULL,NULL),
      (7,5,'ucopuser001@gmail.com','ucopuser001','ucopuser001',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:48:06','2014-01-07 22:21:56','ucopuser001',1,NULL,NULL,NULL),
      (8,6,'cdluser001@gmail.com','cdluser001','cdluser001',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:48:06','2014-01-07 22:21:56','cdluser001',1,NULL,NULL,NULL),
      (9,7,'nrsuser001@gmail.com','nrsuser001','nrsuser001',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A2066616C73650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A2066616C73650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A2066616C73650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:48:06','2014-01-07 22:21:56','nrsuser001',1,NULL,NULL,NULL),
      (15,3,'testsub_01@gmail.com','testsub','01',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D697465643A20747275650A20203A7075626C69736865643A20747275650A20203A7375626D69747465643A20747275650A3A646D705F636F3A0A20203A7375626D69747465643A2066616C73650A20203A64656163746976617465643A2066616C73650A20203A64656C657465643A2066616C73650A20203A6E65775F636F5F6F776E65723A2066616C73650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A3A7265736F757263655F656469746F72733A0A20203A636F6D6D697465643A20747275650A20203A6465616374697665643A20747275650A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D697465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2013-11-01 23:46:01','2013-12-11 20:40:29','testsub_01',1,NULL,NULL,NULL),
      (19,6,'cdluser002@gmail.com','cdluser002','cdluser002',NULL,NULL,X'2D2D2D0A3A75736572733A0A20203A726F6C655F6772616E7465643A20747275650A3A646D705F6F776E6572735F616E645F636F3A0A20203A6E65775F636F6D6D656E743A20747275650A20203A636F6D6D69747465643A20747275650A20203A7669735F6368616E67653A20747275650A20203A7375626D69747465643A20747275650A20203A757365725F61646465643A20747275650A3A726571756972656D656E745F656469746F72733A0A20203A636F6D6D69747465643A20747275650A20203A6465616374697665643A20747275650A3A7265736F757263655F656469746F72733A0A20203A64656C657465643A20747275650A20203A6173736F6369617465645F636F6D6D69747465643A20747275650A3A696E737469747574696F6E616C5F7265766965776572733A0A20203A7375626D69747465643A20747275650A20203A6E65775F636F6D6D656E743A20747275650A20203A617070726F7665645F72656A65637465643A20747275650A','2015-03-09 20:21:54','2015-03-09 20:21:54','cdluser002',1,NULL,NULL,'0af21b93c29859d18dac218551c40da6');




INSERT INTO `roles` (`id`, `name`, `created_at`, `updated_at`)
VALUES 
		(1, 'DMP Administrator', '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(2, 'Resources Editor', '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(3, 'Template Editor', '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(4, 'Institutional Reviewer', '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(5, 'Institutional Administrator', '2013-11-01 23:46:01', '2013-12-11 20:40:29');



INSERT INTO `authorizations` (`id`, `role_id`, `user_id`, `created_at`, `updated_at`)
VALUES 
		(1, 1, 1, '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(2, 2, 2, '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(3, 3, 3, '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(4, 4, 4, '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(5, 5, 5, '2013-11-01 23:46:01', '2013-12-11 20:40:29'),
		(6, 3, 15, '2013-11-01 23:46:01', '2013-12-11 20:40:29');



INSERT INTO `requirements_templates` (`id`, `institution_id`, `name`, `active`, `start_date`, `end_date`, `visibility`, `review_type`, `created_at`, `updated_at`)
VALUES
      (1,6,'cdl institutional template with optional review',1,NULL,NULL,'institutional','informal_review','2015-03-09 20:07:29','2015-03-09 21:37:59'),
      (2,6,'cdl public template - no review',1,NULL,NULL,'public','no_review','2015-03-09 20:10:23','2015-03-09 20:11:45'),
      (3,5,'ucop_institutional_template_informal_review',1,NULL,NULL,'institutional','informal_review','2015-03-09 20:12:14','2015-03-09 20:13:04'),
      (4,5,'ucop public template - formal review',1,NULL,NULL,'public','formal_review','2015-03-09 20:13:39','2015-03-09 20:14:23'),
      (5,7,'NRS_institutional_template_no_review',1,NULL,NULL,'institutional','no_review','2015-03-09 20:14:58','2015-03-09 20:15:59'),
      (6,7,'NRS public template no review',1,NULL,NULL,'public','no_review','2015-03-09 20:17:24','2015-03-09 20:18:17'),
      (7,0,'public non partner template - no review',1,NULL,NULL,'public','no_review','2015-03-09 20:18:51','2015-03-09 21:31:47'),
      (8,0,'Inactive non partner public template - no review',0,NULL,NULL,'public','no_review','2015-03-09 20:20:42','2015-03-09 20:20:58'),
      (9,6,'CDL Public - Mandatory Review',1,NULL,NULL,'public','formal_review','2015-03-09 21:32:47','2015-03-09 21:33:27'),
      (10,5,'UCOP public - no Review',1,NULL,NULL,'public','no_review','2015-03-09 21:34:15','2015-03-09 21:35:00'),
      (11,7,'Colors - NRS public - no review',1,NULL,NULL,'public','no_review','2015-03-09 21:35:38','2015-03-09 21:37:28');




INSERT INTO `requirements` (`id`, `position`, `text_brief`, `text_full`, `requirement_type`, `obligation`, `default`, `requirements_template_id`, `created_at`, `updated_at`, `ancestry`, `group`)
VALUES
      (1,1,' How old are you ?','How old are you ?','numeric','recommended',NULL,1,'2015-03-09 20:08:16','2015-03-09 20:08:16',NULL,0),
      (2,2,'Choose a color','Choose a color','enum','mandatory',NULL,1,'2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,0),
      (3,1,'How many days ?','How many days ?','numeric','recommended',NULL,2,'2015-03-09 20:11:00','2015-03-09 20:11:00',NULL,0),
      (4,2,'Types of data','Types of data','text','mandatory',NULL,2,'2015-03-09 20:11:38','2015-03-09 20:11:38',NULL,0),
      (5,1,'Describe Data','Describe Data','text','mandatory_applicable',NULL,3,'2015-03-09 20:12:43','2015-03-09 20:12:43',NULL,0),
      (6,2,'Describe methods','Describe methods','text','recommended',NULL,3,'2015-03-09 20:13:01','2015-03-09 20:13:01',NULL,0),
      (7,1,'Mandatory requirement 1','Mandatory requirement 1','text','mandatory',NULL,4,'2015-03-09 20:13:58','2015-03-09 20:13:58',NULL,0),
      (8,2,'Mandatory Requirement 2','Mandatory Requirement 2','text','mandatory',NULL,4,'2015-03-09 20:14:16','2015-03-09 20:14:16',NULL,0),
      (9,1,'Question 1','Question 1','text','optional',NULL,5,'2015-03-09 20:15:21','2015-03-09 20:15:21',NULL,0),
      (10,2,'Question 2','Question 2','enum','recommended',NULL,5,'2015-03-09 20:15:55','2015-03-09 20:15:55',NULL,0),
      (11,1,'Birthday','Birthday','date','recommended',NULL,6,'2015-03-09 20:17:53','2015-03-09 20:17:53',NULL,0),
      (12,2,'Meeting','meeting','date','mandatory',NULL,6,'2015-03-09 20:18:12','2015-03-09 20:18:12',NULL,0),
      (13,1,'Why?','Why?','text','optional',NULL,7,'2015-03-09 20:19:13','2015-03-09 20:19:13',NULL,0),
      (14,2,'Where?','Where?','text','recommended',NULL,7,'2015-03-09 20:19:32','2015-03-09 20:19:32',NULL,0),
      (15,3,'When?','When?','date','mandatory',NULL,7,'2015-03-09 20:19:47','2015-03-09 20:19:47',NULL,0),
      (16,1,'Inactive question 1','inactive question 1','text','optional',NULL,8,'2015-03-09 20:20:58','2015-03-09 20:20:58',NULL,0),
      (17,1,'q1','q1','text','mandatory',NULL,9,'2015-03-09 21:32:59','2015-03-09 21:32:59',NULL,0),
      (18,2,'q2','q2','date','mandatory_applicable',NULL,9,'2015-03-09 21:33:20','2015-03-09 21:33:20',NULL,0),
      (19,1,'q1','q1','text','recommended',NULL,10,'2015-03-09 21:34:28','2015-03-09 21:34:28',NULL,0),
      (20,2,'q2','q2','enum','optional',NULL,10,'2015-03-09 21:34:55','2015-03-09 21:34:55',NULL,0),
      (21,1,'Choose','Choose','enum','mandatory_applicable',NULL,11,'2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0);


INSERT INTO `labels` (`id`, `desc`, `created_at`, `updated_at`, `position`, `requirement_id`)
VALUES
      (1,'Years','2015-03-09 20:08:16','2015-03-09 20:08:16',NULL,1),
      (2,'Days','2015-03-09 20:11:00','2015-03-09 20:11:00',NULL,3);



INSERT INTO `enumerations` (`id`, `requirement_id`, `value`, `created_at`, `updated_at`, `position`, `default`)
VALUES
      (1,2,'mint ','2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,1),
      (2,2,'light green','2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,0),
      (3,2,'dark green','2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,0),
      (4,2,'emerald green','2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,0),
      (5,2,'medium green','2015-03-09 20:09:34','2015-03-09 20:09:34',NULL,0),
      (6,10,'A','2015-03-09 20:15:55','2015-03-09 20:15:55',NULL,1),
      (7,10,'B','2015-03-09 20:15:55','2015-03-09 20:15:55',NULL,0),
      (8,10,'C','2015-03-09 20:15:55','2015-03-09 20:15:55',NULL,0),
      (9,20,'a','2015-03-09 21:34:55','2015-03-09 21:34:55',NULL,0),
      (10,20,'b','2015-03-09 21:34:55','2015-03-09 21:34:55',NULL,0),
      (11,20,'c','2015-03-09 21:34:55','2015-03-09 21:34:55',NULL,1),
      (12,21,'blue','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,1),
      (13,21,'yellow','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (14,21,'beige','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (15,21,'dark purple','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (16,21,'dark orange','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (17,21,'terracotta','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (18,21,'off white','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0),
      (19,21,'turquoise','2015-03-09 21:36:34','2015-03-09 21:36:34',NULL,0);



INSERT INTO `responses` (`id`, `plan_id`, `requirement_id`, `label_id`, `text_value`, `created_at`, `updated_at`, `numeric_value`, `date_value`, `enumeration_id`, `lock_version`)
VALUES
      (1,1,13,NULL,'<p>1</p>\r\n','2015-03-09 20:55:47','2015-03-09 20:55:47',NULL,NULL,NULL,0),
      (2,1,14,NULL,'<p>City</p>\r\n','2015-03-09 20:56:00','2015-03-09 20:56:00',NULL,NULL,NULL,0),
      (3,1,15,NULL,NULL,'2015-03-09 20:56:07','2015-03-09 20:56:07',NULL,'2015-03-10',NULL,0),
      (4,2,13,NULL,'<p>Yes</p>\r\n','2015-03-09 21:01:31','2015-03-09 21:01:31',NULL,NULL,NULL,0),
      (5,2,14,NULL,'<p>Here</p>\r\n','2015-03-09 21:01:38','2015-03-09 21:01:38',NULL,NULL,NULL,0),
      (6,2,15,NULL,NULL,'2015-03-09 21:01:48','2015-03-09 21:01:48',NULL,'2015-03-01',NULL,0),
      (7,3,9,NULL,'<p>Answer 1</p>\r\n','2015-03-09 21:17:13','2015-03-09 21:17:13',NULL,NULL,NULL,0),
      (8,3,10,NULL,NULL,'2015-03-09 21:17:21','2015-03-09 21:17:21',NULL,NULL,7,0),
      (9,4,9,NULL,'<p>1</p>\r\n','2015-03-09 21:18:07','2015-03-09 21:18:07',NULL,NULL,NULL,0),
      (10,4,10,NULL,NULL,'2015-03-09 21:18:16','2015-03-09 21:18:16',NULL,NULL,8,0),
      (11,5,9,NULL,'<p>1234567</p>\r\n','2015-03-09 21:19:12','2015-03-09 21:19:12',NULL,NULL,NULL,0),
      (12,5,10,NULL,NULL,'2015-03-09 21:19:19','2015-03-09 21:19:19',NULL,NULL,6,0),
      (13,6,9,NULL,'<p>abc</p>\r\n','2015-03-09 21:20:56','2015-03-09 21:20:56',NULL,NULL,NULL,0),
      (14,6,10,NULL,NULL,'2015-03-09 21:21:02','2015-03-09 21:21:02',NULL,NULL,8,0),
      (15,7,7,NULL,'<p>explanation 1</p>\r\n','2015-03-09 21:22:58','2015-03-09 21:22:58',NULL,NULL,NULL,0),
      (16,7,8,NULL,'<p>explanation 2</p>\r\n','2015-03-09 21:23:06','2015-03-09 21:23:06',NULL,NULL,NULL,0),
      (17,8,1,1,NULL,'2015-03-09 21:40:23','2015-03-09 21:40:23',23,NULL,NULL,0),
      (18,8,2,NULL,NULL,'2015-03-09 21:40:31','2015-03-09 21:40:31',NULL,NULL,3,0),
      (19,9,21,NULL,NULL,'2015-03-09 21:41:34','2015-03-09 21:41:34',NULL,NULL,14,0),
      (20,10,17,NULL,'<p>1</p>\r\n','2015-03-09 21:42:38','2015-03-09 21:42:38',NULL,NULL,NULL,0),
      (21,10,18,NULL,NULL,'2015-03-09 21:42:46','2015-03-09 21:42:46',NULL,'2015-03-11',NULL,0);




























