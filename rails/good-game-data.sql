
INSERT INTO `game_actions` VALUES(2, 2, 4, '{"location_id":3,"created_player_id":7,"created_player_class":"Terra::Predator"}', 'Terra::ActLaunch', '2013-04-01 23:52:37', '2013-04-02 00:24:26');
INSERT INTO `game_actions` VALUES(6, 7, NULL, '{"new_location_id":4}', 'Terra::ActMove', '2013-04-02 20:47:58', '2013-04-02 20:49:32');
INSERT INTO `game_actions` VALUES(7, 1, 5, '{"location_id":3,"created_player_id":8,"created_player_class":"Terra::Predator"}', 'Terra::ActLaunch', '2013-04-03 19:47:17', '2013-04-03 19:49:02');
INSERT INTO `game_actions` VALUES(8, 8, NULL, '{"new_location_id":2}', 'Terra::ActMove', '2013-04-03 20:47:19', '2013-04-03 20:47:51');



INSERT INTO `game_items` VALUES(1, 1, 35.5, NULL, 1);
INSERT INTO `game_items` VALUES(2, 1, 939.75, 1, 1);
INSERT INTO `game_items` VALUES(3, 2, 960, NULL, 1);
INSERT INTO `game_items` VALUES(4, 2, 950, NULL, 2);
INSERT INTO `game_items` VALUES(5, 1, 300, 14, 2);
INSERT INTO `game_items` VALUES(8, 1, -65, 19, 2);
INSERT INTO `game_items` VALUES(9, 1, -65, 26, 2);
INSERT INTO `game_items` VALUES(10, 1, 835, 30, 2);
INSERT INTO `game_items` VALUES(12, 1, -180, 29, 1);
INSERT INTO `game_items` VALUES(13, 1, -65, 37, 2);
INSERT INTO `game_items` VALUES(14, 1, -130, 5, 2);
INSERT INTO `game_items` VALUES(18, 1, -65, 31, 2);
INSERT INTO `game_items` VALUES(19, 1, 950, 2, 2);


INSERT INTO `game_locations` VALUES(1, 0, 0, 1, 1);
INSERT INTO `game_locations` VALUES(2, 0, 1, 1, 1);
INSERT INTO `game_locations` VALUES(3, 0, 2, 1, 1);
INSERT INTO `game_locations` VALUES(4, 0, 3, 1, 1);
INSERT INTO `game_locations` VALUES(5, 0, 4, 1, 1);
INSERT INTO `game_locations` VALUES(6, 0, 5, 1, 1);
INSERT INTO `game_locations` VALUES(7, 1, 0, 1, 1);
INSERT INTO `game_locations` VALUES(8, 1, 1, 1, 1);
INSERT INTO `game_locations` VALUES(9, 1, 2, 1, 1);
INSERT INTO `game_locations` VALUES(10, 1, 3, 1, 1);
INSERT INTO `game_locations` VALUES(11, 1, 4, 1, 1);
INSERT INTO `game_locations` VALUES(12, 1, 5, 1, 1);
INSERT INTO `game_locations` VALUES(13, 2, 0, 1, 1);
INSERT INTO `game_locations` VALUES(14, 2, 1, 1, 1);
INSERT INTO `game_locations` VALUES(15, 2, 2, 1, 1);
INSERT INTO `game_locations` VALUES(16, 2, 3, 1, 1);
INSERT INTO `game_locations` VALUES(17, 2, 4, 1, 1);
INSERT INTO `game_locations` VALUES(18, 2, 5, 1, 1);
INSERT INTO `game_locations` VALUES(19, 3, 0, 1, 1);
INSERT INTO `game_locations` VALUES(20, 3, 1, 1, 1);
INSERT INTO `game_locations` VALUES(21, 3, 2, 1, 1);
INSERT INTO `game_locations` VALUES(22, 3, 3, 1, 1);
INSERT INTO `game_locations` VALUES(23, 3, 4, 1, 1);
INSERT INTO `game_locations` VALUES(24, 3, 5, 1, 1);
INSERT INTO `game_locations` VALUES(25, 4, 0, 1, 1);
INSERT INTO `game_locations` VALUES(26, 4, 1, 1, 1);
INSERT INTO `game_locations` VALUES(27, 4, 2, 1, 1);
INSERT INTO `game_locations` VALUES(28, 4, 3, 1, 1);
INSERT INTO `game_locations` VALUES(29, 4, 4, 1, 1);
INSERT INTO `game_locations` VALUES(30, 4, 5, 1, 1);


INSERT INTO `game_players` VALUES(1, 1, 1, 8, NULL, 'pseudopeach', NULL, NULL, NULL, NULL, NULL, 'Game::HumanPlayer');
INSERT INTO `game_players` VALUES(2, 2, 1, 7, NULL, 'CovertBrit', NULL, NULL, NULL, NULL, NULL, 'Game::HumanPlayer');
INSERT INTO `game_players` VALUES(4, 2, NULL, NULL, NULL, 'snake p2', 4, 50, 50, NULL, '{"blueprint":{"base":3,"upgrades":[]}}', 'Terra::Predator');
INSERT INTO `game_players` VALUES(5, 1, NULL, NULL, NULL, 'bear p1', 5, 75, 65, NULL, '{"blueprint":{"base":4,"upgrades":[]}}', 'Terra::Predator');
INSERT INTO `game_players` VALUES(7, 2, 1, 1, 2, 'snake p2', 4, 50, 50, 4, '{"blueprint":{"base":3,"upgrades":[]},"activity":"flee","predator_id":8}', 'Terra::Predator');
INSERT INTO `game_players` VALUES(8, 1, 1, 2, 1, 'bear p1', 5, 75, 65, 2, '{"blueprint":{"base":4,"upgrades":[]}}', 'Terra::Predator');



