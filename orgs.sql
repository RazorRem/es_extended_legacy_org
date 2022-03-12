CREATE TABLE `orgs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `orgs` (`name`, `label`) VALUES

('unemployed2', 'Unemployed2');

CREATE TABLE `org_grades` (
  `id` int(11) NOT NULL,
  `org_name` varchar(50) DEFAULT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `skin_male` longtext NOT NULL,
  `skin_female` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `org_grades` (`id`, `org_name`, `grade`, `name`, `label`, `skin_male`, `skin_female`) VALUES
('unemployed2', 0, 'unemployed2', 'Sans orga', '{}', '{}');


ALTER TABLE `orgs`
  ADD PRIMARY KEY (`name`);
COMMIT;

ALTER TABLE `org_grades`
  ADD PRIMARY KEY (`id`);
  
ALTER TABLE `org_grades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=815;
COMMIT;

