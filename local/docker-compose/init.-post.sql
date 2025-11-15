-- ============================================================================
-- Script de Inicialización de PostgreSQL para Microservicios
-- ============================================================================
-- Este script se ejecuta automáticamente al crear el contenedor
-- ============================================================================

-- Crear bases de datos para cada microservicio
CREATE DATABASE users_db;
CREATE DATABASE orders_db;
CREATE DATABASE products_db;
CREATE DATABASE payments_db;
CREATE DATABASE notifications_db;

-- Crear usuario para desarrollo
CREATE USER dev_user WITH PASSWORD 'dev_pass';

-- Otorgar permisos a todas las bases de datos
GRANT ALL PRIVILEGES ON DATABASE users_db TO dev_user;
GRANT ALL PRIVILEGES ON DATABASE orders_db TO dev_user;
GRANT ALL PRIVILEGES ON DATABASE products_db TO dev_user;
GRANT ALL PRIVILEGES ON DATABASE payments_db TO dev_user;
GRANT ALL PRIVILEGES ON DATABASE notifications_db TO dev_user;

-- ============================================================================
-- Base de datos: USERS
-- ============================================================================
\c users_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabla de usuarios
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Tabla de perfiles
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    address JSONB,
    preferences JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de relación usuarios-roles
CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- Insertar roles por defecto
INSERT INTO roles (name, description) VALUES
    ('admin', 'Administrador del sistema'),
    ('user', 'Usuario estándar'),
    ('premium', 'Usuario premium'),
    ('moderator', 'Moderador de contenido');

-- Insertar usuario de prueba
INSERT INTO users (email, username, password_hash, first_name, last_name, is_verified)
VALUES ('test@example.com', 'testuser', crypt('password123', gen_salt('bf')), 'Test', 'User', true);

-- Índices para optimización
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- Base de datos: PRODUCTS
-- ============================================================================
\c products_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de categorías
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES categories(id),
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    images JSONB,
    attributes JSONB,
    weight DECIMAL(10, 2),
    dimensions JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_price CHECK (price >= 0),
    CONSTRAINT positive_stock CHECK (stock >= 0)
);

-- Tabla de variantes de productos
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255),
    price DECIMAL(10, 2),
    stock INTEGER DEFAULT 0,
    attributes JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar categorías de ejemplo
INSERT INTO categories (name, slug, description) VALUES
    ('Electrónica', 'electronica', 'Productos electrónicos'),
    ('Ropa', 'ropa', 'Vestimenta y accesorios'),
    ('Hogar', 'hogar', 'Artículos para el hogar'),
    ('Deportes', 'deportes', 'Equipamiento deportivo');

-- Insertar productos de ejemplo
INSERT INTO products (sku, name, description, category_id, price, stock) VALUES
    ('PROD-001', 'Laptop HP 15', 'Laptop HP 15 pulgadas, 8GB RAM', 1, 599.99, 10),
    ('PROD-002', 'Mouse Logitech', 'Mouse inalámbrico', 1, 29.99, 50),
    ('PROD-003', 'Camiseta Deportiva', 'Camiseta para running', 2, 19.99, 100);

-- Índices
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);

-- ============================================================================
-- Base de datos: ORDERS
-- ============================================================================
\c orders_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tipo ENUM para estado de orden
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled');

-- Tabla de órdenes
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id UUID NOT NULL,
    status order_status DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    discount DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address JSONB NOT NULL,
    billing_address JSONB,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de items de orden
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (quantity > 0)
);

-- Tabla de historial de estado de órdenes
CREATE TABLE order_status_history (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    status order_status NOT NULL,
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar orden de ejemplo
INSERT INTO orders (order_number, user_id, subtotal, total, shipping_address) VALUES
    ('ORD-2024-001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 49.98, 54.98, 
     '{"street": "123 Main St", "city": "Madrid", "country": "Spain", "zip": "28001"}');

-- Índices
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- ============================================================================
-- Base de datos: PAYMENTS
-- ============================================================================
\c payments_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tipo ENUM para estado de pago
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('credit_card', 'debit_card', 'paypal', 'stripe', 'bank_transfer');

-- Tabla de pagos
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    user_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status payment_status DEFAULT 'pending',
    payment_method payment_method NOT NULL,
    transaction_id VARCHAR(255) UNIQUE,
    gateway_response JSONB,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de métodos de pago del usuario
CREATE TABLE user_payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    payment_method payment_method NOT NULL,
    card_last4 VARCHAR(4),
    card_brand VARCHAR(20),
    expiry_month INTEGER,
    expiry_year INTEGER,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    gateway_customer_id VARCHAR(255),
    gateway_payment_method_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================================================
-- Base de datos: NOTIFICATIONS
-- ============================================================================
\c notifications_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tipo ENUM para tipo de notificación
CREATE TYPE notification_type AS ENUM ('email', 'sms', 'push', 'in_app');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'delivered', 'failed', 'read');

-- Tabla de notificaciones
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type notification_type NOT NULL,
    status notification_status DEFAULT 'pending',
    title VARCHAR(255),
    message TEXT NOT NULL,
    data JSONB,
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de templates de notificaciones
CREATE TABLE notification_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    type notification_type NOT NULL,
    subject VARCHAR(255),
    template TEXT NOT NULL,
    variables JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar templates de ejemplo
INSERT INTO notification_templates (name, type, subject, template) VALUES
    ('welcome_email', 'email', 'Bienvenido a nuestra plataforma', 
     'Hola {{name}}, bienvenido a nuestra plataforma!'),
    ('order_confirmation', 'email', 'Confirmación de orden #{{order_number}}', 
     'Tu orden #{{order_number}} ha sido confirmada. Total: {{total}}');

-- Índices
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- ============================================================================
-- FUNCIONES Y TRIGGERS ÚTILES
-- ============================================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a las tablas (ejecutar en cada base de datos)
-- Para users_db
\c users_db;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Para products_db
\c products_db;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Para orders_db
\c orders_db;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FIN DEL SCRIPT DE INICIALIZACIÓN
-- ============================================================================