




CREATE TABLE `player_mashbarrel` (
  `id` int(11) NOT NULL,
  `coords` longtext,
  `water` varchar(100) NOT NULL,
  `grains` double NOT NULL,
  `yeast` double NOT NULL,
  `flavor` double NOT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `player_mashbarrel`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `player_mashbarrel`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;


----------------------------------------------------------------------------------------------
CREATE TABLE `player_mashbarrel` (
  `id` int(11) NOT NULL,
  `coords` longtext,
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `player_mashbarrel`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `player_mashbarrel`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
