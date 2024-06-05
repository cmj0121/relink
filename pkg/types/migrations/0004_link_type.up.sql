ALTER TABLE `relink` ADD COLUMN type VARCHAR(255);
CREATE INDEX `idx_type` ON `relink` (type);
UPDATE `relink` SET type = 'link';
