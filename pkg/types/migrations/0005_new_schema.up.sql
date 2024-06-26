CREATE TABLE IF NOT EXISTS `relink_2` (
	key VARCHAR(225) NOT NULL PRIMARY KEY,
	ip VARCHAR(225) NOT NULL,
	type VARCHAR(225) NOT NULL,
	password VARCHAR(225),
	pwd_hint VARCHAR(225),
	link VARCHAR(225),
	text TEXT,
	image BLOB,
	mime VARCHAR(225),

	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	expired_at TIMESTAMP
);

INSERT INTO `relink_2` (key, ip, type, password, link, created_at)
SELECT key, IFNULL(creator_ip, '-') , 'link', password, value, created_at FROM `relink`;
