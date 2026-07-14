INSERT INTO user_roles (user_id, role)
SELECT id, 'USER'
FROM users
ON CONFLICT (user_id, role) DO NOTHING;
