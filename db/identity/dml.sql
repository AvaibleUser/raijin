INSERT INTO
    roles (name, description)
VALUES
    ('ADMIN', 'Administrador del sistema'),
    ('PRODUCT_OWNER', 'Encargado del producto'),
    ('SCRUM_MASTER', 'Scrum Master'),
    ('DEVELOPER', 'Desarrollador'),
    ('QA', 'Encargado de calidad'),
    ('USER', 'Usuario');

INSERT INTO
    permissions (key, description)
VALUES
    ('projects:delete', 'Eliminar proyectos'),
    ('projects:write', 'Crear y editar proyectos'),
    ('projects:read', 'Ver proyectos'),
    ('sprints:delete', 'Eliminar sprints'),
    ('sprints:write', 'Crear y editar sprints'),
    ('sprints:read', 'Ver sprints'),
    ('stories:delete', 'Eliminar historias'),
    ('stories:write', 'Crear y editar historias'),
    ('stories:read', 'Ver historias'),
    ('users:delete', 'Banear usuarios'),
    ('users:write', 'Verificar y editar usuarios'),
    ('users:read', 'Ver usuarios'),
    ('roles:delete', 'Eliminar roles'),
    ('roles:write', 'Crear y editar roles'),
    ('roles:read', 'Ver roles'),
    ('employees:delete', 'Dar de baja empleados'),
    ('employees:write', 'Manejar empleados'),
    ('employees:read', 'Ver empleados'),
    ('costs:delete', 'Eliminar costos'),
    ('costs:write', 'Crear y editar costos'),
    ('costs:read', 'Ver costos');