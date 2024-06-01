ALTER TABLE `relink` ADD COLUMN password VARCHAR(255);
CREATE UNIQUE INDEX `uk_value_password` ON `relink` (value, password);
