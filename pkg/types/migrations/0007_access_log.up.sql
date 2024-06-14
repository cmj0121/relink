CREATE TABLE IF NOT EXISTS relink_access_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key VARCHAR(255) NOT NULL,
  ip VARCHAR(255) NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX relink_access_log_key ON relink_access_log (key);
CREATE INDEX relink_access_log_ip ON relink_access_log (ip);