INSERT INTO `game_player_attributes` VALUES(2, 4, 'pa_attack', 10);
INSERT INTO `game_player_attributes` VALUES(3, 4, 'pa_defense', 5);
INSERT INTO `game_player_attributes` VALUES(4, 4, 'pa_diet', 3);
INSERT INTO `game_player_attributes` VALUES(5, 4, 'pa_habitat', 1);
INSERT INTO `game_player_attributes` VALUES(6, 4, 'pa_hunger', 3);
INSERT INTO `game_player_attributes` VALUES(7, 4, 'pa_movement', 2);
INSERT INTO `game_player_attributes` VALUES(8, 4, 'pa_size', 50);
INSERT INTO `game_player_attributes` VALUES(9, 5, 'pa_attack', 10);
INSERT INTO `game_player_attributes` VALUES(10, 5, 'pa_defense', 8);
INSERT INTO `game_player_attributes` VALUES(11, 5, 'pa_diet', 2);
INSERT INTO `game_player_attributes` VALUES(12, 5, 'pa_habitat', 1);
INSERT INTO `game_player_attributes` VALUES(13, 5, 'pa_hunger', 60);
INSERT INTO `game_player_attributes` VALUES(14, 5, 'pa_movement', 3);
INSERT INTO `game_player_attributes` VALUES(15, 5, 'pa_size', 400);
INSERT INTO `game_player_attributes` VALUES(19, 7, 'pa_hit_points', 38);
INSERT INTO `game_player_attributes` VALUES(20, 7, 'pa_moves_left', 2);
INSERT INTO `game_player_attributes` VALUES(21, 7, 'pa_repro_prog', 0);
INSERT INTO `game_player_attributes` VALUES(26, 8, 'pa_hit_points', 340);
INSERT INTO `game_player_attributes` VALUES(27, 8, 'pa_moves_left', 3);
INSERT INTO `game_player_attributes` VALUES(28, 8, 'pa_repro_prog', 0);


INSERT INTO `game_player_attr_entries` VALUES(4, 19, 2, 50, NULL);
INSERT INTO `game_player_attr_entries` VALUES(5, 20, 2, 2, NULL);
INSERT INTO `game_player_attr_entries` VALUES(6, 21, 2, 0, NULL);
INSERT INTO `game_player_attr_entries` VALUES(7, 20, 6, 1, NULL);
INSERT INTO `game_player_attr_entries` VALUES(8, 25, 6, 4, NULL);
INSERT INTO `game_player_attr_entries` VALUES(9, 19, 6, 47, NULL);
INSERT INTO `game_player_attr_entries` VALUES(11, 19, NULL, 44, 4);
INSERT INTO `game_player_attr_entries` VALUES(12, 20, NULL, 2, 4);
INSERT INTO `game_player_attr_entries` VALUES(13, 26, 7, 400, NULL);
INSERT INTO `game_player_attr_entries` VALUES(14, 27, 7, 3, NULL);
INSERT INTO `game_player_attr_entries` VALUES(15, 28, 7, 0, NULL);
INSERT INTO `game_player_attr_entries` VALUES(16, 19, NULL, 41, 7);
INSERT INTO `game_player_attr_entries` VALUES(17, 20, NULL, 2, 7);
INSERT INTO `game_player_attr_entries` VALUES(18, 19, NULL, 38, 10);
INSERT INTO `game_player_attr_entries` VALUES(19, 20, NULL, 2, 10);
INSERT INTO `game_player_attr_entries` VALUES(20, 27, 8, 2, NULL);
INSERT INTO `game_player_attr_entries` VALUES(21, 26, 8, 340, NULL);
INSERT INTO `game_player_attr_entries` VALUES(22, 27, NULL, 3, 12);

-- --------------------------------------------------------


INSERT INTO `game_states` VALUES(1, 'turn_end', NULL, '2013-03-31 16:57:35', '2013-04-03 20:48:04', 2);



INSERT INTO `game_turn_completions` VALUES(1, 1, 2, '2013-04-02 15:31:40');
INSERT INTO `game_turn_completions` VALUES(4, 1, 7, '2013-04-03 01:31:24');
INSERT INTO `game_turn_completions` VALUES(5, 1, 1, '2013-04-03 19:53:54');
INSERT INTO `game_turn_completions` VALUES(6, 1, 2, '2013-04-03 19:55:51');
INSERT INTO `game_turn_completions` VALUES(7, 1, 7, '2013-04-03 20:01:52');
INSERT INTO `game_turn_completions` VALUES(8, 1, 1, '2013-04-03 20:04:53');
INSERT INTO `game_turn_completions` VALUES(9, 1, 2, '2013-04-03 20:44:19');
INSERT INTO `game_turn_completions` VALUES(10, 1, 7, '2013-04-03 20:45:40');
INSERT INTO `game_turn_completions` VALUES(11, 1, 1, '2013-04-03 20:46:07');
INSERT INTO `game_turn_completions` VALUES(12, 1, 8, '2013-04-03 20:48:04');



INSERT INTO `terra_player_observers` VALUES(2, NULL, 7, 'Terra::ActAttack', 'attacked', 0);
INSERT INTO `terra_player_observers` VALUES(3, NULL, 8, 'Terra::ActAttack', 'attacked', 0);
