CREATE TABLE IF NOT EXISTS `relink_2` (
	key VARCHAR(225) NOT NULL PRIMARY KEY,
	type VARCHAR(225) NOT NULL,
	password VARCHAR(225),
	pwd_hint VARCHAR(225),
	link VARCHAR(225),
	text TEXT,
	image BLOB,
	mime VARCHAR(225),

	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP
);

INSERT INTO `relink_2` (key, type, password, link, created_at) SELECT key, 'link', password, value, created_at FROM `relink`;
